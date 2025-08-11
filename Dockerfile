# Multi-stage build for optimized production image
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files (we'll create a simple package.json)
COPY package*.json ./

# Install dependencies (if any)
RUN npm install --only=production 2>/dev/null || echo "No package.json found, skipping npm install"

# Copy source code
COPY . .

# Production stage
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy website files
COPY --from=builder /app/*.html /usr/share/nginx/html/
COPY --from=builder /app/*.css /usr/share/nginx/html/
COPY --from=builder /app/*.js /usr/share/nginx/html/

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Add labels for better container management
LABEL maintainer="devops-demo@example.com"
LABEL version="1.0"
LABEL description="Demo website for DevOps pipeline demonstration"

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
