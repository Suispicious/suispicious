# Suispicious Server

A Gin-based HTTP server for the Suispicious project.

## Getting Started

### Prerequisites

- Go 1.24.2 or higher

### Installation

1. Navigate to the server directory:
   ```
   cd server
   ```

2. Download dependencies:
   ```
   go mod tidy
   ```

3. Run the server:
   ```
   go run cmd/main.go
   ```

The server will start on port 8080.

## API Endpoints

- `GET /hello`: Returns a hello world message
  ```
  {
    "message": "Hello, World!"
  }
  ``` 