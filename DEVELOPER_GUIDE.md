# Developer Guide: Installing MCP Servers from yourcompany Registry

This guide walks you through the complete process of discovering, installing, and running MCP servers from the yourcompany MCP Registry.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start (3 Steps)](#quick-start-3-steps)
3. [Detailed Step-by-Step Guide](#detailed-step-by-step-guide)
4. [Verifying Installation](#verifying-installation)
5. [Running MCP Servers](#running-mcp-servers)
6. [Troubleshooting](#troubleshooting)
7. [Available MCP Servers](#available-mcp-servers)

---

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

✅ **Docker** (for running the registry)
   ```bash
   docker --version
   # Should output: Docker version 20.x.x or higher
   ```

✅ **Docker Compose**
   ```bash
   docker-compose --version
   # Should output: docker-compose version 1.29.x or higher
   ```

✅ **Node.js & npm** (for installing MCP servers)
   ```bash
   node --version
   # Should output: v18.x.x or higher

   npm --version
   # Should output: 9.x.x or higher
   ```

✅ **Go 1.24.x** (for building the installer daemon)
   ```bash
   go version
   # Should output: go version go1.24.x
   ```

✅ **Git** (for cloning the repository)
   ```bash
   git --version
   # Should output: git version 2.x.x or higher
   ```

### Optional but Recommended

- **make** - For using Makefile commands
- **curl** or **httpie** - For testing API endpoints
- **jq** - For parsing JSON responses

---

## Quick Start (3 Steps)

### Step 1: Start the Registry

```bash
# Clone the repository
git clone https://github.com/syedmajidraza/test_mcp.git
cd test_mcp

# Start the registry
docker-compose up -d
```

Registry will be available at: **http://localhost:9090**

### Step 2: Start the Installer Daemon

```bash
# Build the installer
make installer

# Run the installer daemon
./bin/mcp-installer
```

Installer daemon will run on: **http://localhost:3456**

### Step 3: Install MCP Servers

Open your browser to **http://localhost:9090** and click the green **"Install"** button on any server!

---

## Detailed Step-by-Step Guide

### 1️⃣ Clone the Registry Repository

```bash
# Clone the repository
git clone https://github.com/syedmajidraza/test_mcp.git

# Navigate to the project directory
cd test_mcp

# Verify you're in the right directory
ls -la
# You should see: docker-compose.yml, Makefile, README.md, etc.
```

---

### 2️⃣ Start the Registry Server

The registry runs in Docker containers with PostgreSQL as the database.

```bash
# Start the registry (this will take 30-60 seconds on first run)
docker-compose up -d

# Verify containers are running
docker-compose ps
```

**Expected Output:**
```
   Name                 Command              State           Ports
-------------------------------------------------------------------------
postgres     docker-entrypoint.sh postgres   Up      0.0.0.0:5433->5432/tcp
registry     /app/mcp-registry              Up      0.0.0.0:9090->8080/tcp
```

**Check Registry Logs:**
```bash
docker-compose logs registry
```

Look for this line:
```
HTTP server starting on :8080
```

**Test the Registry API:**
```bash
curl http://localhost:9090/v0.1/version
```

Expected response:
```json
{
  "version": "dev",
  "git_commit": "unknown",
  "build_time": "unknown"
}
```

---

### 3️⃣ Build the Installer Daemon

The installer daemon allows one-click installation from the web UI.

```bash
# Build the installer binary
make installer

# Verify the binary was created
ls -lh bin/mcp-installer
```

**Expected Output:**
```
-rwxr-xr-x  1 user  staff   8.5M Dec 19 01:00 bin/mcp-installer
```

---

### 4️⃣ Start the Installer Daemon

**Option A: Run in Foreground (Recommended for Testing)**

```bash
./bin/mcp-installer
```

You should see:
```
MCP Installer Server v1.0.0 starting on port 3456
CORS enabled for all origins
```

Keep this terminal open.

**Option B: Run in Background**

```bash
./bin/mcp-installer > /tmp/mcp-installer.log 2>&1 &

# Save the process ID
echo $! > /tmp/mcp-installer.pid

# Monitor logs
tail -f /tmp/mcp-installer.log
```

**Test the Installer Daemon:**
```bash
curl http://localhost:3456/health
```

Expected response:
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

---

### 5️⃣ Browse Available MCP Servers

Open your web browser and navigate to:

```
http://localhost:9090
```

You'll see the **yourcompany MCP Registry** interface with 5 available MCP servers:

1. **markitdown-js** - Convert documents to Markdown (JavaScript)
2. **markitdown-ts** - Convert documents to Markdown (TypeScript)
3. **postman-mcp-server** - Postman API integration
4. **@modelcontextprotocol/server-github** - GitHub API integration
5. **mcp-postgres** - PostgreSQL with natural language queries

---

### 6️⃣ Install an MCP Server

You have two options to install:

#### **Option A: One-Click Installation (Recommended)**

1. Find the MCP server you want to install
2. Click the green **"Install"** button
3. Watch the real-time progress:
   - ⏳ "Installing..." - Download in progress
   - ✅ "Successfully installed" - Installation complete

**Example:**
```
┌─────────────────────────────────────────────────────┐
│ mcp-postgres                             v1.0.0     │
│ PostgreSQL MCP Server with Natural Language...     │
│ 12/19/2025                                         │
├─────────────────────────────────────────────────────┤
│ npm install -g mcp-postgres  [Install] [Copy]      │
└─────────────────────────────────────────────────────┘
```

#### **Option B: Manual Installation**

1. Click the blue **"Copy"** button to copy the install command
2. Open your terminal
3. Paste and run the command:

```bash
npm install -g mcp-postgres
```

---

## Verifying Installation

After installation, verify the MCP server was installed correctly:

### Check npm Global Packages

```bash
npm list -g --depth=0
```

You should see the installed package in the list:
```
/usr/local/lib
├── mcp-postgres@1.0.0
└── npm@9.8.1
```

### Check Executable Path

```bash
which mcp-postgres
# Output: /usr/local/bin/mcp-postgres (or similar)
```

### Test the MCP Server

Different servers have different commands. Here are examples:

**For mcp-postgres:**
```bash
mcp-postgres --help
```

**For markitdown-js:**
```bash
npx markitdown-js --help
```

**For @modelcontextprotocol/server-github:**
```bash
npx @modelcontextprotocol/server-github
```

---

## Running MCP Servers

### Example 1: mcp-postgres

```bash
# Set environment variables
export POSTGRES_CONNECTION_STRING="postgresql://user:password@localhost:5432/mydb"

# Run the server
mcp-postgres
```

### Example 2: GitHub MCP Server

```bash
# Set GitHub token
export GITHUB_PERSONAL_ACCESS_TOKEN="your_github_token_here"

# Run the server
npx @modelcontextprotocol/server-github
```

### Example 3: Postman MCP Server

```bash
# Set Postman API key
export POSTMAN_API_KEY="your_postman_api_key_here"

# Run the server
npx postman-mcp-server
```

---

## Troubleshooting

### Problem 1: Registry Not Accessible

**Error:** `curl: (7) Failed to connect to localhost port 9090`

**Solutions:**

1. Check if containers are running:
   ```bash
   docker-compose ps
   ```

2. Check registry logs:
   ```bash
   docker-compose logs registry
   ```

3. Restart the registry:
   ```bash
   docker-compose restart registry
   ```

4. Full restart:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

---

### Problem 2: Installer Daemon Not Running

**Error:** "⚠️ Installer daemon not running"

**Solutions:**

1. Check if daemon is running:
   ```bash
   curl http://localhost:3456/health
   ```

2. Check for port conflicts:
   ```bash
   lsof -i :3456
   ```

3. Start the daemon:
   ```bash
   ./bin/mcp-installer
   ```

4. Check logs if running in background:
   ```bash
   tail -f /tmp/mcp-installer.log
   ```

---

### Problem 3: Installation Fails

**Error:** "❌ Installation failed"

**Common Causes & Solutions:**

1. **npm Permissions Issue**
   ```bash
   # Configure npm to use user directory
   npm config set prefix ~/.npm-global
   export PATH=~/.npm-global/bin:$PATH

   # Add to your shell profile
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Network/Firewall Issue**
   ```bash
   # Test npm connectivity
   npm ping

   # Use manual installation
   npm install -g <package-name>
   ```

3. **Disk Space**
   ```bash
   # Check available disk space
   df -h

   # Clean npm cache
   npm cache clean --force
   ```

---

### Problem 4: Port Already in Use

**Error:** "bind: address already in use"

**For Registry (port 9090):**
```bash
# Find process using port 9090
lsof -i :9090

# Kill the process
kill -9 <PID>

# Restart registry
docker-compose up -d
```

**For Installer (port 3456):**
```bash
# Find process using port 3456
lsof -i :3456

# Kill the process
kill -9 <PID>

# Restart installer
./bin/mcp-installer
```

---

### Problem 5: Database Connection Error

**Error:** "Failed to connect to database"

**Solutions:**

1. Wait for PostgreSQL to be ready:
   ```bash
   docker-compose logs postgres
   ```

2. Check PostgreSQL is healthy:
   ```bash
   docker-compose ps postgres
   # Should show "healthy" in State
   ```

3. Restart PostgreSQL:
   ```bash
   docker-compose restart postgres
   sleep 5
   docker-compose restart registry
   ```

---

## Available MCP Servers

### 1. mcp-postgres v1.0.0

**Description:** PostgreSQL MCP Server with Natural Language Queries - Convert plain English to SQL using GitHub Copilot LLM.

**Features:**
- 8 database tools
- VS Code extension with server management
- Schema-aware SQL generation
- Complex queries, table creation, and stored procedures

**Install Command:**
```bash
npm install -g mcp-postgres
```

**Repository:** https://github.com/syedmajidraza/mcp-postgres

---

### 2. markitdown-js v0.0.14

**Description:** Converts various file formats (PDF, Word, Excel, PowerPoint, images, audio, HTML) to Markdown format.

**Install Command:**
```bash
npm install -g markitdown-js
```

**Repository:** https://github.com/Mirza-Glitch/markitdown-js

---

### 3. markitdown-ts v0.0.7

**Description:** Modern TypeScript implementation for converting documents with AI-powered image descriptions.

**Install Command:**
```bash
npm install -g markitdown-ts
```

**Repository:** https://github.com/dead8309/markitdown-ts

---

### 4. postman-mcp-server v1.0.0

**Description:** Postman MCP server for API testing integration.

**Install Command:**
```bash
npm install -g postman-mcp-server
```

**Repository:** https://github.com/postmanlabs/postman-mcp-server

---

### 5. @modelcontextprotocol/server-github v0.6.2

**Description:** Interact with GitHub repositories, issues, pull requests, and more through the GitHub API.

**Install Command:**
```bash
npm install -g @modelcontextprotocol/server-github
```

**Repository:** https://github.com/modelcontextprotocol/servers

---

## Quick Reference

### Essential Commands

```bash
# Start registry
docker-compose up -d

# Stop registry
docker-compose down

# View registry logs
docker-compose logs -f registry

# Build installer
make installer

# Run installer
./bin/mcp-installer

# Test installer health
curl http://localhost:3456/health

# Test registry API
curl http://localhost:9090/v0.1/version

# List installed MCP servers
npm list -g --depth=0

# Uninstall an MCP server
npm uninstall -g <package-name>
```

### Important URLs

- **Registry Web UI:** http://localhost:9090
- **Registry API:** http://localhost:9090/v0.1/
- **API Documentation:** http://localhost:9090/docs
- **Installer Daemon:** http://localhost:3456
- **GitHub Repository:** https://github.com/syedmajidraza/test_mcp

### Port Configuration

| Service | Port | Protocol |
|---------|------|----------|
| Registry Web UI | 9090 | HTTP |
| Installer Daemon | 3456 | HTTP |
| PostgreSQL | 5433 | TCP |

---

## Advanced Usage

### Running Multiple MCP Servers

You can install and run multiple MCP servers simultaneously:

```bash
# Install multiple servers
npm install -g mcp-postgres markitdown-js @modelcontextprotocol/server-github

# Run them in separate terminals
# Terminal 1
mcp-postgres

# Terminal 2
npx markitdown-js

# Terminal 3
npx @modelcontextprotocol/server-github
```

### Using with Process Managers

For production use, consider using a process manager like PM2:

```bash
# Install PM2
npm install -g pm2

# Start MCP server with PM2
pm2 start mcp-postgres --name "mcp-postgres-server"

# List running processes
pm2 list

# View logs
pm2 logs mcp-postgres-server

# Stop server
pm2 stop mcp-postgres-server
```

---

## Next Steps

1. ✅ Install your first MCP server
2. ✅ Read the server's documentation
3. ✅ Configure required environment variables
4. ✅ Test the server with sample data
5. ✅ Integrate with your application

---

## Getting Help

- **Documentation:** [docs/INSTALLER.md](docs/INSTALLER.md)
- **Issues:** https://github.com/syedmajidraza/test_mcp/issues
- **README:** [README.md](README.md)

---

## Summary

You've learned how to:

✅ Start the yourcompany MCP Registry
✅ Launch the installer daemon
✅ Browse available MCP servers
✅ Install MCP servers (one-click or manual)
✅ Verify installation
✅ Run MCP servers
✅ Troubleshoot common issues

Happy coding! 🚀
