# Build stage
FROM golang:1.24-alpine AS builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev sqlite-dev

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -a -ldflags '-linkmode external -extldflags "-static"' -o whatsapp-bridge .

# Production stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates curl

# Create app directory
RUN mkdir -p /app/store /app/session

# Copy binary from builder
COPY --from=builder /app/whatsapp-bridge /app/

# Set working directory
WORKDIR /app

# Create non-root user
RUN adduser -D -s /bin/sh whatsapp
RUN chown -R whatsapp:whatsapp /app
USER whatsapp

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run the application
CMD ["./whatsapp-bridge"]
