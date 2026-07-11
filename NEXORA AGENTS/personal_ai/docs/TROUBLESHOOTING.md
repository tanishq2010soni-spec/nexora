# Troubleshooting Guide

## Common Issues

### "Disconnected" Status

**Issue**: Dashboard shows "Disconnected" with red indicator.

**Solutions**:
1. Verify the backend is running: `python backend/main.py`
2. Check the backend port (default: 8755) is not in use
3. Ensure firewall is not blocking the connection
4. Restart both frontend and backend
5. Check backend logs for startup errors

### Slow Responses

**Issue**: AI responses are slow or timing out.

**Solutions**:
1. Check your internet connection (for cloud models)
2. Reduce context window size in Settings -> Model
3. Try a smaller/faster model (e.g., GPT-3.5-Turbo instead of GPT-4)
4. Check system resources (CPU/RAM usage)
5. Reduce the number of active concurrent tasks

### Memory Not Saving

**Issue**: Conversations or memories are not being persisted.

**Solutions**:
1. Check that the backend storage directory exists and is writable
2. Verify the memory limit hasn't been reached (increase in Settings)
3. Check backend logs for database errors
4. Try restarting the backend service

### Plugin Installation Fails

**Issue**: Plugin fails to install or load.

**Solutions**:
1. Ensure the plugin is a valid `.whl` or `.zip` file
2. Check plugin format matches the required structure (see PLUGINS.md)
3. Verify the plugin is compatible with the current app version
4. Check backend logs for detailed error messages
5. Ensure all plugin dependencies are available

### Character Animation Lag

**Issue**: Character animations are stuttering or slow.

**Solutions**:
1. Reduce animation speed in Character settings
2. Close other resource-intensive applications
3. Update graphics drivers
4. Lower the system's display refresh rate if possible

### Permission Requests Not Showing

**Issue**: Tool permission requests are not appearing.

**Solutions**:
1. Check Permissions screen for pending requests
2. Ensure tools are enabled in Settings -> Tools
3. Restart the chat conversation
4. Verify WebSocket connection is active

### Settings Not Saving

**Issue**: Changes to settings are lost after restart.

**Solutions**:
1. Click "Save All" button in Settings
2. Check file permissions on `~/.nexora/settings.json`
3. Clear app cache and reconfigure
4. Check disk space

## Error Messages

### "Failed to connect to backend"

The frontend cannot reach the backend server.

1. Start the backend: `python backend/main.py`
2. Verify the backend URL in configuration
3. Check for port conflicts

### "Model not available"

The selected AI model is not accessible.

1. Check API keys are configured
2. Verify model name is correct
3. Try switching to a different model
4. For local models, ensure they are downloaded

### "Permission denied"

The AI attempted an action without approval.

1. Check Permissions screen for pending requests
2. Adjust tool permissions in Settings
3. The action was blocked for safety

### "Plugin error: ..."

A plugin encountered an error during execution.

1. Note the error message
2. Try disabling and re-enabling the plugin
3. Reinstall the plugin
4. Contact the plugin author

## Diagnostic Steps

### Check Backend Health

```
curl http://localhost:8755/api/v1/health
```

Expected response: `{"status": "connected", ...}`

### Check WebSocket Connection

Use a WebSocket client to connect:
```
ws://localhost:8755/ws/v1/chat
```

### View Backend Logs

```
tail -f backend/logs/app.log
```

### Reset Configuration

Delete the settings file and restart:
```
rm ~/.nexora/settings.json
```

## Getting Help

If you continue to experience issues:

1. Check the backend logs for detailed error messages
2. Enable debug logging in settings
3. Submit an issue with:
   - App version
   - Backend version
   - Operating system
   - Steps to reproduce
   - Relevant log output
