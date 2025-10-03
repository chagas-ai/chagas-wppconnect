# Docker Image Deployment Guide

Quick reference for deploying WPPConnect using pre-built Docker images on Railway.

## Available Docker Images

### 1. luizeof/wppconnect (Community)
```bash
docker pull luizeof/wppconnect:latest
```
- **Maintainer**: Community contributor (luizeof)
- **Best for**: Quick testing and simple deployments
- **Status**: Community-maintained

### 2. wppconnect/server-cli (Official)
```bash
docker pull wppconnect/server-cli:latest
```
- **Maintainer**: WPPConnect Team (Official)
- **Best for**: Production deployments
- **Status**: Actively maintained

### 3. unilogica/wppconnect-server
```bash
docker pull unilogica/wppconnect-server:2.4.0
```
- **Maintainer**: Unilogica
- **Best for**: Version-locked deployments
- **Latest Version**: 2.4.0

### 4. groliveira/wppconnect-server
```bash
docker pull groliveira/wppconnect-server:v2.4.1
```
- **Maintainer**: Community contributor
- **Best for**: Alternative fork with custom features
- **Latest Version**: 2.4.1

---

## Railway Deployment

### Quick Deploy (5 minutes)

1. **Create Service**
   ```
   Railway Dashboard → New Project → Empty Service
   ```

2. **Configure Source**
   ```
   Settings → Source → Docker Image
   Image: luizeof/wppconnect:latest
   ```

3. **Environment Variables**
   ```env
   PORT=21465
   SECRET_KEY=<generate-random-key>
   NODE_ENV=production
   ```

4. **Generate Domain**
   ```
   Settings → Networking → Generate Domain
   ```

5. **Deploy**
   ```
   Deployments → Trigger Deploy
   ```

6. **Test**
   ```bash
   curl https://<your-domain>.railway.app/api-docs
   ```

---

## Local Docker Deployment

### Using docker run

```bash
# Pull image
docker pull luizeof/wppconnect:latest

# Run container
docker run -d \
  --name wppconnect \
  -p 21465:21465 \
  -e SECRET_KEY=your_secret_key \
  -v $(pwd)/tokens:/usr/src/wpp-server/tokens \
  luizeof/wppconnect:latest
```

### Using docker-compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  wppconnect:
    image: luizeof/wppconnect:latest
    container_name: wppconnect-server
    restart: unless-stopped
    ports:
      - "21465:21465"
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - NODE_ENV=production
      - PORT=21465
    volumes:
      - ./tokens:/usr/src/wpp-server/tokens
      - ./config.ts:/usr/src/wpp-server/config.ts
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:21465/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

Run:
```bash
docker-compose up -d
```

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | 21465 | Server port |
| `SECRET_KEY` | Yes | - | Token generation secret |
| `NODE_ENV` | No | development | Environment mode |
| `WEBHOOK_URL` | No | - | Webhook endpoint |
| `LOG_LEVEL` | No | info | Logging level |

### Generate Secret Key

```bash
# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Using OpenSSL
openssl rand -hex 32

# Using Python
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

## Volume Mounts

### Token Persistence

**Important**: WhatsApp session tokens need persistent storage.

```bash
# Create volume
docker volume create wppconnect_tokens

# Use volume
docker run -d \
  -v wppconnect_tokens:/usr/src/wpp-server/tokens \
  luizeof/wppconnect:latest
```

**Railway**: Use Railway's volume feature:
```
Settings → Variables → Add Volume
Mount Path: /usr/src/wpp-server/tokens
```

### Custom Configuration

Mount your own `config.ts`:

```bash
docker run -d \
  -v $(pwd)/config.ts:/usr/src/wpp-server/config.ts:ro \
  luizeof/wppconnect:latest
```

---

## Health Checks

### Docker Health Check

```bash
# Check container health
docker ps

# View health check logs
docker inspect --format='{{.State.Health.Status}}' wppconnect
```

### API Health Endpoint

```bash
# Test health endpoint
curl http://localhost:21465/api/health

# Expected response
{"status":"ok","timestamp":"2025-10-03T..."}
```

---

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker logs wppconnect
```

**Common issues:**
- Port 21465 already in use → Change port mapping
- Missing SECRET_KEY → Set environment variable
- Permission issues → Check volume permissions

