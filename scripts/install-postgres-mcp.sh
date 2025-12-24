#!/bin/bash
# PostgreSQL MCP Server - Automated Installation Script
# This script automates the installation of the PostgreSQL MCP server
#
# Usage:
#   ./install-postgres-mcp.sh           # Normal installation (updates if exists)
#   ./install-postgres-mcp.sh --force   # Force reinstall (delete and recreate)

set -e  # Exit on any error

# Check for --force flag
FORCE_REINSTALL=false
if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    FORCE_REINSTALL=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/syedmajidraza/mcp-postgres.git"
INSTALL_DIR="$HOME/.mcp/servers/mcp-postgres"
MCP_SERVER_DIR="$INSTALL_DIR/mcp-server"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PostgreSQL MCP Server Installation${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Handle force reinstall
if [ "$FORCE_REINSTALL" = true ] && [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Force reinstall requested. Removing existing installation...${NC}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓${NC} Existing installation removed\n"
fi

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/6]${NC} Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    echo "Please install Python 3.8 or higher and try again"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION found"

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Git found"

# Step 2: Create installation directory
echo -e "\n${YELLOW}[2/6]${NC} Creating installation directory..."
mkdir -p "$INSTALL_DIR"
echo -e "${GREEN}✓${NC} Directory created: $INSTALL_DIR"

# Step 3: Clone repository (sparse checkout for mcp-server only)
echo -e "\n${YELLOW}[3/6]${NC} Cloning mcp-server from repository..."
if [ -d "$MCP_SERVER_DIR/.git" ]; then
    echo -e "${BLUE}Repository already exists. Pulling latest changes...${NC}"
    cd "$MCP_SERVER_DIR"
    git pull origin main
else
    # Clean up if INSTALL_DIR exists but MCP_SERVER_DIR doesn't
    if [ -d "$INSTALL_DIR" ] && [ ! -d "$MCP_SERVER_DIR" ]; then
        echo -e "${YELLOW}Cleaning up incomplete installation...${NC}"
        rm -rf "$INSTALL_DIR"
    fi

    # Use sparse checkout to only get the mcp-server directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # Use a unique temporary directory name to avoid conflicts
    TEMP_DIR="temp_repo_$$"

    # Initialize git with sparse checkout
    git clone --filter=blob:none --sparse "$REPO_URL" "$TEMP_DIR"
    cd "$TEMP_DIR"
    git sparse-checkout set mcp-server

    # Move mcp-server contents to the final location and clean up
    mv mcp-server "$MCP_SERVER_DIR"
    cd "$INSTALL_DIR"
    rm -rf "$TEMP_DIR"

    # Initialize git in the mcp-server directory for updates
    cd "$MCP_SERVER_DIR"
    git init
    git remote add origin "$REPO_URL"
    git config core.sparseCheckout true
    mkdir -p .git/info
    echo "mcp-server/*" > .git/info/sparse-checkout
    git fetch origin main
    git checkout main

    # Check if files were retrieved
    if [ ! -f "server.py" ]; then
        echo -e "${RED}Error: MCP server files not found after checkout${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} MCP server files retrieved successfully"

# Step 4: Create virtual environment
echo -e "\n${YELLOW}[4/6]${NC} Creating Python virtual environment..."
if [ -d "venv" ]; then
    echo -e "${BLUE}Virtual environment already exists. Skipping...${NC}"
else
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} Virtual environment created"
fi

# Step 5: Install dependencies
echo -e "\n${YELLOW}[5/6]${NC} Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt
echo -e "${GREEN}✓${NC} Dependencies installed successfully"

# Step 6: Configure environment
echo -e "\n${YELLOW}[6/6]${NC} Setting up environment configuration..."
if [ ! -f ".env" ]; then
    # Don't create .env file - let start.sh prompt for credentials interactively
    echo -e "${GREEN}✓${NC} Setup complete - database credentials will be requested on first start"
else
    echo -e "${BLUE}.env file already exists. Skipping...${NC}"
fi

