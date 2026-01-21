# Multi-stage build for optimized nginx image
FROM nginx:alpine

LABEL maintainer="FishcakeLab"
LABEL description="Fishcake RPC Nginx Load Balancer"

# Install required packages for health checks and SSL
RUN apk add --no-cache \
    wget \
    ca-certificates \
    tzdata

# Set timezone
ENV TZ=UTC

# Remove default nginx configuration
RUN rm -f /etc/nginx/conf.d/default.conf \
    && rm -f /etc/nginx/nginx.conf

# Create necessary directories
RUN mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /etc/nginx/conf.d

# Copy custom nginx configuration
# Note: nginx.conf will be provided via ConfigMap in Kubernetes
# For local testing, you can uncomment the line below
# COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /var/cache/nginx \
    && chmod -R 755 /var/log/nginx

# Expose HTTP port
EXPOSE 80

# Health check configuration
# Checks if nginx is responding on /health endpoint
HEALTHCHECK --interval=30s \
    --timeout=3s \
    --start-period=5s \
    --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Use non-root user for better security (optional, nginx:alpine already uses nginx user)
USER nginx

# Start nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
