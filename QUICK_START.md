# Quick Start Guide

## 🚀 3-Step Installation

### 1. Start Registry
```bash
docker-compose up -d
```
✅ Registry: http://localhost:9090

### 2. Start Installer
```bash
make installer && ./bin/mcp-installer
```
✅ Installer: http://localhost:3456

### 3. Install MCP Server
Open http://localhost:9090 and click **"Install"**

---

## 📦 Available MCP Servers

| Server | Version | Description | Install Command |
|--------|---------|-------------|-----------------|
| **mcp-postgres** | 1.0.0 | PostgreSQL with natural language queries | `npm install -g mcp-postgres` |
| **markitdown-js** | 0.0.14 | Convert documents to Markdown (JS) | `npm install -g markitdown-js` |
| **markitdown-ts** | 0.0.7 | Convert documents to Markdown (TS) | `npm install -g markitdown-ts` |
| **postman-mcp-server** | 1.0.0 | Postman API integration | `npm install -g postman-mcp-server` |
| **@modelcontextprotocol/server-github** | 0.6.2 | GitHub API integration | `npm install -g @modelcontextprotocol/server-github` |

---

## 🛠️ Essential Commands

```bash
# Start registry
docker-compose up -d

# Stop registry
docker-compose down

# View logs
docker-compose logs -f registry

# Build installer
make installer

# Run installer
./bin/mcp-installer

# Check health
curl http://localhost:9090/v0.1/version
curl http://localhost:3456/health

# List installed packages
npm list -g --depth=0
```

---

## 🆘 Troubleshooting

**Registry not accessible?**
```bash
docker-compose restart registry
```

**Installer not running?**
```bash
./bin/mcp-installer
```

**Installation fails?**
```bash
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

---

## 📚 Full Documentation

- **Complete Guide:** [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
- **Installer Details:** [docs/INSTALLER.md](docs/INSTALLER.md)
- **README:** [README.md](README.md)

---

## 🎯 Ports

| Service | Port | URL |
|---------|------|-----|
| Registry | 9090 | http://localhost:9090 |
| Installer | 3456 | http://localhost:3456 |
| PostgreSQL | 5433 | localhost:5433 |
