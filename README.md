
# Syed MCP Registry

A local, isolated MCP registry that provides MCP clients with a curated list of MCP servers, featuring the **PostgreSQL MCP Server** with automated installation.

📚 [**Developer Guide**](DEVELOPER_GUIDE.md) | [**Quick Start**](QUICK_START.md) | [**PostgreSQL Server Guide**](docs/guides/USER_GUIDE.md) | 📖 **[Full Documentation](docs/guides/DOCUMENTATION_INDEX.md)**

---

## 🚀 Featured: PostgreSQL MCP Server

### One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/syedmajidraza/registry/main/scripts/install-postgres-mcp.sh | bash
```

**After install**: Configure `.env` → Start server → Access at `http://127.0.0.1:3000`

📖 **[Complete Guide →](docs/guides/USER_GUIDE.md)** | **[All Docs →](docs/guides/DOCUMENTATION_INDEX.md)**

---

## Project Status

**2025-12-22 update:**
- 🟢 **PostgreSQL MCP Server** integrated with automated installation
- 📋 **Copy button UI** in registry for easy installation
- 📚 **Complete documentation** (11 comprehensive guides)
- 🛠️ **5 MCP servers** listed in registry
- 🏠 **Local-only registry** - no remote aggregation
- 🐳 **Docker Compose** setup with clean, isolated environment


## Quick Start


### Prerequisites

- **Docker**
- **Go 1.24.x**


#### Running the server

```bash
# Start the local Syed MCP Registry environment
docker-compose up --build -d
```

This starts the registry at [`localhost:9090`](http://localhost:9090) with PostgreSQL. The database uses ephemeral storage and is reset each time you restart the containers, ensuring a clean state for development and testing. The registry loads 5 MCP servers defined in `data/seed.json` and does not aggregate from any remote sources.

Configuration is managed via [docker-compose.yml](./docker-compose.yml). The default database name is now `mcp-registry-test` for a clean, isolated state.


<!--
## Screenshot
No screenshot is currently included. Add a screenshot of the Syed MCP Registry UI here if desired.
-->


## Installing MCP Servers

The registry includes a one-click installer for easy local installation of MCP servers.

### Option 1: One-Click Installation (Recommended)

1. Start the installer daemon:
```bash
make installer
./bin/mcp-installer
```

2. Open [http://localhost:9090](http://localhost:9090) in your browser
3. Click the green **"Install"** button on any server
4. Watch real-time installation progress

See [the installer guide](./docs/INSTALLER.md) for complete documentation.

### Option 2: Manual Installation

Click the **"Copy"** button on any server to copy the npm install command, then paste it into your terminal.


## Publishing a Server

To publish a server, use the CLI:

```bash
make publisher
./bin/mcp-publisher --help
```

See [the publisher guide](./docs/modelcontextprotocol-io/quickstart.mdx) for more details.


## Other Commands

```bash
# Run lint, unit tests, and integration tests
make check
```

Run `make help` to see all available commands.


## Architecture

### Project Structure

```
├── cmd/                     # Application entry points
│   ├── installer/           # Local installation daemon
│   ├── publisher/           # Server publishing tool
│   └── registry/            # Main registry server
├── data/                    # Seed data
├── deploy/                  # Deployment configuration (Pulumi)
├── docs/                    # Documentation
├── internal/                # Private application code
│   ├── api/                 # HTTP handlers and routing
│   ├── auth/                # Authentication (GitHub OAuth, JWT, namespace blocking)
│   ├── config/              # Configuration management
│   ├── database/            # Data persistence (PostgreSQL)
│   ├── service/             # Business logic
│   ├── telemetry/           # Metrics and monitoring
│   └── validators/          # Input validation
├── pkg/                     # Public packages
│   ├── api/                 # API types and structures
│   │   └── v0/              # Version 0 API types
│   └── model/               # Data models for server.json
├── scripts/                 # Development and testing scripts
├── tests/                   # Integration tests
└── tools/                   # CLI tools and utilities
    └── validate-*.sh        # Schema validation tools
```


### Authentication

Publishing supports multiple authentication methods:
- **GitHub OAuth**
- **GitHub OIDC**
- **DNS verification**
- **HTTP verification**

The registry validates namespace ownership when publishing. For example:
- To publish `ai.alpic.test/test-mcp-server`, you must prove ownership of the relevant namespace.


## 📚 Complete Documentation

### PostgreSQL MCP Server Guides

| Guide | Description | Best For |
|-------|-------------|----------|
| [📑 Documentation Index](docs/guides/DOCUMENTATION_INDEX.md) | Master navigation for all docs | Finding any documentation |
| [📖 Working Setup](docs/guides/WORKING_SETUP.md) | Current setup reference | Operating the server |
| [🔄 Migration Guide](docs/guides/MIGRATION_TO_STDIO_MCP.md) | Convert to stdio MCP | Upgrading to standard protocol |
| [👤 User Guide](docs/guides/USER_GUIDE.md) | Installation and usage | End users |
| [⚡ Quick Install](docs/guides/QUICK_INSTALL_POSTGRES.md) | One-command setup | Fast installation |
| [📊 Final Summary](docs/guides/FINAL_SUMMARY.md) | Complete overview | High-level understanding |
| [🧪 Demo Results](docs/guides/MCP_SERVER_DEMO_RESULTS.md) | Test results and examples | Verifying functionality |
| [🎨 Registry UI](docs/guides/REGISTRY_UI_UPDATED.md) | UI features | Understanding UI changes |
| [🔧 Manual Install](docs/guides/POSTGRES_MCP_INSTALL.md) | Manual setup guide | Custom installation |
| [✅ Setup Complete](docs/guides/SETUP_COMPLETE.md) | What was configured | Understanding setup |
| [📋 Commands](docs/guides/INSTALLATION_COMMANDS.txt) | Quick reference | Command cheat sheet |

### Additional Resources

- [Detailed Installation Guide](docs/POSTGRES_INSTALL.md)
- [Standalone HTML Page](docs/install-postgres-mcp.html)
- [Installer Documentation](docs/INSTALLER.md)
- [Quickstart Guide](docs/modelcontextprotocol-io/quickstart.mdx)

**Start here**: [📑 Documentation Index](docs/guides/DOCUMENTATION_INDEX.md)
