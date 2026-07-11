from __future__ import annotations

import json
from typing import Any

import pytest


class JsonLogger:

    def __init__(self) -> None:
        self._buffer: list[dict[str, Any]] = []
        self._correlation_id: str | None = None
        self._trace_spans: list[dict[str, Any]] = []

    def _log(self, level: str, message: str, **kwargs: Any) -> None:
        record: dict[str, Any] = {
            "level": level,
            "message": message,
            "correlation_id": self._correlation_id,
            **kwargs,
        }
        self._buffer.append(record)

    def debug(self, message: str, **kwargs: Any) -> None:
        self._log("DEBUG", message, **kwargs)

    def info(self, message: str, **kwargs: Any) -> None:
        self._log("INFO", message, **kwargs)

    def warning(self, message: str, **kwargs: Any) -> None:
        self._log("WARNING", message, **kwargs)

    def error(self, message: str, **kwargs: Any) -> None:
        self._log("ERROR", message, **kwargs)

    def critical(self, message: str, **kwargs: Any) -> None:
        self._log("CRITICAL", message, **kwargs)

    def set_correlation_id(self, cid: str | None) -> None:
        self._correlation_id = cid

    def start_span(self, span_name: str, **kwargs: Any) -> str:
        import uuid
        span_id = str(uuid.uuid4())
        self._trace_spans.append({"span_id": span_id, "name": span_name, "operation": "start", **kwargs})
        return span_id

    def end_span(self, span_id: str, **kwargs: Any) -> None:
        for span in self._trace_spans:
            if span["span_id"] == span_id:
                span["operation"] = "end"
                span.update(kwargs)
                break

    def record_metric(self, name: str, value: float, **kwargs: Any) -> None:
        self._log("METRIC", f"Metric: {name}", metric_name=name, metric_value=value, **kwargs)

    def get_records(self, level: str | None = None) -> list[dict[str, Any]]:
        if level:
            return [r for r in self._buffer if r["level"] == level]
        return list(self._buffer)

    def clear(self) -> None:
        self._buffer.clear()
        self._trace_spans.clear()

    def get_output(self) -> str:
        return "\n".join(json.dumps(r) for r in self._buffer)


@pytest.fixture
def logger() -> JsonLogger:
    return JsonLogger()


class TestJsonLogger:

    async def test_log_levels(self, logger: JsonLogger) -> None:
        logger.debug("debug msg")
        logger.info("info msg")
        logger.warning("warning msg")
        logger.error("error msg")
        logger.critical("critical msg")

        assert len(logger.get_records("DEBUG")) == 1
        assert len(logger.get_records("INFO")) == 1
        assert len(logger.get_records("WARNING")) == 1
        assert len(logger.get_records("ERROR")) == 1
        assert len(logger.get_records("CRITICAL")) == 1
        assert len(logger.get_records()) == 5

    async def test_json_output_format(self, logger: JsonLogger) -> None:
        logger.info("test message", extra_field="extra_value")
        output = logger.get_output()
        lines = output.strip().split("\n")
        assert len(lines) == 1
        parsed = json.loads(lines[0])
        assert parsed["level"] == "INFO"
        assert parsed["message"] == "test message"
        assert parsed["extra_field"] == "extra_value"

    async def test_correlation_id_propagation(self, logger: JsonLogger) -> None:
        logger.set_correlation_id("corr-123")
        logger.info("correlated message")
        record = logger.get_records("INFO")[0]
        assert record["correlation_id"] == "corr-123"

        logger.set_correlation_id(None)
        logger.info("uncorrelated message")
        record = logger.get_records("INFO")[1]
        assert record["correlation_id"] is None

    async def test_performance_metrics(self, logger: JsonLogger) -> None:
        logger.record_metric("response_time", 42.5, unit="ms")
        records = logger.get_records("METRIC")
        assert len(records) == 1
        assert records[0]["metric_name"] == "response_time"
        assert records[0]["metric_value"] == 42.5
        assert records[0]["unit"] == "ms"

    async def test_trace_spans(self, logger: JsonLogger) -> None:
        span_id = logger.start_span("db_query", db="postgres")
        assert span_id is not None
        assert len(logger._trace_spans) == 1
        assert logger._trace_spans[0]["name"] == "db_query"
        assert logger._trace_spans[0]["db"] == "postgres"

        logger.end_span(span_id, duration_ms=15.3)
        assert logger._trace_spans[0]["duration_ms"] == 15.3
        assert logger._trace_spans[0]["operation"] == "end"
