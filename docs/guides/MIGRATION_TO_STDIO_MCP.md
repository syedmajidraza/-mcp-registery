# 🔄 Migration Guide: FastAPI to stdio-based MCP Server

## 📋 Overview

Your current PostgreSQL MCP Server uses **FastAPI with HTTP/JSON endpoints**. While this works, the standard MCP protocol uses **stdio (standard input/output)** for communication.

This guide explains:
1. Why migrate to stdio
2. Recommended changes
3. Step-by-step migration process
4. Code examples
5. Benefits and considerations

---

## 🤔 Why Migrate to stdio?

### Current Setup (FastAPI/HTTP)
- ✅ Works with HTTP clients
- ✅ Easy to test with curl
- ✅ Web-based API
- ❌ Not compatible with standard MCP clients (Claude Desktop, etc.)
- ❌ Requires server to be running on a port
- ❌ Manual installation process

### Standard MCP (stdio)
- ✅ Compatible with all MCP clients
- ✅ One-click installation in Claude Desktop
- ✅ No port conflicts
- ✅ Automatic process management
- ✅ Standard MCP protocol compliance
- ✅ Better integration with MCP ecosystem

---

## 🎯 Recommended Changes

### 1. Replace FastAPI with MCP Python SDK

**Current** (FastAPI):
```python
from fastapi import FastAPI
app = FastAPI(title="PostgreSQL MCP Server")

@app.get("/mcp/v1/tools")
async def list_tools():
    return {"tools": [...]}
```

**Recommended** (MCP SDK):
```python
from mcp.server import Server
from mcp.server.stdio import stdio_server

app = Server("mcp-postgres")

@app.list_tools()
async def list_tools():
    return [...]
```

### 2. Change Communication Method

**Current**: HTTP endpoints on port 3000

**Recommended**: stdio (standard input/output)

### 3. Update Installation Method

**Current**: Run as a background service

**Recommended**: MCP clients manage the process automatically

---

## 📦 Step-by-Step Migration

### Step 1: Install MCP Python SDK

Update `requirements.txt`:

**Before**:
```txt
fastapi==0.115.0
uvicorn[standard]==0.32.0
asyncpg==0.29.0
pydantic==2.9.2
python-dotenv==1.0.1
```

**After**:
```txt
mcp==1.0.0
asyncpg==0.29.0
python-dotenv==1.0.1
```

Install new dependencies:
```bash
cd ~/.mcp/servers/mcp-postgres/mcp-server
source venv/bin/activate
pip install mcp
pip uninstall fastapi uvicorn -y
```

---

### Step 2: Rewrite server.py

Create a new `server.py` using the MCP SDK:

