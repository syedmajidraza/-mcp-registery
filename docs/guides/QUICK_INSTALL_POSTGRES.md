# 🚀 Quick Install: PostgreSQL MCP Server

## Copy and Run This Command

```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash
```

## What Happens Next?

The script will automatically:
- ✅ Check your system (Python 3 & Git required)
- ✅ Download the PostgreSQL MCP Server
- ✅ Set up Python environment
- ✅ Install all dependencies
- ✅ Create start/stop scripts

## After Installation

### Step 1: Configure Database
```bash
nano ~/.mcp/servers/mcp-postgres/mcp-server/.env
```

Update these values:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database
DB_USER=your_username
DB_PASSWORD=your_password
```

### Step 2: Start the Server
```bash
~/.mcp/servers/mcp-postgres/start.sh
```

### Step 3: Stop the Server (when needed)
```bash
~/.mcp/servers/mcp-postgres/stop.sh
```

## Available Commands

Once running on `http://127.0.0.1:3000`, you get access to:

| Tool | Description |
|------|-------------|
| `list_tables` | List all database tables |
| `describe_table` | Get table schema details |
| `query_database` | Run SELECT queries |
| `execute_sql` | Run INSERT/UPDATE/DELETE/CREATE |

---

**Server Location:** `~/.mcp/servers/mcp-postgres`
**Repository:** https://github.com/syedmajidraza/mcp-postgres
