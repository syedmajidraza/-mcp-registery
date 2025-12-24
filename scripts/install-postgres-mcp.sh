#!/bin/bash
# PostgreSQL MCP Server - Automated Installation Script
# This script automates the installation of the PostgreSQL MCP server

set -e  # Exit on any error

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
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Environment file created: $MCP_SERVER_DIR/.env"
    echo -e "${YELLOW}⚠${NC}  You need to configure your database credentials in .env"
else
    echo -e "${BLUE}.env file already exists. Skipping...${NC}"
fi

# Create a convenient start script at the MCP server directory
echo -e "\n${YELLOW}Creating start script...${NC}"
cat > "$MCP_SERVER_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
echo "Starting PostgreSQL MCP Server on http://127.0.0.1:3000"
echo "Press Ctrl+C to stop the server"
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

# Installation complete
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Next steps
echo -e "${BLUE}Next Steps:${NC}\n"
echo -e "1. Configure your PostgreSQL database credentials:"
echo -e "   ${YELLOW}nano $MCP_SERVER_DIR/.env${NC}\n"
echo -e "   Required variables:"
echo -e "   - DB_HOST (e.g., localhost)"
echo -e "   - DB_PORT (e.g., 5432)"
echo -e "   - DB_NAME (your database name)"
echo -e "   - DB_USER (your database user)"
echo -e "   - DB_PASSWORD (your database password)\n"

echo -e "2. Start the server:"
echo -e "   ${YELLOW}$MCP_SERVER_DIR/start.sh${NC}\n"

echo -e "3. Stop the server (when needed):"
echo -e "   ${YELLOW}$MCP_SERVER_DIR/stop.sh${NC}\n"

echo -e "${BLUE}Installation location:${NC} $MCP_SERVER_DIR"
echo -e "${BLUE}Server will run on:${NC} http://127.0.0.1:3000\n"
