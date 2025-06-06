# Use Python 3.11 as specified in .python-version
FROM python:3.11-slim

# Install system dependencies including FFmpeg for audio conversion
RUN apt-get update && apt-get install -y \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml uv.lock ./

# Install Python dependencies
RUN uv sync --frozen

# Copy source code
COPY . .

# Create directories for media and store
RUN mkdir -p /app/media /app/store

# Create non-root user
RUN useradd -m -s /bin/bash whatsapp
RUN chown -R whatsapp:whatsapp /app
USER whatsapp

# Expose port for MCP server
EXPOSE 3000

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV WHATSAPP_API_BASE_URL=http://whatsapp-bridge:8080/api
ENV MESSAGES_DB_PATH=/app/store/messages.db

# Run the MCP server
CMD ["uv", "run", "python", "main.py"]
