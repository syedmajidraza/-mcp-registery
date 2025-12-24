# PostgreSQL MCP Server - Complete Guide

**Version:** 1.0.0
**Last Updated:** December 24, 2024

A comprehensive guide for installing, configuring, and using the PostgreSQL MCP Server from the Syed MCP Registry.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Method 1: Quick Install (Recommended)](#method-1-quick-install-recommended)
  - [Method 2: Fresh Install](#method-2-fresh-install)
  - [Method 3: Terminal Installation](#method-3-terminal-installation)
- [Configuration](#configuration)
- [Starting the Server](#starting-the-server)
- [Stopping the Server](#stopping-the-server)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [Advanced](#advanced)

---

## Overview

The PostgreSQL MCP Server is a Python-based Model Context Protocol (MCP) server that provides:

- Database schema inspection
- SQL query execution
- Table management capabilities
- Interactive database credential setup
- Automatic environment configuration

**Repository:** [https://github.com/syedmajidraza/mcp-postgres](https://github.com/syedmajidraza/mcp-postgres)
**Registry:** [http://localhost:9090](http://localhost:9090)
**Server Port:** http://127.0.0.1:3000

---

## Features

✅ **Interactive Setup** - Prompts for database credentials on first start
✅ **Sparse Checkout** - Only downloads necessary files (mcp-server subdirectory)
✅ **Auto Configuration** - Creates `.env` file automatically
✅ **Force Reinstall** - `--force` flag for clean reinstallation
✅ **Easy Updates** - Simple update process for existing installations
✅ **Wrapper Scripts** - Convenient start/stop scripts at multiple locations

---

## Prerequisites

Before installing the PostgreSQL MCP Server, ensure you have:

- **Python 3.8+** installed
  ```bash
  python3 --version
  ```

- **Git** installed
  ```bash
  git --version
  ```

- **PostgreSQL database** (running and accessible)
  - Host (default: localhost)
  - Port (default: 5432)
  - Database name
  - Username
  - Password

---

## Installation

### Method 1: Quick Install (Recommended)

**From the Registry UI:**

1. Visit [http://localhost:9090](http://localhost:9090)
2. Find **PostgreSQL MCP Server** (`io.github.syedmajidraza/mcp-postgres`)
3. Click **⚡ Install / Update** button
4. Command is copied to clipboard automatically
5. Open your terminal
6. Paste and press Enter

**What it does:**
- First-time installation: Installs fresh
- Existing installation: Updates to latest version
- Preserves existing configuration

---

### Method 2: Fresh Install

Use this when you want to completely remove and reinstall:

**From the Registry UI:**

1. Visit [http://localhost:9090](http://localhost:9090)
2. Find **PostgreSQL MCP Server**
3. Click **🔄 Fresh Install** button (orange)
4. Read the warning about complete removal
5. Command is copied to clipboard
6. Paste in terminal and run

**What it does:**
- Removes existing installation completely
- Deletes all configuration
- Performs clean reinstallation
- Prompts for new credentials

---

### Method 3: Terminal Installation

**Normal Install/Update:**
```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash
```

**Fresh Install (Force):**
```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash -s -- --force
```

**What happens during installation:**

```
[1/6] Checking prerequisites...
[2/6] Creating installation directory...
[3/6] Cloning mcp-server from repository...
[4/6] Creating Python virtual environment...
[5/6] Installing Python dependencies...
[6/6] Setting up environment configuration...
```

**Installation Location:**
```
~/.mcp/servers/mcp-postgres/
├── start.sh              # Wrapper script (shortcut)
├── stop.sh               # Wrapper script (shortcut)
└── mcp-server/
    ├── server.py         # Main server
    ├── config.py         # Configuration
    ├── requirements.txt  # Dependencies
    ├── .env             # Your credentials (created on first start)
    ├── start.sh         # Start script
    ├── stop.sh          # Stop script
    └── venv/            # Python virtual environment
```

---

## Configuration

### Interactive Setup (First Start)

On first start, you'll be prompted for database credentials:

```
========================================
PostgreSQL MCP Server - First Time Setup
========================================

Please enter your PostgreSQL database credentials:

Database Host [localhost]:
Database Port [5432]:
Database Name:
Database User [postgres]:
Database Password:
```

**Required Fields:**
- Database Name (no default)
- Database Password (no default)

**Optional Fields (with defaults):**
- Database Host: `localhost`
- Database Port: `5432`
- Database User: `postgres`

### Manual Configuration

To change database settings after installation:

```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

**Example `.env` file:**
```env
# PostgreSQL Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=postgres
DB_PASSWORD=mypassword

# Server Configuration
SERVER_HOST=127.0.0.1
SERVER_PORT=3000
```

**After editing, restart the server for changes to take effect.**

---

## Starting the Server

### Option 1: Short Path (Recommended)
```bash
~/.mcp/servers/mcp-postgres/start.sh
```

### Option 2: Full Path
```bash
~/.mcp/servers/mcp-postgres/mcp-server/start.sh
```

**Expected Output:**
```
Starting PostgreSQL MCP Server on http://127.0.0.1:3000
Press Ctrl+C to stop the server

INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:3000 (Press CTRL+C to quit)
```

**Server is now running at:** http://127.0.0.1:3000

---

## Stopping the Server

### Option 1: Using Stop Script
```bash
~/.mcp/servers/mcp-postgres/stop.sh
```

**Output:**
```
Server stopped (PID: 12345)
```

### Option 2: In Terminal (Ctrl+C)
If server is running in foreground, press `Ctrl+C`

### Option 3: Kill by Port
```bash
lsof -ti:3000 | xargs kill
```

### Option 4: Find and Kill Process
```bash
ps aux | grep uvicorn
kill <PID>
```

---

## Usage Examples

### Check Available Tools

```bash
curl http://localhost:3000/mcp/v1/tools | jq '.'
```

**Available Tools:**
- `query_database` - Execute SELECT queries
- `execute_sql` - Execute SQL statements (INSERT, UPDATE, DELETE, CREATE TABLE)
- `create_table` - Create new tables
- `create_stored_procedure` - Create stored procedures/functions
- `list_tables` - List all tables in schema
- `describe_table` - Get table structure
- `get_table_indexes` - Get table indexes
- `analyze_query_plan` - Get query execution plan

### List Tables

```bash
curl -X POST http://localhost:3000/mcp/v1/tools/call \
  -H "Content-Type: application/json" \
  -d '{
    "name": "list_tables",
    "arguments": {
      "schema": "public"
    }
  }' | jq '.'
```

**Response:**
```json
{
  "result": {
    "schema": "public",
    "tables": [
      {
        "table_name": "users",
        "table_type": "BASE TABLE"
      },
      {
        "table_name": "products",
        "table_type": "BASE TABLE"
      }
    ],
    "count": 2
  }
}
```

### Execute Query

```bash
curl -X POST http://localhost:3000/mcp/v1/tools/call \
  -H "Content-Type: application/json" \
  -d '{
    "name": "query_database",
    "arguments": {
      "query": "SELECT * FROM users LIMIT 5"
    }
  }' | jq '.'
```

### Describe Table

```bash
curl -X POST http://localhost:3000/mcp/v1/tools/call \
  -H "Content-Type: application/json" \
  -d '{
    "name": "describe_table",
    "arguments": {
      "table_name": "users"
    }
  }' | jq '.'
```

---

## Troubleshooting

### Database Connection Error

**Error:** `❌ Failed to connect to database`

**Solution:**
1. Check if PostgreSQL is running:
   ```bash
   lsof -ti:5432
   ```

2. Verify database exists:
   ```bash
   psql -U postgres -l
   ```

3. Check credentials in `.env` file:
   ```bash
   cat ~/.mcp/servers/mcp-postgres/mcp-server/.env
   ```

4. Test connection manually:
   ```bash
   psql -h localhost -p 5432 -U postgres -d mydb
   ```

### Database Name Case Sensitivity

PostgreSQL database names are case-sensitive. If you see:
```
database "MyDB" does not exist
```

Check actual database name:
```bash
psql -U postgres -l
```

Update `.env` with exact name (e.g., `mydb` not `MyDB`)

### Port Already in Use

**Error:** `Address already in use: 3000`

**Solution:**
```bash
# Stop existing server
~/.mcp/servers/mcp-postgres/stop.sh

# Or kill process on port 3000
lsof -ti:3000 | xargs kill
```

### Installation Failed - Prerequisites

Ensure Python and Git are installed:
```bash
python3 --version  # Should show 3.8+
git --version      # Should show git version
```

### Server Won't Start

1. Check if virtual environment exists:
   ```bash
   ls ~/.mcp/servers/mcp-postgres/mcp-server/venv/
   ```

2. Reinstall dependencies:
   ```bash
   cd ~/.mcp/servers/mcp-postgres/mcp-server
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. Check `.env` file exists:
   ```bash
   cat ~/.mcp/servers/mcp-postgres/mcp-server/.env
   ```

---

## Uninstall

To completely remove the PostgreSQL MCP Server:

```bash
rm -rf ~/.mcp/servers/mcp-postgres
```

**This will delete:**
- All server files
- Virtual environment
- Configuration (`.env`)
- Start/stop scripts

---

## Advanced

### Update to Latest Version

```bash
cd ~/.mcp/servers/mcp-postgres/mcp-server
git pull origin main
pip install -r requirements.txt
```

### Change Server Port

Edit configuration:
```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

Change:
```env
SERVER_PORT=3001  # Instead of 3000
```

Update `start.sh`:
```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/start.sh
```

Change last line:
```bash
uvicorn server:app --host 127.0.0.1 --port 3001
```

### Run in Background

```bash
nohup ~/.mcp/servers/mcp-postgres/mcp-server/start.sh > /tmp/mcp-server.log 2>&1 &
```

View logs:
```bash
tail -f /tmp/mcp-server.log
```

### Connect to Different Database

You can switch databases by:

1. **Option 1:** Edit `.env` file
   ```bash
   nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
   ```
   Change `DB_NAME` value

2. **Option 2:** Delete `.env` and restart
   ```bash
   rm ~/.mcp/servers/mcp-postgres/mcp-server/.env
   ~/.mcp/servers/mcp-postgres/start.sh
   ```
   You'll be prompted for new credentials

### Installation Script Flags

The installation script supports the following flag:

**`--force` or `-f`**
- Removes existing installation completely
- Performs fresh reinstallation
- Deletes all configuration

Usage:
```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash -s -- --force
```

---

## Summary of Commands

### Installation
```bash
# Normal install/update
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash

# Fresh install
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash -s -- --force
```

### Server Control
```bash
# Start server
~/.mcp/servers/mcp-postgres/start.sh

# Stop server
~/.mcp/servers/mcp-postgres/stop.sh
```

### Configuration
```bash
# Edit configuration
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env

# Reset configuration (delete .env and restart to re-prompt)
rm ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

### Maintenance
```bash
# Update to latest
cd ~/.mcp/servers/mcp-postgres/mcp-server && git pull origin main

# Uninstall completely
rm -rf ~/.mcp/servers/mcp-postgres
```

---

## Support

- **Repository Issues:** [https://github.com/syedmajidraza/mcp-postgres/issues](https://github.com/syedmajidraza/mcp-postgres/issues)
- **Registry Issues:** [https://github.com/syedmajidraza/-mcp-registery/issues](https://github.com/syedmajidraza/-mcp-registery/issues)
- **Registry UI:** [http://localhost:9090](http://localhost:9090)

---

## License

See the repository for license information.

---

**Last Updated:** December 24, 2024
**Document Version:** 1.0.0