### QR Code Not Generating

**Solution 1: Check Puppeteer**
```bash
docker logs wppconnect | grep -i puppeteer
```

**Solution 2: Verify Browser**
```bash
docker exec wppconnect which chromium
```

**Solution 3: Restart Container**
```bash
docker restart wppconnect
```

### Session Tokens Lost

**Problem**: Tokens disappear after container restart

**Solution**: Verify volume mount
```bash
docker inspect wppconnect | grep -A 10 Mounts
```

### High Memory Usage

**Monitor resources:**
```bash
docker stats wppconnect
```

**Limit memory:**
```bash
docker run -d \
  --memory="1g" \
  --memory-swap="2g" \
  luizeof/wppconnect:latest
```

---

## Image Comparison

| Feature | luizeof | server-cli | unilogica | groliveira |
|---------|---------|------------|-----------|------------|
| **Official** | ❌ | ✅ | ❌ | ❌ |
| **Latest Tag** | ✅ | ✅ | ❌ | ✅ |
| **Version Lock** | ❌ | ✅ | ✅ | ✅ |
| **Size** | ~800MB | ~850MB | ~820MB | ~810MB |
| **Updates** | Community | Official | Periodic | Community |
| **Puppeteer** | ✅ | ✅ | ✅ | ✅ |
| **Multi-arch** | ❓ | ✅ | ❓ | ❓ |

**Recommendation**:
- **Production**: `wppconnect/server-cli:latest` (Official)
- **Testing**: `luizeof/wppconnect:latest` (Easy setup)
- **Stable**: `unilogica/wppconnect-server:2.4.0` (Version-locked)

---

## Railway-Specific Tips

### 1. Use Health Checks

Railway needs a health check endpoint to verify deployment:

```toml
# railway.toml
[deploy]
healthcheckPath = "/api/health"
healthcheckTimeout = 100
```

### 2. Configure Restart Policy

```toml
[deploy]
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3
```

### 3. Monitor Logs

```bash
# Railway CLI
railway logs --tail

# Filter errors
railway logs | grep ERROR
```

### 4. Resource Limits

Railway auto-scales, but you can set limits:
```
Settings → Resources
Memory: 1GB (minimum)
CPU: Shared (default)
```

---

## Security Best Practices

### 1. Environment Variables

**Never commit secrets:**
```bash
# .gitignore
.env
*.key
config.ts
```

### 2. Secret Generation

Use strong secrets:
```bash
# Bad
SECRET_KEY=12345

# Good
SECRET_KEY=a8f5f167f44f4964e6c998dee827110c03b42e7f726c0d27964f89a29c9e3c0d
```

### 3. Network Security

**Limit access:**
```yaml
# docker-compose.yml
networks:
  wpp-network:
    driver: bridge
```

**Use Railway's private networking** for internal services.

### 4. Update Regularly

```bash
# Pull latest image
docker pull luizeof/wppconnect:latest

# Recreate container
docker-compose up -d --force-recreate
```

---

## Next Steps

1. ✅ Choose a Docker image
2. ✅ Deploy to Railway
3. ✅ Configure environment variables
4. ✅ Test session creation
5. ✅ Set up monitoring
6. ✅ Configure webhooks (optional)
7. ✅ Implement backup strategy

---

## Resources

- [Docker Hub - luizeof/wppconnect](https://hub.docker.com/r/luizeof/wppconnect)
- [Docker Hub - wppconnect/server-cli](https://hub.docker.com/r/wppconnect/server-cli)
- [WPPConnect Official Docs](https://wppconnect.io/)
- [Railway Docker Deployment](https://docs.railway.com/deploy/dockerfiles)
- [WPPConnect GitHub](https://github.com/wppconnect-team/wppconnect-server)

---

## Support

**WPPConnect Issues:**
- GitHub: https://github.com/wppconnect-team/wppconnect-server/issues
- Discord: https://discord.gg/wppconnect

**Railway Issues:**
- Help Station: https://help.railway.app
- Discord: https://discord.gg/railway

**Docker Issues:**
- Docker Forums: https://forums.docker.com/
- Stack Overflow: `docker` + `wppconnect` tags
