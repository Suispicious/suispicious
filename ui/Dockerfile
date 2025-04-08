FROM node:20-alpine

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN yarn install

# Copy the source code
COPY . .

# Expose port
EXPOSE 3000

# Start the development server
CMD ["yarn", "start"]
