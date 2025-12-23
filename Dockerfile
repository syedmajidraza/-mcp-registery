# syntax=docker/dockerfile:1

# Build stage
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o mcp-registry ./cmd/registry

# Final stage
FROM alpine:3.23
WORKDIR /app
COPY --from=builder /app/mcp-registry ./mcp-registry
COPY data ./data
EXPOSE 8080
ENTRYPOINT ["./mcp-registry"]
