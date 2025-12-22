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

# Step 3: Clone repository
echo -e "\n${YELLOW}[3/6]${NC} Cloning repository..."
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${BLUE}Repository already exists. Pulling latest changes...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main
else
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
echo -e "${GREEN}✓${NC} Repository cloned successfully"

# Step 4: Create virtual environment
echo -e "\n${YELLOW}[4/6]${NC} Creating Python virtual environment..."
cd "$MCP_SERVER_DIR"
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

# Create a convenient start script
echo -e "\n${YELLOW}Creating start script...${NC}"
cat > "$INSTALL_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/mcp-server"
source venv/bin/activate
echo "Starting PostgreSQL MCP Server on http://127.0.0.1:3000"
echo "Press Ctrl+C to stop the server"
echo ""
uvicorn server:app --host 127.0.0.1 --port 3000
EOF

chmod +x "$INSTALL_DIR/start.sh"
echo -e "${GREEN}✓${NC} Start script created: $INSTALL_DIR/start.sh"

# Create a stop script
cat > "$INSTALL_DIR/stop.sh" << 'EOF'
#!/bin/bash
PID=$(lsof -ti:3000)
if [ -z "$PID" ]; then
    echo "No server running on port 3000"
else
    kill $PID
    echo "Server stopped (PID: $PID)"
fi
EOF

chmod +x "$INSTALL_DIR/stop.sh"
echo -e "${GREEN}✓${NC} Stop script created: $INSTALL_DIR/stop.sh"

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
echo -e "   ${YELLOW}$INSTALL_DIR/start.sh${NC}\n"

echo -e "3. Stop the server (when needed):"
echo -e "   ${YELLOW}$INSTALL_DIR/stop.sh${NC}\n"

echo -e "${BLUE}Installation location:${NC} $INSTALL_DIR"
echo -e "${BLUE}Server will run on:${NC} http://127.0.0.1:3000\n"
