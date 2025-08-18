# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy rest of the app source code
COPY . .

# Expose port 3000
EXPOSE 3000

# Use environment variables from Kubernetes ConfigMap/Secret for API keys
CMD ["node", "server"]