```python
"""
PostgreSQL MCP Server (stdio-based)
Provides tools for database operations through the Model Context Protocol
"""

import asyncpg
import os
from typing import Any
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Create MCP server
app = Server("mcp-postgres")

# Database connection pool
db_pool: asyncpg.Pool | None = None


# Lifecycle management
@app.server_started()
async def on_server_started():
    """Initialize database connection pool when server starts"""
    global db_pool
    try:
        db_pool = await asyncpg.create_pool(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", "5432")),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            min_size=2,
            max_size=10
        )
        print(f"✅ Connected to PostgreSQL: {os.getenv('DB_NAME')}", flush=True)
    except Exception as e:
        print(f"❌ Database connection failed: {e}", flush=True)
        db_pool = None


@app.server_stopped()
async def on_server_stopped():
    """Close database connection pool when server stops"""
    global db_pool
    if db_pool:
        await db_pool.close()
        print("Database connection pool closed", flush=True)


# Define MCP tools
@app.list_tools()
async def list_tools() -> list[Tool]:
    """List all available MCP tools"""
    return [
        Tool(
            name="list_tables",
            description="List all tables in the current database schema",
            inputSchema={
                "type": "object",
                "properties": {
                    "schema": {
                        "type": "string",
                        "description": "Schema name (default: 'public')"
                    }
                }
            }
        ),
        Tool(
            name="describe_table",
            description="Get the structure/schema of a specific table including columns, types, and constraints",
            inputSchema={
                "type": "object",
                "properties": {
                    "table_name": {
                        "type": "string",
                        "description": "Name of the table to describe"
                    }
                },
                "required": ["table_name"]
            }
        ),
        Tool(
            name="query_database",
            description="Execute a SELECT query on the PostgreSQL database. Returns query results as a list of rows.",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "The SQL SELECT query to execute"
                    }
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="execute_sql",
            description="Execute a SQL statement (INSERT, UPDATE, DELETE, CREATE TABLE, etc.)",
            inputSchema={
                "type": "object",
                "properties": {
                    "sql": {
                        "type": "string",
                        "description": "The SQL statement to execute"
                    }
                },
                "required": ["sql"]
            }
        ),
        Tool(
            name="get_table_indexes",
            description="Get all indexes for a specific table",
            inputSchema={
                "type": "object",
                "properties": {
                    "table_name": {
                        "type": "string",
                        "description": "Name of the table"
                    }
                },
                "required": ["table_name"]
            }
        ),
    ]


# Tool implementations
@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Execute MCP tool calls"""
    if not db_pool:
        return [TextContent(
            type="text",
            text="Error: Database connection not available"
        )]

    try:
        async with db_pool.acquire() as conn:
            if name == "list_tables":
                schema = arguments.get("schema", "public")
                query = """
                    SELECT table_name, table_type
                    FROM information_schema.tables
                    WHERE table_schema = $1
                    ORDER BY table_name
                """
                rows = await conn.fetch(query, schema)
                tables = [dict(row) for row in rows]

                return [TextContent(
                    type="text",
                    text=f"Found {len(tables)} tables in schema '{schema}':\n" +
                         "\n".join([f"- {t['table_name']} ({t['table_type']})" for t in tables])
                )]

            elif name == "describe_table":
                table_name = arguments["table_name"]
                query = """
                    SELECT column_name, data_type, character_maximum_length,
                           is_nullable, column_default
                    FROM information_schema.columns
                    WHERE table_name = $1
                    ORDER BY ordinal_position
                """
                rows = await conn.fetch(query, table_name)

                if not rows:
                    return [TextContent(
                        type="text",
                        text=f"Table '{table_name}' not found"
                    )]

                columns_text = f"Table: {table_name}\nColumns ({len(rows)}):\n\n"
                for row in rows:
                    col_type = row['data_type']
                    if row['character_maximum_length']:
                        col_type += f"({row['character_maximum_length']})"
                    nullable = "NULL" if row['is_nullable'] == 'YES' else "NOT NULL"
                    default = f" DEFAULT {row['column_default']}" if row['column_default'] else ""
                    columns_text += f"  {row['column_name']}: {col_type} {nullable}{default}\n"

                return [TextContent(type="text", text=columns_text)]

            elif name == "query_database":
                query = arguments["query"]

                # Security: Only allow SELECT queries
                if not query.strip().upper().startswith("SELECT"):
                    return [TextContent(
                        type="text",
                        text="Error: Only SELECT queries are allowed. Use execute_sql for other operations."
                    )]

                rows = await conn.fetch(query)

                if not rows:
                    return [TextContent(
                        type="text",
                        text="Query returned no results"
                    )]

                # Format results as text
                result_text = f"Query returned {len(rows)} row(s):\n\n"
                for i, row in enumerate(rows[:100], 1):  # Limit to first 100 rows
                    result_text += f"Row {i}:\n"
                    for key, value in dict(row).items():
                        result_text += f"  {key}: {value}\n"
                    result_text += "\n"

                if len(rows) > 100:
                    result_text += f"(Showing first 100 of {len(rows)} rows)\n"

                return [TextContent(type="text", text=result_text)]

            elif name == "execute_sql":
                sql = arguments["sql"]
                result = await conn.execute(sql)

                return [TextContent(
                    type="text",
                    text=f"SQL executed successfully: {result}"
                )]

            elif name == "get_table_indexes":
                table_name = arguments["table_name"]
                query = """
                    SELECT indexname, indexdef
                    FROM pg_indexes
                    WHERE tablename = $1
                """
                rows = await conn.fetch(query, table_name)

                if not rows:
                    return [TextContent(
                        type="text",
                        text=f"No indexes found for table '{table_name}'"
                    )]

                indexes_text = f"Indexes for table '{table_name}':\n\n"
                for row in rows:
                    indexes_text += f"- {row['indexname']}:\n  {row['indexdef']}\n\n"

                return [TextContent(type="text", text=indexes_text)]

            else:
                return [TextContent(
                    type="text",
                    text=f"Unknown tool: {name}"
                )]

    except Exception as e:
        return [TextContent(
            type="text",
            text=f"Error executing {name}: {str(e)}"
        )]


# Run server
if __name__ == "__main__":
    stdio_server(app)
```

