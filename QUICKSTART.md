# WPPConnect Quick Start Guide

Get WPPConnect running locally in 5 minutes and deploy to Railway in 10 minutes.

## 🚀 Local Development

### Prerequisites

- Docker Desktop installed and running
- (Optional) [mise](https://mise.jdx.dev/) installed for shortcuts
- (Optional) Node.js for secret generation

### Step 1: Start Locally

**Option A: Using the start script**
```bash
./start-local.sh
```

**Option B: Using mise**
```bash
mise run local-start
```

**Option C: Using Docker Compose directly**
```bash
# Pull image
docker pull luizeof/wppconnect:latest

# Start container
docker-compose -f docker-compose.local.yml up -d

# View logs
docker-compose -f docker-compose.local.yml logs -f
```

### Step 2: Configure Environment

1. **Edit `.env` file**:
   ```bash
   nano .env
   ```

2. **Generate a strong SECRET_KEY**:
   ```bash
   # Using mise
   mise run generate-secret

   # Or using Node.js
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

3. **Update `.env` with your SECRET_KEY**:
   ```env
   SECRET_KEY=your_generated_secret_key_here
   ```

### Step 3: Access the API

- **Swagger UI**: http://localhost:21465/api-docs
- **Health Check**: http://localhost:21465/api/health

### Step 4: Create a Session

1. Open Swagger UI: http://localhost:21465/api-docs
2. Generate a token using `/api/{session}/generate-token`
3. Use the token to start a session: `/api/{session}/start-session`
4. Scan the QR code with WhatsApp

### Common Local Commands

```bash
# View logs
mise run local-logs
# or
docker-compose -f docker-compose.local.yml logs -f

# Restart container
mise run local-restart

# Stop container
mise run local-stop

# Clean everything (removes tokens!)
mise run local-clean

# Test API
mise run test-api

# Open Swagger UI
mise run test-swagger

# List all available tasks
mise tasks
```

---

## ☁️ Railway Deployment

### Prerequisites

- Railway account: https://railway.app
- Railway CLI (optional): `npm i -g @railway/cli`

### Method 1: Deploy Using Railway Dashboard (Easiest)

1. **Create New Project**
   - Go to https://railway.app/new
   - Click "Empty Service"

2. **Configure Docker Image**
   - Settings → Source → "Docker Image"
   - Enter: `luizeof/wppconnect:latest`

3. **Add Environment Variables**
   - Settings → Variables → "New Variable"
   - Add:
     ```
     SECRET_KEY=<your-secret-key>
     PORT=21465
     NODE_ENV=production
     ```

4. **Generate Domain**
   - Settings → Networking → "Generate Domain"

5. **Deploy**
   - Deployments → "Deploy"

6. **Access Your API**
   ```
   https://<your-service>.railway.app/api-docs
   ```

### Method 2: Deploy from GitHub

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/your-username/your-repo.git
   git push -u origin main
   ```

2. **Connect to Railway**
   - Railway Dashboard → New Project
   - "Deploy from GitHub repo"
   - Select your repository

3. **Configure Environment Variables**
   - Add `SECRET_KEY`, `PORT`, `NODE_ENV` as above

4. **Deploy**
   - Railway will auto-deploy on push

### Method 3: Deploy Using Railway CLI

1. **Install Railway CLI**
   ```bash
   npm i -g @railway/cli
   ```

2. **Login to Railway**
   ```bash
   railway login
   ```

3. **Initialize Project**
   ```bash
   railway init
   ```

4. **Set Environment Variables**
   ```bash
   railway variables set SECRET_KEY=your_secret_key
   railway variables set PORT=21465
   railway variables set NODE_ENV=production
   ```

5. **Deploy**
   ```bash
   railway up
   ```

6. **View Logs**
   ```bash
   railway logs
   ```

---

## 📝 Configuration Files

### Local Development Files
- `docker-compose.local.yml` - Local Docker Compose configuration
- `.env` - Local environment variables
- `start-local.sh` - Startup script
- `.mise.toml` - Task runner configuration

### Railway Deployment Files
- `railway.toml` - Railway configuration
- `nixpacks.toml` - Puppeteer system dependencies
- `Dockerfile.railway` - Railway Dockerfile wrapper
- `.railwayignore` - Files to exclude from deployment

---

## 🔑 Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY` | API token secret | `a8f5f167f44f...` |
| `PORT` | Server port | `21465` |
| `NODE_ENV` | Environment | `production` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `WEBHOOK_URL` | Webhook endpoint | - |
| `WEBHOOK_SECRET` | Webhook secret | - |
| `LOG_LEVEL` | Logging level | `info` |
| `CORS_ORIGIN` | CORS origin | `*` |

---

## 🧪 Testing

### Test Local API

```bash
# Health check
curl http://localhost:21465/api/health

# Expected response
{"status":"ok","timestamp":"2025-10-03T..."}
```

### Test Railway API

```bash
# Health check
curl https://your-service.railway.app/api/health

# Generate token
curl -X POST https://your-service.railway.app/api/mySession/generate-token \
  -H "Content-Type: application/json" \
  -d '{"secret": "your_secret_key"}'

# Start session
curl -X POST https://your-service.railway.app/api/mySession/start-session \
  -H "Authorization: Bearer your_token"
```

---

## 🛠️ Troubleshooting

### Local Issues

**Container won't start**
```bash
# Check Docker is running
docker info

# Check logs
docker-compose -f docker-compose.local.yml logs
```

**Port already in use**
```bash
# Find process using port 21465
lsof -i :21465

# Kill the process or change PORT in .env
```

**Session not generating QR code**
```bash
# Restart container
make local-restart

# Check Puppeteer logs
docker-compose -f docker-compose.local.yml logs | grep -i puppeteer
```

### Railway Issues

**Deployment fails**
- Check environment variables are set
- Verify SECRET_KEY is configured
- Check Railway logs for errors

**API not responding**
- Verify domain is generated
- Check health check status
- Review deployment logs

**Session stuck at INITIALIZING**
- Known issue with Puppeteer on Railway
- Try increasing memory allocation (Railway plan)
- Consider Browserless alternative (see [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md))

---

## 📚 Next Steps

1. ✅ Run locally with `./start-local.sh`
2. ✅ Test API at http://localhost:21465/api-docs
3. ✅ Create a WhatsApp session
4. ✅ Deploy to Railway
5. ✅ Set up monitoring
6. ✅ Configure webhooks (optional)
7. ✅ Read full documentation:
   - [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) - Complete Railway guide
   - [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) - Docker details
   - [WPPConnect Docs](https://wppconnect.io/) - API documentation

---

## 🆘 Support

**Local Issues:**
- Check Docker logs: `docker-compose -f docker-compose.local.yml logs`
- Verify Docker is running: `docker info`

**Railway Issues:**
- Railway Help: https://help.railway.app
- Railway Discord: https://discord.gg/railway

**WPPConnect Issues:**
- GitHub: https://github.com/wppconnect-team/wppconnect-server/issues
- Discord: https://discord.gg/wppconnect

---

## 🎯 Quick Reference

```bash
# Local Development
./start-local.sh              # Start server
mise run local-logs           # View logs
mise run local-stop           # Stop server
mise run test-api             # Test API
mise tasks                    # List all tasks

# Railway Deployment
railway login                 # Login to Railway
railway init                  # Initialize project
railway up                    # Deploy
railway logs                  # View logs

# Generate Secret
mise run generate-secret      # Generate SECRET_KEY
```

Good luck! 🚀
