from __future__ import annotations

from typing import Any

import httpx

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission


class HttpTool:
    category = ToolCategory.NETWORK_HTTP
    permissions = [ToolPermission.READ, ToolPermission.WRITE]

    def __init__(self) -> None:
        self._client: httpx.AsyncClient | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                timeout=httpx.Timeout(30.0, connect=10.0),
                follow_redirects=True,
            )
        return self._client

    async def execute(self, parameters: dict[str, Any]) -> dict[str, Any]:
        method = parameters.get("method", "GET").upper()
        url = parameters.get("url", "")
        if not url:
            return {"success": False, "error": "No URL specified"}
        headers = parameters.get("headers", {})
        params = parameters.get("params", {})
        data = parameters.get("data")
        json_data = parameters.get("json")
        auth = parameters.get("auth")
        timeout = parameters.get("timeout", 30.0)

        try:
            client = await self._get_client()
            auth_tuple = None
            if auth:
                auth_tuple = (auth.get("username", ""), auth.get("password", ""))

            kwargs: dict[str, Any] = {
                "url": url,
                "headers": headers,
                "params": params,
            }
            if data is not None:
                kwargs["data"] = data
            if json_data is not None:
                kwargs["json"] = json_data
            if auth_tuple:
                kwargs["auth"] = auth_tuple

            response = await client.request(method, **kwargs)
            content_type = response.headers.get("content-type", "")
            result: dict[str, Any] = {
                "success": response.is_success,
                "status_code": response.status_code,
                "headers": dict(response.headers),
            }
            if "application/json" in content_type:
                result["data"] = response.json()
            else:
                result["data"] = response.text

            return result
        except httpx.TimeoutException:
            return {"success": False, "error": f"Request timed out after {timeout}s"}
        except httpx.HTTPError as exc:
            return {"success": False, "error": str(exc)}
        except Exception as exc:
            return {"success": False, "error": str(exc)}

    async def close(self) -> None:
        if self._client and not self._client.is_closed:
            await self._client.aclose()
