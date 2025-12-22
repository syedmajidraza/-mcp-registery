# PostgreSQL MCP Server - Quick Install Guide

## 🚀 One-Command Installation

Run this single command to automatically install the PostgreSQL MCP Server:

```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash
```

Or download and run locally:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh -o install-postgres-mcp.sh

# Make it executable
chmod +x install-postgres-mcp.sh

# Run the installer
./install-postgres-mcp.sh
```

## What This Does

The installer automatically:
1. ✅ Checks for Python 3 and Git
2. ✅ Creates installation directory at `~/.mcp/servers/mcp-postgres`
3. ✅ Clones the repository
4. ✅ Creates Python virtual environment
5. ✅ Installs all dependencies
6. ✅ Sets up `.env` configuration file
7. ✅ Creates convenient `start.sh` and `stop.sh` scripts

## After Installation

### 1. Configure Database Credentials

Edit the environment file:
```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

Add your PostgreSQL connection details:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_username
DB_PASSWORD=your_password
```

### 2. Start the Server

```bash
~/.mcp/servers/mcp-postgres/start.sh
```

The server will start on `http://127.0.0.1:3000`

### 3. Stop the Server (when needed)

```bash
~/.mcp/servers/mcp-postgres/stop.sh
```

## Available Tools

Once running, the server provides these MCP tools:

- **list_tables** - List all tables in your PostgreSQL database
- **describe_table** - Get detailed schema information for a specific table
- **query_database** - Execute SELECT queries
- **execute_sql** - Execute INSERT, UPDATE, DELETE, and CREATE statements

## Manual Installation

If you prefer to install manually, see [POSTGRES_MCP_INSTALL.md](../POSTGRES_MCP_INSTALL.md)

## Troubleshooting

### Python not found
Install Python 3.8 or higher:
- macOS: `brew install python3`
- Ubuntu/Debian: `sudo apt install python3 python3-venv`
- Windows: Download from [python.org](https://www.python.org/downloads/)

### Port 3000 already in use
Edit the start script and change the port:
```bash
nano ~/.mcp/servers/mcp-postgres/start.sh
# Change --port 3000 to another port like --port 3001
```

### Database connection errors
Verify your `.env` file has correct credentials and that PostgreSQL is running.

## Repository

Source code: [https://github.com/syedmajidraza/mcp-postgres](https://github.com/syedmajidraza/mcp-postgres)
