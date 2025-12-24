# PostgreSQL MCP Server - Migration Guide

**How to add PostgreSQL MCP Server to other MCP-compliant projects**

This guide explains how to migrate or add the PostgreSQL MCP Server to other projects that support MCP (Model Context Protocol) but may have different registry implementations or seed.json formats.

---

## Table of Contents

- [Overview](#overview)
- [Understanding the PostgreSQL MCP Server Entry](#understanding-the-postgresql-mcp-server-entry)
- [Migration to Different MCP Projects](#migration-to-different-mcp-projects)
- [Standard MCP Registry Format](#standard-mcp-registry-format)
- [Custom Installation Methods](#custom-installation-methods)
- [Registry-Specific Adaptations](#registry-specific-adaptations)
- [Examples](#examples)
- [Testing](#testing)

---

## Overview

The PostgreSQL MCP Server can be added to any MCP-compliant registry by adapting the server entry to match the target registry's format. While the core MCP protocol is standardized, registry implementations may vary in:

- `seed.json` structure
- Installation methods
- Package management
- Server metadata format

---

## Understanding the PostgreSQL MCP Server Entry

### Current Entry in Syed MCP Registry

From `data/seed.json`:

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json",
  "name": "io.github.syedmajidraza/mcp-postgres",
  "description": "MCP PostgreSQL server - A Python-based MCP server for interacting with PostgreSQL databases. Provides database schema inspection, query execution, and table management capabilities.",
  "repository": {
    "url": "https://github.com/syedmajidraza/mcp-postgres",
    "source": "github"
  },
  "version": "1.0.0",
  "packages": [
    {
      "registryType": "custom",
      "identifier": "mcp-postgres",
      "version": "1.0.0",
      "install": "curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash",
      "transport": {
        "type": "stdio"
      }
    }
  ]
}
```

### Key Components

1. **Schema Validation** - Uses official MCP server schema
2. **Name** - Unique identifier for the server
3. **Repository** - Source code location
4. **Packages** - Installation methods and metadata
5. **Transport Type** - Communication protocol (stdio)

---

## Migration to Different MCP Projects

### Step 1: Identify Target Registry Format

Different MCP registries may use different formats. Common variations:

#### Variation A: Official MCP Registry Format
```json
{
  "name": "mcp-postgres",
  "version": "1.0.0",
  "description": "PostgreSQL MCP server",
  "vendor": "io.github.syedmajidraza",
  "sourceUrl": "https://github.com/syedmajidraza/mcp-postgres",
  "runtime": "python",
  "installType": "script"
}
```

#### Variation B: NPM-Style Format
```json
{
  "name": "@syedmajidraza/mcp-postgres",
  "version": "1.0.0",
  "description": "PostgreSQL MCP server",
  "repository": "https://github.com/syedmajidraza/mcp-postgres",
  "main": "server.py",
  "scripts": {
    "install": "curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash"
  }
}
```

#### Variation C: Minimal Format
```json
{
  "id": "mcp-postgres",
  "repo": "https://github.com/syedmajidraza/mcp-postgres",
  "version": "1.0.0"
}
```

---

### Step 2: Adapt the Entry

Based on target registry's requirements, adapt the PostgreSQL MCP Server entry.

#### Example: Adapting to Standard MCP Registry

**Original (Syed Registry):**
```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json",
  "name": "io.github.syedmajidraza/mcp-postgres",
  "packages": [
    {
      "registryType": "custom",
      "identifier": "mcp-postgres"
    }
  ]
}
```

**Adapted (Standard MCP Registry):**
```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json",
  "name": "mcp-postgres",
  "vendor": "syedmajidraza",
  "repository": {
    "type": "git",
    "url": "https://github.com/syedmajidraza/mcp-postgres.git"
  },
  "version": "1.0.0",
  "description": "PostgreSQL database MCP server with schema inspection and query execution",
  "homepage": "https://github.com/syedmajidraza/mcp-postgres",
  "license": "MIT",
  "tags": ["database", "postgresql", "sql", "mcp"],
  "runtime": {
    "language": "python",
    "version": ">=3.8"
  },
  "transport": {
    "type": "stdio"
  },
  "capabilities": {
    "tools": true,
    "resources": false,
    "prompts": false
  }
}
```

---

## Standard MCP Registry Format

### Complete Standard Entry

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json",
  "name": "mcp-postgres",
  "vendor": "syedmajidraza",
  "version": "1.0.0",
  "description": "MCP PostgreSQL server - A Python-based MCP server for interacting with PostgreSQL databases. Provides database schema inspection, query execution, and table management capabilities.",

  "repository": {
    "type": "git",
    "url": "https://github.com/syedmajidraza/mcp-postgres.git",
    "directory": "mcp-server"
  },

  "homepage": "https://github.com/syedmajidraza/mcp-postgres",
  "license": "MIT",
  "author": "Syed Majid Raza",

  "tags": [
    "database",
    "postgresql",
    "sql",
    "query",
    "schema",
    "mcp-server"
  ],

  "runtime": {
    "language": "python",
    "version": ">=3.8",
    "dependencies": [
      "fastapi==0.115.0",
      "uvicorn==0.32.0",
      "asyncpg==0.29.0",
      "pydantic==2.9.2",
      "python-dotenv==1.0.1"
    ]
  },

  "transport": {
    "type": "stdio"
  },

  "capabilities": {
    "tools": true,
    "resources": false,
    "prompts": false
  },

  "installation": {
    "method": "script",
    "script": "https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh",
    "requirements": ["python3", "git"],
    "postInstall": "Interactive database credential setup on first start"
  },

  "configuration": {
    "required": [
      {
        "key": "DB_NAME",
        "description": "PostgreSQL database name",
        "type": "string"
      },
      {
        "key": "DB_PASSWORD",
        "description": "PostgreSQL password",
        "type": "string",
        "sensitive": true
      }
    ],
    "optional": [
      {
        "key": "DB_HOST",
        "description": "PostgreSQL host",
        "type": "string",
        "default": "localhost"
      },
      {
        "key": "DB_PORT",
        "description": "PostgreSQL port",
        "type": "number",
        "default": 5432
      },
      {
        "key": "DB_USER",
        "description": "PostgreSQL username",
        "type": "string",
        "default": "postgres"
      }
    ]
  },

  "tools": [
    {
      "name": "query_database",
      "description": "Execute a SELECT query on the PostgreSQL database"
    },
    {
      "name": "execute_sql",
      "description": "Execute a SQL statement (INSERT, UPDATE, DELETE, CREATE TABLE, etc.)"
    },
    {
      "name": "create_table",
      "description": "Create a new table in the PostgreSQL database"
    },
    {
      "name": "create_stored_procedure",
      "description": "Create a stored procedure or function"
    },
    {
      "name": "list_tables",
      "description": "List all tables in the current database schema"
    },
    {
      "name": "describe_table",
      "description": "Get the structure/schema of a specific table"
    },
    {
      "name": "get_table_indexes",
      "description": "Get all indexes for a specific table"
    },
    {
      "name": "analyze_query_plan",
      "description": "Analyze and return the execution plan for a SQL query"
    }
  ]
}
```

---

## Custom Installation Methods

### Method 1: Direct Git Clone

For registries that prefer direct repository installation:

```json
{
  "installation": {
    "method": "git",
    "repository": "https://github.com/syedmajidraza/mcp-postgres.git",
    "directory": "mcp-server",
    "setup": [
      "cd mcp-server",
      "python3 -m venv venv",
      "source venv/bin/activate",
      "pip install -r requirements.txt",
      "cp .env.example .env"
    ]
  }
}
```

### Method 2: NPM-Style Installation

For registries using NPM package manager:

```json
{
  "installation": {
    "method": "npm",
    "package": "@syedmajidraza/mcp-postgres",
    "postInstall": "mcp-postgres-setup"
  }
}
```

### Method 3: Docker-Based Installation

For Docker-based registries:

```json
{
  "installation": {
    "method": "docker",
    "image": "syedmajidraza/mcp-postgres:latest",
    "ports": ["3000:3000"],
    "environment": [
      "DB_HOST",
      "DB_PORT",
      "DB_NAME",
      "DB_USER",
      "DB_PASSWORD"
    ]
  }
}
```

### Method 4: Python Package Installation

If distributed as a Python package:

```json
{
  "installation": {
    "method": "pip",
    "package": "mcp-postgres-server",
    "command": "pip install mcp-postgres-server"
  }
}
```

---

## Registry-Specific Adaptations

### For ModelContextProtocol.io Official Registry

```json
{
  "name": "postgres",
  "vendor": "syedmajidraza",
  "version": "1.0.0",
  "description": "PostgreSQL database server with schema inspection and query execution",
  "repository": "https://github.com/syedmajidraza/mcp-postgres",
  "language": "python",
  "license": "MIT"
}
```

### For Claude Desktop

```json
{
  "mcpServers": {
    "postgres": {
      "command": "python3",
      "args": [
        "-m",
        "uvicorn",
        "server:app",
        "--host",
        "127.0.0.1",
        "--port",
        "3000"
      ],
      "cwd": "~/.mcp/servers/mcp-postgres/mcp-server",
      "env": {
        "DB_HOST": "localhost",
        "DB_PORT": "5432",
        "DB_NAME": "mydb",
        "DB_USER": "postgres",
        "DB_PASSWORD": "password"
      }
    }
  }
}
```

### For VSCode MCP Extension

```json
{
  "mcp.servers": [
    {
      "id": "postgres",
      "name": "PostgreSQL MCP Server",
      "command": "~/.mcp/servers/mcp-postgres/mcp-server/start.sh",
      "autoStart": false,
      "config": {
        "dbHost": "localhost",
        "dbPort": 5432,
        "dbName": "${config:postgres.dbName}",
        "dbUser": "${config:postgres.dbUser}",
        "dbPassword": "${secret:postgres.password}"
      }
    }
  ]
}
```

---

## Examples

### Example 1: Adding to a Simple Registry

**Target Registry Format:**
```json
{
  "servers": []
}
```

**Add PostgreSQL Server:**
```json
{
  "servers": [
    {
      "name": "mcp-postgres",
      "url": "https://github.com/syedmajidraza/mcp-postgres",
      "version": "1.0.0",
      "install": "curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash"
    }
  ]
}
```

### Example 2: Adding to NPM-Based Registry

**Create package.json:**
```json
{
  "name": "@syedmajidraza/mcp-postgres",
  "version": "1.0.0",
  "description": "PostgreSQL MCP server",
  "main": "mcp-server/server.py",
  "bin": {
    "mcp-postgres": "mcp-server/start.sh"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/syedmajidraza/mcp-postgres.git"
  },
  "keywords": ["mcp", "postgresql", "database"],
  "author": "Syed Majid Raza",
  "license": "MIT"
}
```

### Example 3: Adding to YAML-Based Registry

```yaml
servers:
  - id: mcp-postgres
    name: PostgreSQL MCP Server
    version: 1.0.0
    description: PostgreSQL database server with schema inspection
    repository: https://github.com/syedmajidraza/mcp-postgres
    language: python
    requirements:
      - python: ">=3.8"
      - git: "*"
    installation:
      script: https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh
    transport: stdio
    capabilities:
      - tools
```

---

## Testing

### Validate Your Entry

1. **Schema Validation:**
   ```bash
   # If registry supports JSON schema validation
   npm install -g ajv-cli
   ajv validate -s server.schema.json -d your-entry.json
   ```

2. **Manual Testing:**
   ```bash
   # Test installation
   curl -fsSL https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh | bash

   # Test server starts
   ~/.mcp/servers/mcp-postgres/start.sh

   # Test tools endpoint
   curl http://localhost:3000/mcp/v1/tools
   ```

3. **Integration Testing:**
   ```bash
   # Test with target registry's client
   mcp-client install mcp-postgres
   mcp-client run mcp-postgres list_tables
   ```

---

## Migration Checklist

- [ ] Review target registry's documentation
- [ ] Identify required entry format
- [ ] Map Syed Registry fields to target format
- [ ] Update installation method if needed
- [ ] Add any registry-specific metadata
- [ ] Validate against registry schema
- [ ] Test installation process
- [ ] Test server functionality
- [ ] Update documentation
- [ ] Submit to target registry

---

## Common Migration Patterns

### Pattern 1: Minimal to Detailed

**From:**
```json
{
  "name": "mcp-postgres",
  "url": "https://github.com/syedmajidraza/mcp-postgres"
}
```

**To:**
```json
{
  "name": "mcp-postgres",
  "version": "1.0.0",
  "description": "PostgreSQL MCP server",
  "repository": {
    "url": "https://github.com/syedmajidraza/mcp-postgres"
  },
  "packages": [
    {
      "registryType": "custom",
      "identifier": "mcp-postgres",
      "version": "1.0.0",
      "transport": {
        "type": "stdio"
      }
    }
  ]
}
```

### Pattern 2: Custom to Standard

**From:**
```json
{
  "registryType": "custom",
  "install": "curl ... | bash"
}
```

**To:**
```json
{
  "registryType": "npm",
  "identifier": "@syedmajidraza/mcp-postgres",
  "version": "1.0.0"
}
```

### Pattern 3: Single Package to Multi-Package

**From:**
```json
{
  "packages": [
    {
      "registryType": "custom",
      "identifier": "mcp-postgres"
    }
  ]
}
```

**To:**
```json
{
  "packages": [
    {
      "registryType": "pip",
      "identifier": "mcp-postgres-server"
    },
    {
      "registryType": "npm",
      "identifier": "@syedmajidraza/mcp-postgres"
    },
    {
      "registryType": "docker",
      "identifier": "syedmajidraza/mcp-postgres"
    }
  ]
}
```

---

## Summary

**Key Points for Migration:**

1. **Understand target format** - Each registry may have different requirements
2. **Preserve core information** - Name, version, repository, description
3. **Adapt installation method** - Match target registry's package management
4. **Maintain functionality** - Ensure server works the same way
5. **Test thoroughly** - Validate before submission

**Essential Information to Preserve:**

- Server name/identifier
- Version number
- Repository URL
- Installation method
- Transport type (stdio)
- Required configuration
- Tool capabilities

**Common Adaptations:**

- Change naming convention
- Update installation script location
- Add/remove metadata fields
- Restructure packages array
- Convert between formats (JSON/YAML/TOML)

---

## Resources

- **MCP Server Schema:** https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json
- **PostgreSQL MCP Repository:** https://github.com/syedmajidraza/mcp-postgres
- **Syed Registry:** https://github.com/syedmajidraza/-mcp-registery
- **Installation Script:** https://raw.githubusercontent.com/syedmajidraza/-mcp-registery/main/scripts/install-postgres-mcp.sh

---

**Last Updated:** December 24, 2024
**Document Version:** 1.0.0
