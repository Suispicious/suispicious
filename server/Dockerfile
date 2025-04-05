FROM golang:1.24-alpine

WORKDIR /app

# Install air for hot-reloading
RUN go install github.com/air-verse/air@latest

# Copy go.mod and go.sum
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Expose port
EXPOSE 8080

# Run air for hot-reloading
CMD ["air", "-c", ".air.toml"] 