# Create a convenient start script at the MCP server directory
echo -e "\n${YELLOW}Creating start script...${NC}"
cat > "$MCP_SERVER_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env file exists and has database configuration
if [ ! -f .env ] || ! grep -q "^DB_NAME=" .env || [ -z "$(grep '^DB_NAME=' .env | cut -d= -f2)" ]; then
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}PostgreSQL MCP Server - First Time Setup${NC}"
    echo -e "${YELLOW}========================================${NC}\n"

    # Prompt for database credentials
    echo -e "${BLUE}Please enter your PostgreSQL database credentials:${NC}\n"

    read -p "Database Host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}

    read -p "Database Port [5432]: " DB_PORT
    DB_PORT=${DB_PORT:-5432}

    read -p "Database Name: " DB_NAME
    while [ -z "$DB_NAME" ]; do
        echo -e "${YELLOW}Database name is required!${NC}"
        read -p "Database Name: " DB_NAME
    done

    read -p "Database User [postgres]: " DB_USER
    DB_USER=${DB_USER:-postgres}

    read -sp "Database Password: " DB_PASSWORD
    echo ""
    while [ -z "$DB_PASSWORD" ]; do
        echo -e "${YELLOW}Password is required!${NC}"
        read -sp "Database Password: " DB_PASSWORD
        echo ""
    done

    # Create .env file
    cat > .env << ENVEOF
# PostgreSQL Database Configuration
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# Server Configuration
SERVER_HOST=127.0.0.1
SERVER_PORT=3000
ENVEOF

    echo -e "\n${GREEN}✓${NC} Configuration saved to .env file"
    echo -e "${YELLOW}Note: You can edit .env file anytime to change these settings${NC}\n"
fi

echo -e "${GREEN}Starting PostgreSQL MCP Server on http://127.0.0.1:3000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""
uvicorn server:app --host 127.0.0.1 --port 3000
EOF

chmod +x "$MCP_SERVER_DIR/start.sh"
echo -e "${GREEN}✓${NC} Start script created: $MCP_SERVER_DIR/start.sh"

# Create a stop script
cat > "$MCP_SERVER_DIR/stop.sh" << 'EOF'
#!/bin/bash
PID=$(lsof -ti:3000)
if [ -z "$PID" ]; then
    echo "No server running on port 3000"
else
    kill $PID
    echo "Server stopped (PID: $PID)"
fi
EOF

chmod +x "$MCP_SERVER_DIR/stop.sh"
echo -e "${GREEN}✓${NC} Stop script created: $MCP_SERVER_DIR/stop.sh"

# Create wrapper scripts at parent level for convenience
cat > "$INSTALL_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/mcp-server"
exec ./start.sh
EOF

cat > "$INSTALL_DIR/stop.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/mcp-server"
exec ./stop.sh
EOF

chmod +x "$INSTALL_DIR/start.sh"
chmod +x "$INSTALL_DIR/stop.sh"
echo -e "${GREEN}✓${NC} Wrapper scripts created at: $INSTALL_DIR"

# Installation complete
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Next steps
echo -e "${BLUE}Next Steps:${NC}\n"
echo -e "1. Start the server (either command works):"
echo -e "   ${YELLOW}$INSTALL_DIR/start.sh${NC}"
echo -e "   ${YELLOW}$MCP_SERVER_DIR/start.sh${NC}\n"
echo -e "   ${BLUE}On first start, you'll be prompted to enter your database credentials.${NC}\n"

echo -e "2. Stop the server (when needed):"
echo -e "   ${YELLOW}$INSTALL_DIR/stop.sh${NC}"
echo -e "   ${YELLOW}$MCP_SERVER_DIR/stop.sh${NC}\n"

echo -e "3. To change database settings later, edit:"
echo -e "   ${YELLOW}$MCP_SERVER_DIR/.env${NC}\n"

echo -e "${BLUE}Installation location:${NC} $MCP_SERVER_DIR"
echo -e "${BLUE}Convenient wrapper scripts:${NC} $INSTALL_DIR/start.sh, $INSTALL_DIR/stop.sh"
echo -e "${BLUE}Server will run on:${NC} http://127.0.0.1:3000\n"
