# MCP Server Installer

The MCP Server Installer provides one-click installation of MCP servers directly from the yourcompany MCP Registry web interface.

## Architecture

The installation system consists of two components:

1. **Installer Daemon** (`mcp-installer`) - A local HTTP server that executes npm install commands
2. **Web UI** - Browser interface that communicates with the daemon

```
┌─────────────────┐         HTTP          ┌──────────────────┐
│   Web Browser   │ ◄─────────────────► │ Installer Daemon │
│  (localhost:8080)│      (localhost:3456) │                  │
└─────────────────┘                       └──────────────────┘
                                                    │
                                                    ▼
                                            ┌──────────────┐
                                            │  npm install │
                                            └──────────────┘
```

## Quick Start

### 1. Start the Registry

```bash
docker-compose up -d
```

The registry will be available at [http://localhost:8080](http://localhost:8080)

### 2. Start the Installer Daemon

```bash
make installer
./bin/mcp-installer
```

You should see:
```
MCP Installer Server v1.0.0 starting on port 3456
CORS enabled for all origins
```

Keep this terminal open while using the web interface.

### 3. Install MCP Servers

1. Open [http://localhost:8080](http://localhost:8080) in your browser
2. Browse available MCP servers
3. Click the green **"Install"** button on any server
4. Watch the real-time installation progress
5. When complete, you'll see ✅ "Successfully installed"

## Features

### One-Click Installation
- Click the **"Install"** button to install packages directly to your system
- Real-time progress updates
- Success/failure notifications with detailed error messages

### Copy Command Option
- If you prefer manual installation, use the **"Copy"** button
- Copies the npm install command to your clipboard
- Paste into your terminal to install manually

### Installation Status
Each installation shows real-time status:
- ⏳ "Installing..." - Package is being downloaded and installed
- ✅ "Successfully installed" - Installation completed
- ❌ "Installation failed" - Error occurred (with details)
- ⚠️ "Installer daemon not running" - Daemon needs to be started

## API Reference

### Installer Daemon Endpoints

#### `GET /health`
Check if the installer daemon is running.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

#### `POST /install`
Request package installation.

**Request:**
```json
{
  "packageIdentifier": "mcp-postgres",
  "version": "1.0.0",
  "registryType": "npm"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Installation started",
  "jobId": "job-1234567890"
}
```

#### `GET /status/{jobId}`
Check installation job status.

**Response:**
```json
{
  "jobId": "job-1234567890",
  "status": "completed",
  "message": "Installation successful",
  "output": "npm install output...",
  "startedAt": "2025-12-19T06:00:00Z",
  "updatedAt": "2025-12-19T06:00:15Z"
}
```

**Status values:**
- `pending` - Job queued
- `running` - Installation in progress
- `completed` - Successfully installed
- `failed` - Installation failed

## Security Considerations

### Local-Only Access
The installer daemon:
- Only listens on `localhost:3456` (not accessible remotely)
- Requires local network access to the registry
- Executes npm commands with the user's permissions

### CORS Policy
- Allows requests from any origin (for local development)
- In production, configure stricter CORS policies

### Package Verification
- Packages are installed from the official npm registry
- No verification of package signatures (relies on npm's security)
- Consider using `npm audit` after installation

## Troubleshooting

### Daemon Not Running
**Error:** "⚠️ Installer daemon not running"

**Solution:**
```bash
make installer
./bin/mcp-installer
```

### Port Already in Use
**Error:** "bind: address already in use"

**Solution:**
```bash
# Find process using port 3456
lsof -i :3456

# Kill the process
kill <PID>

# Restart daemon
./bin/mcp-installer
```

### Permission Denied
**Error:** "EACCES: permission denied"

**Solution:**
- Install npm packages globally with proper permissions
- Use `sudo` if required (not recommended)
- Configure npm to use a user-local directory:
  ```bash
  npm config set prefix ~/.npm-global
  export PATH=~/.npm-global/bin:$PATH
  ```

### Installation Timeout
If installation takes longer than 60 seconds:
- Check your internet connection
- Large packages may timeout (increase timeout in UI code)
- Try manual installation with the "Copy" button

## Development

### Building the Installer

```bash
make installer
```

This creates `./bin/mcp-installer`

### Running Tests

```bash
# Test health endpoint
curl http://localhost:3456/health

# Test installation
curl -X POST http://localhost:3456/install \
  -H "Content-Type: application/json" \
  -d '{
    "packageIdentifier": "mcp-postgres",
    "version": "1.0.0",
    "registryType": "npm"
  }'

# Check status
curl http://localhost:3456/status/job-1234567890
```

### Logs

Installer daemon logs to stdout. To save logs:

```bash
./bin/mcp-installer > /tmp/mcp-installer.log 2>&1 &
tail -f /tmp/mcp-installer.log
```

## Future Enhancements

Potential improvements:
- [ ] Support for Python packages (pip)
- [ ] Support for other package managers (cargo, go install)
- [ ] Package update notifications
- [ ] Uninstall functionality
- [ ] Installation queue management
- [ ] Desktop notification integration
- [ ] Auto-start on system boot
- [ ] Package verification and signatures
- [ ] Offline installation support
- [ ] Rate limiting and throttling

## Related Documentation

- [README.md](../README.md) - Main project documentation
- [Quickstart Guide](./modelcontextprotocol-io/quickstart.mdx) - Getting started
- [Architecture Overview](../README.md#architecture) - System design
