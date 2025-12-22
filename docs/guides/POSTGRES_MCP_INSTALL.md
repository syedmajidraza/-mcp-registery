# PostgreSQL MCP Server - Manual Installation Guide

## Important Note

The PostgreSQL MCP server at https://github.com/syedmajidraza/mcp-postgres is currently a FastAPI HTTP server and does not follow the standard MCP stdio protocol. This means it cannot be installed using the one-click installer.

## Manual Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/syedmajidraza/mcp-postgres.git
cd mcp-postgres/mcp-server
```

2. Create a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Configure environment variables by copying `.env.example` to `.env`:
```bash
cp .env.example .env
```

5. Edit `.env` and add your PostgreSQL credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database
DB_USER=your_username
DB_PASSWORD=your_password
```

6. Run the server:
```bash
uvicorn server:app --host 127.0.0.1 --port 3000
```

## Converting to a Proper MCP Server

To make this server compatible with the MCP protocol and the one-click installer, you need to:

1. Install the MCP Python SDK:
```bash
pip install mcp
```

2. Replace the FastAPI implementation with MCP's stdio server
3. Use MCP's `@server.list_tools()` and `@server.call_tool()` decorators
4. Communicate via stdio instead of HTTP

Example structure:
```python
from mcp.server import Server
from mcp.server.stdio import stdio_server

app = Server("mcp-postgres")

@app.list_tools()
async def list_tools():
    return [
        {
            "name": "list_tables",
            "description": "List all tables in the PostgreSQL database",
            "inputSchema": {"type": "object", "properties": {}}
        }
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "list_tables":
        # Your implementation here
        pass

if __name__ == "__main__":
    stdio_server(app)
```
