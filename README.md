# Suispicious

A project with a Go backend and React frontend.

## Development Environment

This project uses Docker Compose to set up a local development environment with hot-reloading for both the server and UI components.

### Prerequisites

- Docker and Docker Compose
- Git

### Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/Suispicious/suispicious.git
   cd suispicious
   ```

2. Start the development environment:
   ```
   docker-compose up
   ```

3. Access the applications:
   - Backend API: http://localhost:8080
   - Frontend UI: http://localhost:3000

### Development Workflow

- The Go server automatically reloads when you make changes to the Go code
- The React UI automatically reloads when you make changes to the React code
- Both services are connected via a Docker network

### Stopping the Environment

To stop the development environment, press `Ctrl+C` in the terminal where docker-compose is running, or run:
```
docker-compose down
```

## Project Structure

- `server/`: Go backend with Gin HTTP server
- `ui/`: React frontend
- `move/`: Move-related code