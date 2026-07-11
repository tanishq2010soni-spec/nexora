#!/usr/bin/env python3
"""NEXORA Production Backup Script.
Backs up PostgreSQL database, Qdrant snapshots, and uploads to S3-compatible storage.

Usage:
    python scripts/backup.py                    # Full backup
    python scripts/backup.py --type db          # Database only
    python scripts/backup.py --retention 7      # Delete backups older than 7 days

Schedule via cron:
    0 2 * * * cd /app && python scripts/backup.py >> /var/log/nexora/backup.log 2>&1
"""

import asyncio
import subprocess
import sys
import os
import tarfile
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional
from dataclasses import dataclass


@dataclass
class BackupConfig:
    db_host: str = "postgres"
    db_port: int = 5432
    db_name: str = "nexora"
    db_user: str = "nexora"
    qdrant_url: str = "http://qdrant:6333"
    backup_dir: Path = Path("/var/backups/nexora")
    retention_days: int = 30
    s3_bucket: Optional[str] = None
    s3_prefix: str = "nexora-backups"


class DatabaseBackup:
    def __init__(self, config: BackupConfig):
        self.config = config
        self.timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    def pg_dump(self) -> Path:
        """Dump PostgreSQL database to SQL file."""
        dump_file = self.config.backup_dir / f"db_{self.config.db_name}_{self.timestamp}.sql.gz"
        self.config.backup_dir.mkdir(parents=True, exist_ok=True)

        cmd = [
            "pg_dump",
            "-h", self.config.db_host,
            "-p", str(self.config.db_port),
            "-U", self.config.db_user,
            "-d", self.config.db_name,
            "--format=custom",
            "--compress=9",
            "--verbose",
        ]

        print(f"[DB] Starting pg_dump → {dump_file}")
        with open(dump_file, "wb") as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, timeout=3600)

        if result.returncode != 0:
            print(f"[DB] pg_dump FAILED: {result.stderr.decode()}")
            raise RuntimeError("Database backup failed")

        size_mb = dump_file.stat().st_size / (1024 * 1024)
        print(f"[DB] Completed: {dump_file.name} ({size_mb:.1f} MB)")
        return dump_file

    def cleanup_old_dumps(self):
        """Remove local dumps older than retention period."""
        cutoff = datetime.utcnow() - timedelta(days=self.config.retention_days)
        removed = 0
        for f in self.config.backup_dir.glob("db_*.sql.gz"):
            if datetime.fromtimestamp(f.stat().st_mtime) < cutoff:
                f.unlink()
                removed += 1
        if removed:
            print(f"[DB] Cleaned up {removed} old backup(s)")


class QdrantBackup:
    def __init__(self, config: BackupConfig):
        self.config = config
        self.timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    async def snapshot(self) -> Optional[Path]:
        """Create Qdrant snapshot."""
        import httpx

        snapshot_dir = self.config.backup_dir / "qdrant"
        snapshot_dir.mkdir(parents=True, exist_ok=True)

        try:
            async with httpx.AsyncClient(timeout=60) as client:
                # Create snapshot
                resp = await client.put(
                    f"{self.config.qdrant_url}/collections/nexora_memory/snapshots"
                )
                resp.raise_for_status()
                snapshot_info = resp.json()

                print(f"[Qdrant] Snapshot created: {snapshot_info}")
                return snapshot_dir
        except Exception as e:
            print(f"[Qdrant] Snapshot failed (non-critical): {e}")
            return None


class BackupManager:
    def __init__(self, config: Optional[BackupConfig] = None):
        self.config = config or BackupConfig()

    async def full_backup(self, backup_type: str = "all") -> dict:
        """Run full backup: DB + Qdrant."""
        results = {"timestamp": datetime.utcnow().isoformat(), "files": []}

        if backup_type in ("all", "db"):
            db = DatabaseBackup(self.config)
            dump_path = db.pg_dump()
            results["files"].append(str(dump_path))
            results["db_size_mb"] = round(dump_path.stat().st_size / (1024 * 1024), 1)

        if backup_type in ("all", "qdrant"):
            qdrant = QdrantBackup(self.config)
            qd_path = await qdrant.snapshot()
            if qd_path:
                results["files"].append(str(qd_path))

        # Upload to S3 if configured
        if self.config.s3_bucket:
            results["s3_uploaded"] = await self._upload_to_s3(results["files"])

        # Cleanup old local backups
        DatabaseBackup(self.config).cleanup_old_dumps()

        return results

    async def _upload_to_s3(self, files: list) -> bool:
        """Upload backup files to S3-compatible storage."""
        try:
            import boto3
            from botocore.config import Config

            s3 = boto3.client(
                "s3",
                config=Config(signature_version="s3v4"),
            )

            for file_path in files:
                if not os.path.exists(file_path):
                    continue
                key = f"{self.config.s3_prefix}/{os.path.basename(file_path)}"
                print(f"[S3] Uploading {os.path.basename(file_path)} → s3://{self.config.s3_bucket}/{key}")
                s3.upload_file(file_path, self.config.s3_bucket, key)
            return True
        except ImportError:
            print("[S3] boto3 not installed, skipping S3 upload")
            return False
        except Exception as e:
            print(f"[S3] Upload failed: {e}")
            return False


async def main():
    import argparse

    parser = argparse.ArgumentParser(description="NEXORA backup")
    parser.add_argument("--type", choices=["all", "db", "qdrant"], default="all")
    parser.add_argument("--retention", type=int, default=30)
    parser.add_argument("--s3-bucket", type=str, default=None)
    args = parser.parse_args()

    config = BackupConfig(
        retention_days=args.retention,
        s3_bucket=args.s3_bucket or os.environ.get("BACKUP_S3_BUCKET"),
        db_host=os.environ.get("POSTGRES_HOST", "postgres"),
        db_name=os.environ.get("POSTGRES_DB", "nexora"),
        db_user=os.environ.get("POSTGRES_USER", "nexora"),
    )

    manager = BackupManager(config)
    results = await manager.full_backup(args.type)

    print(f"\n[COMPLETE] Backup finished: {results}")


if __name__ == "__main__":
    asyncio.run(main())
