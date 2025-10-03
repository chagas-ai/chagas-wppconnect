# Railway Dockerfile - Uses pre-built luizeof/wppconnect image
# This is a simple wrapper to deploy the Docker image on Railway

FROM luizeof/wppconnect:latest

# Railway provides PORT environment variable
ENV PORT=21465

# Expose port (Railway will map this dynamically)
EXPOSE ${PORT}

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:${PORT}/api/health || exit 1

# Start command (already defined in base image, but explicit for clarity)
CMD ["node", "dist/server.js"]
