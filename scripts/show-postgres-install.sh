#!/bin/bash
# Quick helper to show the PostgreSQL MCP Server installation command

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║         PostgreSQL MCP Server - Installation Command            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

📋 COPY THIS COMMAND:

curl -fsSL https://raw.githubusercontent.com/syedmajidraza/registry/main/scripts/install-postgres-mcp.sh | bash

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 After installation, configure your database:

    nano ~/.mcp/servers/mcp-postgres/mcp-server/.env

🚀 Start the server:

    ~/.mcp/servers/mcp-postgres/start.sh

🛑 Stop the server:

    ~/.mcp/servers/mcp-postgres/stop.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Server will run on: http://127.0.0.1:3000
Repository: https://github.com/syedmajidraza/mcp-postgres

EOF
