# Nexora AI API Reference

## Domain Layer

### Entities

#### `Message(id, role, content, type, tool_calls, tool_call_id, name, metadata, tokens, created_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `Message` |

#### `Conversation(id, thread_id, messages, system_prompt, context_window, status, metadata, created_at, updated_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `Conversation` |

#### `Thread(id, title, conversations, metadata, created_at, updated_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `Thread` |

#### `StreamingChunk(content, finish_reason, usage, tool_calls)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `StreamingChunk` |

#### `MemoryEntry(id, type, content, embedding, importance, score, tags, source, conversation_id, user_id, metadata, created_at, accessed_at, expires_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `MemoryEntry` |

#### `MemorySearchQuery(text, types, tags, min_score, limit, offset, user_id)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `MemorySearchQuery` |

#### `MemorySearchResult(entries, total, query, latency_ms)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `MemorySearchResult` |

#### `MemorySummary(id, original_entries, summary_text, metadata, created_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `MemorySummary` |

#### `Task(id, title, description, status, priority, dependencies, parent_id, subtasks, metadata, timeout_seconds, retry_count, max_retries, created_at, started_at, completed_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `Task` |

#### `ExecutionGraph(id, tasks, strategy, metadata)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ExecutionGraph` |

#### `Plan(id, goal, graph, status, created_at, updated_at)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `Plan` |

#### `PlanResult(plan_id, success, output, errors, duration_ms)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `PlanResult` |

#### `PlanError(task_id, message, code, recoverable)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `PlanError` |

#### `ToolDefinition(name, description, category, version, author, permissions, parameters, return_type, timeout_seconds, status, health, metadata)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ToolDefinition` |

#### `ToolParameter(name, type, description, required, default, enum_values)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ToolParameter` |

#### `ToolContext(tool_name, arguments, user_id, org_id, conversation_id, execution_id, permissions, timeout, cancellation_token)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ToolContext` |

#### `ToolResult(success, output, error, execution_time_ms, tool_name, metadata)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ToolResult` |

#### `ToolHealth(status, last_check, response_time_ms, error_count, version)`
| Method | Returns |
|--------|---------|
| `to_json()` | `dict` |
| `from_json(data)` | `ToolHealth` |

### Interfaces

#### `ProviderInterface`
| Method | Signature |
|--------|-----------|
| `chat` | `(messages: list[dict], config: dict\|None) -> AsyncIterator[StreamingChunk]` |
| `complete` | `(prompt: str, config: dict\|None) -> str` |
| `embed` | `(texts: list[str], config: dict\|None) -> list[list[float]]` |
| `generate_tool_call` | `(messages: list[dict], tools: list[dict], config: dict\|None) -> dict` |

---

## Application Layer

#### `ConversationService(provider, memory, event_bus, config)`
| Method | Returns |
|--------|---------|
| `create_conversation(thread_id, system_prompt)` | `str` (conversation ID) |
| `send_message(conversation_id, content)` | `str` (response) |
| `send_message_streaming(conversation_id, content)` | `list[str]` (chunks) |
| `get_history(conversation_id)` | `list[dict]` |
| `context_trimming(conversation_id, max_messages)` | `int` (trimmed count) |
| `memory_injection(conversation_id, query)` | `list[dict]` |

#### `ToolRegistry`
| Method | Returns |
|--------|---------|
| `register(definition, handler)` | `None` |
| `get(name)` | `ToolDefinition` |
| `execute(context)` | `ToolResult` |
| `list_by_category(category)` | `list[ToolDefinition]` |
| `list_all()` | `list[ToolDefinition]` |

#### `AutoationEngine`
| Method | Returns |
|--------|---------|
| `create_workflow(name, steps)` | `Workflow` |
| `get_workflow(workflow_id)` | `Workflow` |
| `execute_workflow(workflow_id, context)` | `WorkflowStatus` |
| `cancel_execution(workflow_id)` | `bool` |
| `schedule_cron(workflow_id, cron_expression)` | `str` (schedule ID) |
| `list_schedules()` | `list[dict]` |

#### `PluginLoader`
| Method | Returns |
|--------|---------|
| `load_manifest(manifest)` | `str` (plugin name) |
| `unload(plugin_name)` | `bool` |
| `list_installed()` | `list[PluginManifest]` |
| `enable(plugin_name)` | `bool` |
| `disable(plugin_name)` | `bool` |
| `get_manifest(plugin_name)` | `PluginManifest\|None` |
| `register_hook(plugin_name, hook_name, handler)` | `None` |
| `get_hooks(hook_name)` | `list[tuple]` |
| `resolve_dependency_chain(plugin_name)` | `list[str]` |

#### `PlanningService`
| Method | Returns |
|--------|---------|
| `decompose_goal(goal)` | `Plan` |
| `resolve_dependencies(graph)` | `list[list[str]]` |
| `detect_cycle(graph)` | `list[str]\|None` |
| `execute_graph_sequential(graph, task_executor)` | `PlanResult` |
| `execute_graph_parallel(graph, task_executor)` | `PlanResult` |
| `rollback_on_failure(graph, task_executor)` | `PlanResult` |

