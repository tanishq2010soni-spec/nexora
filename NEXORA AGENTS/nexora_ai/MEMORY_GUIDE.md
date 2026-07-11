# Memory System Guide

## Overview

The memory system provides persistent storage for agent context, conversations, and knowledge. It supports multiple backend types with a common interface.

## Memory Types

| Type | Purpose | Example |
|------|---------|---------|
| `CONVERSATION` | Chat history | "User asked about Python" |
| `FACT` | Declarative knowledge | "The sky is blue" |
| `WORKFLOW` | Process state | "Deploy step completed" |
| `PREFERENCE` | User preferences | "User prefers dark mode" |
| `EPISODIC` | Event recollections | "User was frustrated at 3pm" |
| `PROCEDURAL` | How-to knowledge | "To deploy, run deploy.sh" |

## Memory Entry Structure

```python
from nexora_ai.domain.entities.memory import MemoryEntry
from nexora_ai.domain.enums.memory_enums import MemoryType, MemoryImportance

entry = MemoryEntry(
    id="unique-id",
    type=MemoryType.CONVERSATION,
    content="Relevant conversation excerpt",
    embedding=[0.1, 0.2, ...],   # Optional vector embedding
    importance=MemoryImportance.HIGH,
    score=0.85,                    # Computed relevance score
    tags=["python", "tutorial"],
    source="conversation-123",
    conversation_id="conv-456",
    user_id="user-789",
    metadata={"language": "en"},
)
```

## Backend Selection

| Backend | Use Case | Dependencies |
|---------|----------|-------------|
| `InMemoryMemoryBackend` | Testing, ephemeral storage | None |
| `SQLiteMemoryBackend` | Single-process persistence | `aiosqlite` |
| `VectorMemoryBackend` | Semantic search | `qdrant-client` or `chromadb` |

```python
from nexora_ai.infrastructure.memory import SQLiteMemoryBackend

backend = SQLiteMemoryBackend({"database": "memory.db"})
await backend.initialize()
```

## Scoring Algorithm

Memory entries are scored using a combination of factors:

```
score = (recency_weight * recency_score)
      + (frequency_weight * frequency_score)
      + (importance_weight * importance_base)
      + (relevance_weight * embedding_similarity)
```

- **Recency**: Higher score for recently accessed entries (decay over time)
- **Frequency**: Higher score for frequently accessed entries
- **Importance**: Base score from `MemoryImportance` (LOW=0.2, MEDIUM=0.5, HIGH=0.8, CRITICAL=1.0)
- **Relevance**: Cosine similarity between query embedding and entry embedding

## Pruning Strategies

### By Count
```python
pruned = await backend.prune(max_entries=1000)
# Removes lowest-scored entries beyond the limit
```

### By Age
```python
pruned = await backend.prune(max_age_days=30)
# Removes entries older than 30 days
```

### Combined
```python
pruned = await backend.prune(max_entries=500, max_age_days=7)
```

### Eviction Policy
Entries are sorted by `(score, created_at)` ascending. Lowest-scored, oldest entries are removed first.

## Search Optimization

### Query Fields
```python
from nexora_ai.domain.entities.memory import MemorySearchQuery

query = MemorySearchQuery(
    text="Python programming",     # Full-text search
    types=[MemoryType.FACT],       # Filter by type
    tags=["python"],               # Filter by tags
    min_score=0.3,                 # Minimum relevance threshold
    limit=20,                      # Max results
    offset=0,                      # Pagination offset
    user_id="user-789",            # Filter by user
)
result = await backend.search(query)
```

### Tips
- Use `min_score` to filter noise
- Use `types` and `tags` to narrow results
- Store embeddings for semantic search (vector backend)
- Index frequently-queried fields (type, tags, user_id)

## Best Practices

1. **Tag consistently**: Use a controlled vocabulary for tags
2. **Set importance**: Mark critical memories with `MemoryImportance.CRITICAL` to prevent pruning
3. **Prune regularly**: Schedule periodic pruning to manage storage
4. **Use user_id**: Always scope memories to users for multi-tenant systems
5. **Batch operations**: Group store/delete operations for performance
6. **Monitor latency**: Track `latency_ms` in `MemorySearchResult`
7. **Expiration**: Set `expires_at` for ephemeral memories (e.g., session data)
