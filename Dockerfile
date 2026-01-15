# Stage 1: Build Node.js application
FROM node:14 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package.json package-lock.json ./

# Install project dependencies
RUN npm install

# Copy the entire application to the container
COPY . .

# Build the React app (modify the command if necessary)


# Stage 2: Serve the built application with Nginx
FROM nginx:1.23-alpine


# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