---

### Step 3: Update server.json for MCP Clients

Create `server.json` in the repository root:

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json",
  "name": "io.github.syedmajidraza/mcp-postgres",
  "description": "PostgreSQL MCP Server - Query and manage PostgreSQL databases with MCP tools",
  "repository": {
    "url": "https://github.com/syedmajidraza/mcp-postgres",
    "source": "github"
  },
  "version": "1.0.0",
  "packages": [
    {
      "registryType": "pypi",
      "identifier": "mcp-postgres",
      "version": "1.0.0",
      "transport": {
        "type": "stdio"
      },
      "environmentVariables": [
        {
          "name": "DB_HOST",
          "isRequired": true,
          "description": "PostgreSQL database host"
        },
        {
          "name": "DB_PORT",
          "default": "5432",
          "description": "PostgreSQL database port"
        },
        {
          "name": "DB_NAME",
          "isRequired": true,
          "description": "PostgreSQL database name"
        },
        {
          "name": "DB_USER",
          "isRequired": true,
          "description": "PostgreSQL database user"
        },
        {
          "name": "DB_PASSWORD",
          "isRequired": true,
          "isSecret": true,
          "description": "PostgreSQL database password"
        }
      ]
    }
  ],
  "tools": [
    {
      "name": "list_tables",
      "description": "List all tables in the database"
    },
    {
      "name": "describe_table",
      "description": "Get table schema information"
    },
    {
      "name": "query_database",
      "description": "Execute SELECT queries"
    },
    {
      "name": "execute_sql",
      "description": "Execute INSERT/UPDATE/DELETE/CREATE statements"
    },
    {
      "name": "get_table_indexes",
      "description": "View table indexes"
    }
  ]
}
```

---

### Step 4: Update Claude Desktop Configuration

Users will add to their `claude_desktop_config.json`:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "postgres": {
      "command": "python",
      "args": [
        "-m",
        "venv",
        "/Users/username/.mcp/servers/mcp-postgres/mcp-server/venv/bin/activate",
        "&&",
        "python",
        "/Users/username/.mcp/servers/mcp-postgres/mcp-server/server.py"
      ],
      "env": {
        "DB_HOST": "localhost",
        "DB_PORT": "5432",
        "DB_NAME": "your_database",
        "DB_USER": "your_user",
        "DB_PASSWORD": "your_password"
      }
    }
  }
}
```

---

### Step 5: Test the stdio Server

```bash
# Run server in stdio mode
cd ~/.mcp/servers/mcp-postgres/mcp-server
source venv/bin/activate
python server.py

# Server now reads from stdin and writes to stdout
# It will wait for MCP protocol messages
```

Test with echo:
```bash
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | python server.py
```

---

## 🔄 Comparison: Before vs After

| Aspect | FastAPI (Current) | stdio MCP (Recommended) |
|--------|-------------------|-------------------------|
| **Protocol** | HTTP/JSON | MCP stdio |
| **Port Required** | Yes (3000) | No |
| **Compatible with Claude Desktop** | No | Yes ✅ |
| **Installation** | Custom script | Standard MCP install |
| **Process Management** | Manual start/stop | Automatic by MCP client |
| **Testing** | curl/HTTP client | MCP client tools |
| **Dependencies** | FastAPI, uvicorn, pydantic | mcp SDK only |
| **Communication** | REST API | Standard I/O |
| **Registry Compatibility** | Custom handling | Full support ✅ |

