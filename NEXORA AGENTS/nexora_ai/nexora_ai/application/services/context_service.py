from __future__ import annotations

from nexora_ai.domain.entities.conversation import Message
from nexora_ai.domain.enums.conversation_enums import ContextStrategy


class ContextService:

    def calculate_tokens(self, text: str) -> int:
        return len(text) // 4

    def should_trim(self, messages: list[Message], max_tokens: int) -> bool:
        total = sum(self.calculate_tokens(m.content) for m in messages)
        return total > max_tokens

    def trim_messages(
        self,
        messages: list[Message],
        max_tokens: int,
        strategy: ContextStrategy = ContextStrategy.SLIDING_WINDOW,
    ) -> list[Message]:
        if not self.should_trim(messages, max_tokens):
            return list(messages)
        if strategy == ContextStrategy.SLIDING_WINDOW:
            return self.sliding_window(messages, max_tokens)
        if strategy == ContextStrategy.SUMMARY_COMPRESSION:
            return self.compress_with_summary(messages, max_tokens)
        if strategy == ContextStrategy.SEMANTIC_FILTER:
            return self.semantic_filter(messages, max_tokens)
        return self.sliding_window(messages, max_tokens)

    def sliding_window(self, messages: list[Message], max_tokens: int) -> list[Message]:
        result: list[Message] = []
        total = 0
        for msg in reversed(messages):
            tokens = self.calculate_tokens(msg.content)
            if total + tokens > max_tokens:
                break
            result.insert(0, msg)
            total += tokens
        return result

    async def compress_with_summary(
        self,
        messages: list[Message],
        max_tokens: int,
    ) -> list[Message]:
        if not self.should_trim(messages, max_tokens):
            return list(messages)
        system_messages = [m for m in messages if m.role.value == "system"]
        non_system = [m for m in messages if m.role.value != "system"]
        if not non_system:
            return self.sliding_window(messages, max_tokens)
        summary_text = " ".join(m.content for m in non_system[:-1])
        summary_tokens = self.calculate_tokens(summary_text)
        window = self.sliding_window(non_system[-1:], max_tokens - summary_tokens)
        compressed = list(system_messages) + window
        total = sum(self.calculate_tokens(m.content) for m in compressed)
        if total > max_tokens:
            return self.sliding_window(compressed, max_tokens)
        return compressed

    def semantic_filter(self, messages: list[Message], max_tokens: int) -> list[Message]:
        return self.sliding_window(messages, max_tokens)
