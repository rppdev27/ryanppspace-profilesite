# Build stage
FROM node:18-alpine as build

# Set working directory
WORKDIR /app

# Copy package files for efficient caching
COPY package*.json ./

# Install dependencies with clean install for production
RUN npm ci

# Copy all project files
COPY . .

# Build the project
RUN npm run build

# Production stage using lightweight nginx
FROM nginx:alpine

# Copy the built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Set up nginx configuration inline
RUN echo 'server { \
    listen 8080; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 8080
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]