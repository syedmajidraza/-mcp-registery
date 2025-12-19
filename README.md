
# yourcompany MCP Registry

yourcompany MCP Registry is a local, isolated MCP registry that provides MCP clients with a list of MCP servers. This version is rebranded and restricted to only two local MCP servers, with all remote aggregation and fallback to public registries disabled.

📚 [**Developer Guide**](DEVELOPER_GUIDE.md) | [**Installer Guide**](docs/INSTALLER.md) | [**Quickstart**](docs/modelcontextprotocol-io/quickstart.mdx) | 📖 **[Full documentation](./docs)**


## Project Status

**2025-12-05 update:**
- The registry is now fully local-only and rebranded as "yourcompany MCP Registry."
- Only two MCP servers are listed, as defined in `data/seed.json`.
- Remote aggregation and fallback to public registries are disabled at the code level.
- Docker Compose and database setup have been updated for a clean, isolated development environment.


## Quick Start


### Prerequisites

- **Docker**
- **Go 1.24.x**


#### Running the server

```bash
# Start the local yourcompany MCP Registry environment
docker-compose up --build -d
```

This starts the registry at [`localhost:9090`](http://localhost:9090) with PostgreSQL. The database uses ephemeral storage and is reset each time you restart the containers, ensuring a clean state for development and testing. The registry loads 5 MCP servers defined in `data/seed.json` and does not aggregate from any remote sources.

Configuration is managed via [docker-compose.yml](./docker-compose.yml). The default database name is now `mcp-registry-test` for a clean, isolated state.


<!--
## Screenshot
No screenshot is currently included. Add a screenshot of the yourcompany MCP Registry UI here if desired.
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


## More Documentation

See the [documentation](./docs) for more details.
