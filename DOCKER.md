# WhatsApp MCP Docker Setup

This Docker Compose setup allows you to run the WhatsApp MCP server and bridge in containers.

## Prerequisites

- Docker
- Docker Compose
- WhatsApp account for authentication

## Quick Start

1. **Clone and navigate to the directory:**
   ```bash
   git clone <repository-url>
   cd whatsapp-mcp
   ```

2. **Build and start the services:**
   ```bash
   docker-compose up --build
   ```

3. **Authenticate with WhatsApp:**
   - Watch the logs for the whatsapp-bridge service:
     ```bash
     docker-compose logs -f whatsapp-bridge
     ```
   - Scan the QR code that appears with your WhatsApp mobile app
   - The authentication will be saved in the `./whatsapp-bridge/session` volume

4. **Access the services:**
   - WhatsApp Bridge API: http://localhost:8080
   - MCP Server: http://localhost:3000

## Services

### whatsapp-bridge
- **Port:** 8080
- **Purpose:** Go application that connects to WhatsApp Web API
- **Volumes:**
  - `./whatsapp-bridge/store` - SQLite database storage
  - `./whatsapp-bridge/session` - WhatsApp session data
- **Health Check:** Available at http://localhost:8080/health

### whatsapp-mcp-server
- **Port:** 3000
- **Purpose:** Python MCP server that provides tools for WhatsApp interaction
- **Volumes:**
  - `./whatsapp-bridge/store` - Read-only access to message database
  - `./whatsapp-mcp-server/media` - Media file storage
- **Dependencies:** FFmpeg for audio conversion

## Environment Variables

### whatsapp-bridge
- `CGO_ENABLED=1` - Required for SQLite support

### whatsapp-mcp-server
- `WHATSAPP_API_BASE_URL` - URL to the bridge API (default: http://whatsapp-bridge:8080/api)
- `MESSAGES_DB_PATH` - Path to the messages database (default: /app/store/messages.db)
- `PYTHONUNBUFFERED=1` - For better logging

## Data Persistence

The following directories are mounted as volumes to persist data:

- `./whatsapp-bridge/store/` - Contains the SQLite database with all messages
- `./whatsapp-bridge/session/` - Contains WhatsApp session authentication data
- `./whatsapp-mcp-server/media/` - Contains downloaded media files

## Network

All services run on a custom bridge network called `whatsapp-network` to enable inter-service communication.

## Management Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f whatsapp-bridge
docker-compose logs -f whatsapp-mcp-server
```

### Rebuild and restart
```bash
docker-compose down
docker-compose up --build
```

### Clean restart (removes volumes)
```bash
docker-compose down -v
docker-compose up --build
```

## Troubleshooting

### WhatsApp Authentication Issues
- If authentication fails, remove the session volume and restart:
  ```bash
  docker-compose down
  rm -rf ./whatsapp-bridge/session/*
  docker-compose up
  ```

### Database Issues
- If there are database connection issues, check the bridge service health:
  ```bash
  curl http://localhost:8080/health
  ```

### Python Dependencies
- If Python packages are missing, rebuild the MCP server:
  ```bash
  docker-compose build whatsapp-mcp-server
  docker-compose up whatsapp-mcp-server
  ```

### Logs and Debugging
- Enable verbose logging by adding environment variables in docker-compose.yml:
  ```yaml
  environment:
    - DEBUG=1
    - LOG_LEVEL=debug
  ```

## Security Notes

- The containers run as non-root users for security
- WhatsApp session data is persisted in volumes - keep this secure
- The message database contains your personal WhatsApp data
- Services communicate internally on a private Docker network

## Integration with Claude Desktop

To use with Claude Desktop, add this configuration to your Claude Desktop config:

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "docker",
      "args": ["exec", "-i", "whatsapp-mcp-server", "uv", "run", "python", "main.py"],
      "env": {}
    }
  }
}
```

Or connect directly to the MCP server running on localhost:3000.

# Navigate to the project directory
cd /Users/parra/Documents/AP/dev/mcp-servers/public-mcp-servers/whatsapp-mcp

# Initial setup
make install

# Start services
make up

# Watch logs to see QR code for WhatsApp authentication
make logs-bridge

# Check status
make status