# 🚀 PostgreSQL MCP Server - Complete User Guide

## ✅ Installation Verified & Working!

The installation script has been tested and works perfectly. Here's everything users need:

---

## Step 1: Install (One Command)

Copy and paste this command into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/registry/main/scripts/install-postgres-mcp.sh | bash
```

**Or run locally:**
```bash
/Users/syedraza/registry/scripts/install-postgres-mcp.sh
```

### What Gets Installed
- 📁 Location: `~/.mcp/servers/mcp-postgres`
- 🐍 Python virtual environment with all dependencies
- ⚙️ Configuration file: `.env`
- 🚀 Start script: `start.sh`
- 🛑 Stop script: `stop.sh`

---

## Step 2: Configure Database

Edit the environment file:
```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

Add your PostgreSQL credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_postgres_username
DB_PASSWORD=your_postgres_password

# Optional connection pool settings
DB_MIN_POOL_SIZE=1
DB_MAX_POOL_SIZE=10
```

Save and exit: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 3: Start the Server

```bash
~/.mcp/servers/mcp-postgres/start.sh
```

You'll see:
```
Starting PostgreSQL MCP Server on http://127.0.0.1:3000
Press Ctrl+C to stop the server
```

---

## Step 4: Use the Server

The server is now running on `http://127.0.0.1:3000` with these tools:

### Available Tools

| Tool | Description | Example |
|------|-------------|---------|
| `list_tables` | List all database tables | Lists all tables in your DB |
| `describe_table` | Get table schema | Shows columns, types, constraints |
| `query_database` | Run SELECT queries | Execute read-only queries |
| `execute_sql` | Run INSERT/UPDATE/DELETE/CREATE | Execute write operations |

---

## Step 5: Stop the Server

When you're done, stop the server:
```bash
~/.mcp/servers/mcp-postgres/stop.sh
```

Or press `Ctrl+C` in the terminal where it's running.

---

## 📋 Quick Reference

### Installation Directory
```bash
cd ~/.mcp/servers/mcp-postgres
```

### View Logs
The server outputs logs to the terminal where `start.sh` is running.

### Reinstall/Update
Just run the installer again - it will pull latest changes:
```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/registry/main/scripts/install-postgres-mcp.sh | bash
```

### Uninstall
```bash
rm -rf ~/.mcp/servers/mcp-postgres
```

---

## 🔧 Troubleshooting

### "Python 3 not found"
Install Python 3.8+:
- **macOS**: `brew install python3`
- **Ubuntu**: `sudo apt install python3 python3-venv`
- **Windows**: Download from [python.org](https://python.org)

### "Git not found"
Install Git:
- **macOS**: `brew install git` or `xcode-select --install`
- **Ubuntu**: `sudo apt install git`
- **Windows**: Download from [git-scm.com](https://git-scm.com)

### "Port 3000 already in use"
Edit the start script to use a different port:
```bash
nano ~/.mcp/servers/mcp-postgres/start.sh
# Change --port 3000 to --port 3001
```

### "Database connection failed"
- Verify PostgreSQL is running
- Check credentials in `.env` file
- Ensure database exists: `createdb your_database_name`
- Test connection: `psql -h localhost -U your_user -d your_database`

### "Virtual environment not activated"
The start script handles this automatically. If running manually:
```bash
cd ~/.mcp/servers/mcp-postgres/mcp-server
source venv/bin/activate
uvicorn server:app --host 127.0.0.1 --port 3000
```

---

## 📚 Additional Resources

- **Repository**: https://github.com/syedmajidraza/mcp-postgres
- **Registry**: http://localhost:9090
- **Issues**: Report bugs on GitHub

---

## 🎯 Summary

**Install**: `curl -fsSL https://raw.githubusercontent.com/syedmajidraza/registry/main/scripts/install-postgres-mcp.sh | bash`

**Configure**: `nano ~/.mcp/servers/mcp-postgres/mcp-server/.env`

**Start**: `~/.mcp/servers/mcp-postgres/start.sh`

**Stop**: `~/.mcp/servers/mcp-postgres/stop.sh`

That's it! 🎉