---

## 📝 Updated Installation for stdio Version

### For Developers (after migration)

**Option 1: Direct installation (recommended)**
```bash
pip install mcp-postgres
```

**Option 2: From source**
```bash
git clone https://github.com/syedmajidraza/mcp-postgres.git
cd mcp-postgres/mcp-server
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Claude Desktop Integration

After installation, add to Claude Desktop config and restart Claude.

---

## ✅ Benefits of Migration

### For Users
1. ✅ **One-click installation** in Claude Desktop
2. ✅ **No manual server management** required
3. ✅ **Automatic process lifecycle** handling
4. ✅ **Standard MCP experience** like other servers
5. ✅ **No port conflicts** or networking issues

### For Developers
1. ✅ **Simpler codebase** (no HTTP layer needed)
2. ✅ **Standard MCP patterns** easier to maintain
3. ✅ **Better debugging** with MCP client tools
4. ✅ **Wider compatibility** with MCP ecosystem
5. ✅ **Less dependencies** to manage

---

## ⚠️ Migration Considerations

### What You'll Lose
- ❌ Web-based API (no more curl testing)
- ❌ Swagger/OpenAPI documentation
- ❌ Independent HTTP server
- ❌ REST endpoint accessibility

### What You'll Gain
- ✅ Full MCP protocol compliance
- ✅ Claude Desktop integration
- ✅ Automatic process management
- ✅ Standard MCP client compatibility
- ✅ Simplified deployment

---

## 🚀 Recommended Migration Path

### Phase 1: Preparation (1-2 hours)
1. Read MCP documentation: https://modelcontextprotocol.io
2. Study MCP Python SDK examples
3. Test stdio communication locally

### Phase 2: Code Migration (2-4 hours)
1. Install MCP SDK
2. Rewrite server.py using MCP patterns
3. Remove FastAPI dependencies
4. Update requirements.txt
5. Create server.json

### Phase 3: Testing (1-2 hours)
1. Test stdio communication
2. Verify all tools work
3. Test with Claude Desktop
4. Check error handling

### Phase 4: Documentation (1 hour)
1. Update README.md
2. Add Claude Desktop setup instructions
3. Update installation guide
4. Remove HTTP-specific docs

### Phase 5: Deployment
1. Publish to PyPI (optional)
2. Update registry entry
3. Tag new version in git
4. Announce migration to users

---

## 📚 Resources

### Official Documentation
- **MCP Protocol**: https://modelcontextprotocol.io
- **MCP Python SDK**: https://github.com/modelcontextprotocol/python-sdk
- **Server Schema**: https://github.com/modelcontextprotocol/registry/docs/reference/server-json

### Example Repositories
- **MCP Servers**: https://github.com/modelcontextprotocol/servers
- **Python Examples**: https://github.com/modelcontextprotocol/python-sdk/tree/main/examples

### Testing Tools
- **MCP Inspector**: For testing stdio servers
- **Claude Desktop**: For integration testing

---

## 💡 Quick Decision Guide

### Stick with FastAPI if:
- ❓ You need a web-accessible API
- ❓ You want REST endpoint compatibility
- ❓ You have existing HTTP-based integrations
- ❓ You need Swagger documentation

### Migrate to stdio if:
- ✅ You want Claude Desktop integration
- ✅ You want standard MCP compliance
- ✅ You want easier deployment
- ✅ You want to reach MCP ecosystem users
- ✅ **Recommended for most use cases**

---

## 🎯 Conclusion

**Recommendation**: **Migrate to stdio-based MCP server**

### Why?
1. Standard MCP protocol compliance
2. Better user experience (one-click install)
3. Claude Desktop integration
4. Simpler architecture
5. Wider compatibility

### Timeline
**Total estimated time**: 5-9 hours including testing

### Priority
**High** - If you want to serve MCP clients (Claude Desktop, etc.)
**Low** - If you only need HTTP API functionality

---

**Next Steps**: Choose your path and start with Phase 1 preparation!

**Questions?** Check the MCP documentation or open an issue in the repository.
