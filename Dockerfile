# ---------- Stage 1: Build React app ----------
FROM node:14 AS build

# Working directory
WORKDIR /app

# Copy dependency files first (cache optimization)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .




# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:1.23-alpine




# Expose HTTP port
EXPOSE 80

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]