#### `RetryService`
| Method | Returns |
|--------|---------|
| `execute(fn, *args, **kwargs)` | `Any` |

---

## Infrastructure Layer

### Providers

#### `BaseProviderAdapter(config)`
| Method/Property | Returns |
|----------------|---------|
| `_get_client()` | `httpx.AsyncClient` |
| `close()` | `None` |
| `_rate_limit_acquire()` | `None` |
| `_classify_error(response)` | `Exception` |
| `_make_request(method, url, **kwargs)` | `httpx.Response` |
| `_count_tokens(text)` | `int` |

#### `GLMProviderAdapter(config)` (extends `BaseProviderAdapter`)
| Method | Returns |
|--------|---------|
| `chat(messages, config)` | `AsyncIterator[StreamingChunk]` |
| `complete(prompt, config)` | `str` |
| `embed(texts, config)` | `list[list[float]]` |
| `generate_tool_call(messages, tools, config)` | `dict` |

Similar API for all other provider adapters (`OpenAIAdapter`, `AnthropicAdapter`, `GeminiAdapter`, `DeepSeekAdapter`, `GroqAdapter`, `MistralAdapter`, `OllamaAdapter`, `LMStudioAdapter`, `OpenRouterAdapter`, `MockAdapter`).

#### `ProviderFactory`
| Method | Returns |
|--------|---------|
| `create(config)` | `ProviderInterface` |

### Memory

#### `InMemoryMemoryBackend(config)`
| Method | Returns |
|--------|---------|
| `initialize()` | `None` |
| `store(entry)` | `str` |
| `retrieve(entry_id)` | `MemoryEntry\|None` |
| `search(query)` | `MemorySearchResult` |
| `delete(entry_id)` | `bool` |
| `update(entry)` | `bool` |
| `prune(max_entries, max_age_days)` | `int` |
| `count()` | `int` |
| `clear()` | `None` |
| `get_summary(summary_id)` | `MemorySummary\|None` |
| `save_summary(summary)` | `str` |
| `close()` | `None` |

### Event Bus

#### `MockEventBus`
| Method | Returns |
|--------|---------|
| `publish(event_type, data, **kwargs)` | `None` |
| `subscribe(event_type, handler, priority, **kwargs)` | `None` |
| `unsubscribe(event_type, handler)` | `bool` |
| `replay_dead_letter(index)` | `None` |
| `get_published_events(event_type)` | `list[dict]` |
| `get_dead_letter_count()` | `int` |
| `clear()` | `None` |

### Config

#### `MockConfigManager(defaults)`
| Method | Returns |
|--------|---------|
| `get(key, default)` | `Any` |
| `set(key, value)` | `None` |
| `set_encrypted(key, value)` | `None` |
| `is_encrypted(key)` | `bool` |
| `set_env_override(key, value)` | `None` |
| `get_with_override(key, default)` | `Any` |
| `validate(schema)` | `list[str]` |
| `export_config()` | `dict` |
| `import_config(data)` | `None` |
| `load_defaults(defaults)` | `None` |
| `all()` | `dict` |
| `clear()` | `None` |

### Logging

#### `JsonLogger`
| Method | Returns |
|--------|---------|
| `debug(message, **kwargs)` | `None` |
| `info(message, **kwargs)` | `None` |
| `warning(message, **kwargs)` | `None` |
| `error(message, **kwargs)` | `None` |
| `critical(message, **kwargs)` | `None` |
| `set_correlation_id(cid)` | `None` |
| `start_span(span_name, **kwargs)` | `str` (span ID) |
| `end_span(span_id, **kwargs)` | `None` |
| `record_metric(name, value, **kwargs)` | `None` |
| `get_records(level)` | `list[dict]` |
| `clear()` | `None` |
| `get_output()` | `str` |

### Security

#### `PermissionManager`
| Method | Returns |
|--------|---------|
| `add_rule(rule)` | `None` |
| `check_permission(resource_type, resource_id, action, context)` | `PermissionEffect` |
| `get_audit_log()` | `list[dict]` |
| `clear_audit_log()` | `None` |

### Runtime

#### `MockRuntime(config)`
| Method | Returns |
|--------|---------|
| `start()` | `None` |
| `shutdown()` | `None` |
| `hot_reload(new_config)` | `None` |
| `execute_task(task_id, task_data)` | `Any` |
| `cancel_task(task_id)` | `bool` |
| `get_health()` | `dict` |
| `get_task_status(task_id)` | `dict\|None` |
| `get_all_tasks()` | `dict` |
| `close()` | `None` |

### DI Container

#### `DIContainer`
| Method | Returns |
|--------|---------|
| `register(name, implementation, scope, **kwargs)` | `None` |
| `resolve(name, scope_id)` | `Any` |
| `is_registered(name)` | `bool` |
| `clear()` | `None` |
