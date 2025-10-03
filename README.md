# WPPConnect Deployment Project

Deploy [WPPConnect Server](https://github.com/wppconnect-team/wppconnect-server) locally and to Railway using the pre-built `luizeof/wppconnect` Docker image.

## 🎯 Quick Start

**Run locally in 2 commands:**
```bash
./start-local.sh
# Open http://localhost:21465/api-docs
```

**Deploy to Railway in 5 minutes:** See [QUICKSTART.md](QUICKSTART.md)

---

## 📚 Documentation

| File | Description |
|------|-------------|
| **[QUICKSTART.md](QUICKSTART.md)** | ⚡ Start here! Local setup + Railway deployment in 10 minutes |
| **[RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)** | 📖 Complete Railway deployment guide with troubleshooting |
| **[DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md)** | 🐳 Docker image details and deployment options |

---

## 🚀 What's Included

### Local Development
- ✅ **docker-compose.local.yml** - Run WPPConnect locally
- ✅ **start-local.sh** - One-command startup script
- ✅ **.mise.toml** - Task runner shortcuts (`mise run local-start`, `mise run local-logs`, etc.)
- ✅ **.env** - Local environment configuration
- ✅ **tokens/** - Persistent WhatsApp session storage

### Railway Deployment
- ✅ **railway.toml** - Railway service configuration
- ✅ **nixpacks.toml** - Puppeteer dependencies for Nixpacks
- ✅ **Dockerfile.railway** - Railway-optimized Dockerfile
- ✅ **.railwayignore** - Build optimization

---

## 🛠️ Features

- **Pre-built Docker Image**: Uses `luizeof/wppconnect:latest` - no build required
- **WhatsApp Multi-Session**: Manage multiple WhatsApp sessions
- **REST API**: Full REST API with Swagger documentation
- **QR Code Authentication**: Easy WhatsApp Web connection
- **Webhook Support**: Real-time message notifications
- **Token Persistence**: Session data survives container restarts
- **Health Checks**: Built-in health monitoring endpoints

---

## 📦 Available Docker Images

| Image | Maintainer | Status | Best For |
|-------|------------|--------|----------|
| `luizeof/wppconnect:latest` | Community | Active | Quick testing |
| `wppconnect/server-cli:latest` | Official | Active | Production |
| `unilogica/wppconnect-server:2.4.0` | Community | Stable | Version-locked |
| `groliveira/wppconnect-server:v2.4.1` | Community | Active | Alternative fork |

This project uses `luizeof/wppconnect:latest` by default. See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for other options.

---

## 🔧 Local Development

### Prerequisites
- Docker Desktop installed and running
- (Optional) [mise](https://mise.jdx.dev/) for task shortcuts
- (Optional) Node.js for secret generation

### Quick Commands

```bash
# Start server
./start-local.sh
# or
mise run local-start

# View logs
mise run local-logs

# Stop server
mise run local-stop

# Generate SECRET_KEY
mise run generate-secret

# Test API
mise run test-api

# List all available tasks
mise tasks
```

### Manual Setup

```bash
# 1. Pull Docker image
docker pull luizeof/wppconnect:latest

# 2. Start container
docker-compose -f docker-compose.local.yml up -d

# 3. View logs
docker-compose -f docker-compose.local.yml logs -f

# 4. Access API
open http://localhost:21465/api-docs
```

---

## ☁️ Railway Deployment

### Option 1: Docker Image (Fastest)

1. Create empty service on Railway
2. Settings → Source → Docker Image
3. Enter: `luizeof/wppconnect:latest`
4. Add environment variables:
   ```
   SECRET_KEY=<your-secret>
   PORT=21465
   NODE_ENV=production
   ```
5. Generate domain and deploy

### Option 2: Deploy from GitHub

1. Push this repository to GitHub
2. Railway → New Project → Deploy from GitHub
3. Select repository
4. Add environment variables
5. Deploy automatically on push

### Option 3: Railway CLI

```bash
# Install CLI
npm i -g @railway/cli

# Login
railway login

# Initialize
railway init

# Deploy
railway up
```

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

---

## 🔑 Configuration

### Required Environment Variables

```env
SECRET_KEY=your_secret_key_here  # Generate with: make generate-secret
PORT=21465                       # Server port
NODE_ENV=production              # Environment mode
```

### Optional Environment Variables

```env
WEBHOOK_URL=https://your-webhook.com/endpoint
WEBHOOK_SECRET=your_webhook_secret
LOG_LEVEL=info
CORS_ORIGIN=*
```

---

## 📖 API Documentation

Once running, access the Swagger UI:

- **Local**: http://localhost:21465/api-docs
- **Railway**: https://your-service.railway.app/api-docs

### Key Endpoints

```bash
# Health check
GET /api/health

# Generate token
POST /api/{session}/generate-token

# Start session
POST /api/{session}/start-session

# Send message
POST /api/{session}/send-message

# Get QR code
GET /api/{session}/qrcode

# Check status
GET /api/{session}/status
```

---

## 🧪 Testing

### Local Testing

```bash
# Health check
curl http://localhost:21465/api/health

# Response: {"status":"ok","timestamp":"2025-10-03T..."}
```

### Railway Testing

```bash
# Health check
curl https://your-service.railway.app/api/health

# Generate token
curl -X POST https://your-service.railway.app/api/mySession/generate-token \
  -H "Content-Type: application/json" \
  -d '{"secret": "your_secret_key"}'
```

---

## 📁 Project Structure

```
chagas-wppconnect/
├── README.md                    # This file
├── QUICKSTART.md               # Quick start guide
├── RAILWAY_DEPLOYMENT.md       # Railway deployment guide
├── DOCKER_DEPLOYMENT.md        # Docker deployment guide
│
├── docker-compose.local.yml    # Local Docker Compose
├── start-local.sh              # Local startup script
├── .mise.toml                  # Task runner configuration
│
├── railway.toml                # Railway configuration
├── nixpacks.toml              # Puppeteer dependencies
├── Dockerfile.railway          # Railway Dockerfile
├── .railwayignore             # Railway build optimization
│
├── .env                        # Local environment variables
├── .env.example               # Environment template
│
└── tokens/                     # WhatsApp session storage (gitignored)
```

---

## 🛠️ Troubleshooting

### Common Issues

**Docker not running**
```bash
# Check Docker status
docker info

# Start Docker Desktop
open -a Docker
```

**Port 21465 already in use**
```bash
# Find process
lsof -i :21465

# Change port in .env
PORT=21466
```

**QR code not generating**
- Check Puppeteer logs: `docker logs wppconnect-local`
- Restart container: `make local-restart`
- See [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md#troubleshooting) for Railway-specific issues

**Session tokens lost after restart**
- Verify volume mount in docker-compose.local.yml
- Check tokens/ directory exists and has write permissions

---

## 🆘 Support & Resources

**Documentation:**
- [WPPConnect Official Docs](https://wppconnect.io/)
- [WPPConnect Server GitHub](https://github.com/wppconnect-team/wppconnect-server)
- [Railway Documentation](https://docs.railway.com/)

**Community Support:**
- WPPConnect Discord: https://discord.gg/wppconnect
- WPPConnect GitHub Issues: https://github.com/wppconnect-team/wppconnect-server/issues
- Railway Discord: https://discord.gg/railway
- Railway Help Station: https://help.railway.app

---

## 📝 License

This deployment configuration is provided as-is for use with WPPConnect Server.

WPPConnect Server is licensed under Apache-2.0. See [wppconnect-team/wppconnect-server](https://github.com/wppconnect-team/wppconnect-server) for details.

---

## 🙏 Credits

- **WPPConnect Team** - [github.com/wppconnect-team](https://github.com/wppconnect-team)
- **luizeof** - Docker image maintainer [hub.docker.com/r/luizeof/wppconnect](https://hub.docker.com/r/luizeof/wppconnect)
- **Railway** - Deployment platform [railway.app](https://railway.app)

---

## 🚀 Get Started

Ready to begin? Check out the [QUICKSTART.md](QUICKSTART.md) guide!

```bash
# Local development
./start-local.sh

# Railway deployment
railway login && railway init && railway up
```

Happy coding! 🎉
