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

## Player Matching and Staking Logic

### Overview
This project implements a blockchain-based chess game on the SUI platform. The game includes a player matching and staking mechanism to ensure fair play and commitment from both players.

### Key Components
1. **Matchmaker**: A singleton object that holds pending stakes and matches players.
2. **Game**: Represents an active chess game between two players.
3. **Staking**: Players deposit their stakes (SUI coins) into the Matchmaker before the game starts.

### Workflow
1. **Matchmaker Creation**:
   - The admin creates a singleton `Matchmaker` object.
   - This object holds pending stakes and matches players.

2. **Player Joins**:
   - Players call the `join_matchmaker` function to deposit their stakes into the `Matchmaker`.
   - The `Matchmaker` stores the player's address and their stake.

3. **Game Creation**:
   - Once two players have joined, the admin calls `create_game_from_matchmaker` to create a new `Game` object.
   - The stakes are transferred from the `Matchmaker` to the `Game`.

4. **Game Progression**:
   - Players make moves using the `send_move` function.
   - The game state is updated accordingly.

5. **Stake Distribution**:
   - At the end of the game, the admin calls `distribute_stakes` to transfer the stakes to the winner.

### Benefits
- **Gas Efficiency**: Players only pay gas fees to join the `Matchmaker`, and the admin pays to create the game.
- **Security**: Stakes are locked in the `Matchmaker` until the game starts.
- **Fairness**: Both players must commit their stakes before the game begins.