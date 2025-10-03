# WPPConnect Server - Railway Deployment Guide

Complete guide for deploying WPPConnect Server to Railway.app with optimized Puppeteer/Chromium configuration.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Option 1: Deploy from GitHub](#option-1-deploy-from-github-recommended)
  - [Option 2: Deploy via Railway Dashboard](#option-2-deploy-via-railway-dashboard)
  - [Option 3: Deploy Pre-built Docker Image](#option-3-deploy-pre-built-docker-image-easiest)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Alternative: Browserless Integration](#alternative-browserless-integration)

---

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **GitHub Repository**: Your wppconnect-server code pushed to GitHub
3. **Railway CLI** (Optional): `npm i -g @railway/cli`

---

## Quick Start

### Option 1: Deploy from GitHub (Recommended)

1. **Connect Repository**
   ```bash
   # Login to Railway
   railway login

   # Initialize project
   railway init

   # Link to your repo
   railway link
   ```

2. **Push Configuration Files**
   Ensure these files are in your repository root:
   - `railway.json` - Service configuration
   - `nixpacks.toml` - Puppeteer dependencies
   - `.railwayignore` - Build optimization
   - `.env.example` - Environment template

3. **Deploy**
   ```bash
   git add .
   git commit -m "Add Railway configuration"
   git push origin main
   ```

   Railway will automatically detect changes and deploy.

### Option 2: Deploy via Railway Dashboard

1. Go to [railway.app/new](https://railway.app/new)
2. Click "Deploy from GitHub repo"
3. Select your wppconnect-server repository
4. Railway will automatically use `nixpacks.toml` configuration
5. Configure environment variables (see below)

### Option 3: Deploy Pre-built Docker Image (Easiest)

**Best for**: Quick testing or if you don't want to maintain source code.

Using the `luizeof/wppconnect` Docker image:

1. **Create New Project on Railway**
   - Go to [railway.app/new](https://railway.app/new)
   - Click "Empty Service"

2. **Configure Docker Image**
   - Go to Settings → Deploy
   - Change "Source" to "Docker Image"
   - Enter: `luizeof/wppconnect:latest`

3. **Set Environment Variables**
   ```env
   PORT=21465
   SECRET_KEY=<your-secret-key>
   ```

4. **Configure Service**
   - Settings → Networking → Generate Domain
   - Settings → Deploy → Deploy

5. **Access Your API**
   ```
   https://<your-service>.railway.app/api-docs
   ```

**Pros:**
- No source code needed
- Pre-configured Puppeteer
- Faster deployment
- Community-maintained image

**Cons:**
- Less control over configuration
- Depends on image maintainer updates
- May have different defaults than official image

**Alternative Docker Images:**
- `wppconnect/server-cli:latest` - Official image
- `unilogica/wppconnect-server:2.4.0` - Version-specific
- `groliveira/wppconnect-server:v2.4.1` - Community fork

---

## Detailed Setup

### 1. Environment Variables

Configure in Railway Dashboard → Your Service → Variables:

**Required:**
```env
PORT=${{PORT}}              # Auto-provided by Railway
NODE_ENV=production
SECRET_KEY=<generate-strong-key>
```

**Optional:**
```env
WEBHOOK_URL=<your-webhook-url>
WEBHOOK_SECRET=<webhook-secret>
LOG_LEVEL=info
CORS_ORIGIN=*
```

**How to set:**
1. Navigate to your service in Railway
2. Click "Variables" tab
3. Click "New Variable"
4. Add each variable
5. Click "Deploy" to apply changes

### 2. Puppeteer Configuration

The `nixpacks.toml` file installs all required system packages:
- Chrome/Chromium fonts
- Graphics libraries (GTK, GBM)
- Audio libraries
- X11 dependencies

**Puppeteer Launch Args** (verify in your `config.ts`):
```typescript
{
  headless: true,
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-gpu',
    '--disable-software-rasterizer',
    '--disable-extensions'
  ]
}
```

### 3. Volume Configuration (Token Persistence)

Railway doesn't support traditional Docker volumes, but you can use:

**Option A: Database Storage**
- Store session tokens in a PostgreSQL database
- Add Railway Postgres plugin
- Update config.ts to use database

**Option B: Ephemeral Storage**
- Accept that tokens reset on redeploy
- Users must re-scan QR code after each deployment
- Simplest for testing

### 4. Health Check Endpoint

Ensure your server has a health check endpoint at `/api/health`:

```javascript
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});
```

Railway uses this to verify deployment success (configured in `railway.json`).

---

## Configuration

### railway.json

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "watchPatterns": ["src/**", "package.json", "yarn.lock"]
  },
  "deploy": {
    "numReplicas": 1,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3,
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 100,
    "startCommand": "node dist/server.js"
  }
}
```

**Key Settings:**
- `builder: NIXPACKS` - Uses nixpacks.toml for dependencies
- `watchPatterns` - Triggers rebuild only when these files change
- `healthcheckPath` - Railway pings this endpoint to verify deployment
- `restartPolicyType: ON_FAILURE` - Auto-restart on crashes

### nixpacks.toml

Installs system dependencies for Puppeteer. See file for complete package list.

**Key Packages:**
- `chromium` browser
- `fonts-liberation` for text rendering
- `libgtk-3-0` for UI components
- `libnss3` for security

---

## Deployment Workflow

1. **Initial Deploy**
   ```bash
   git push origin main
   ```
   Railway automatically builds and deploys.

2. **Monitor Deployment**
   - Watch logs in Railway Dashboard
   - Check for "Build succeeded" message
   - Verify health check passes

3. **Access API**
   ```
   https://<your-service>.railway.app/api-docs
   ```

4. **Test Session Creation**
   ```bash
   curl -X POST https://<your-service>.railway.app/api/mySession/start-session \
     -H "Authorization: Bearer <token>"
   ```

---

## Troubleshooting

### Issue: "INITIALIZING" Status Hangs

**Symptoms:**
- Session stuck at "INITIALIZING"
- QR code never generates
- High memory usage (~1.1GB)

**Solutions:**

1. **Verify Puppeteer Args**
   ```typescript
   // config.ts
   puppeteer: {
     headless: true,
     args: [
       '--no-sandbox',
       '--disable-setuid-sandbox',
       '--disable-dev-shm-usage'
     ]
   }
   ```

2. **Check Railway Logs**
   ```bash
   railway logs
   ```
   Look for Chrome/Chromium errors.

3. **Increase Memory Allocation**
   - Upgrade Railway plan for more resources
   - Minimum recommended: 1GB RAM

4. **Try New Headless Mode**
   ```typescript
   puppeteer: {
     headless: 'new' // Chrome's new headless mode
   }
   ```

### Issue: Build Fails

**Check:**
1. All dependencies in `package.json` are compatible
2. `nixpacks.toml` is in repository root
3. Node.js version compatibility (check Railway logs)

**Fix:**
```bash
# Update Node.js version in package.json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### Issue: Port Binding Error

**Ensure:**
```javascript
const PORT = process.env.PORT || 21465;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

Railway automatically sets `$PORT` - your app must use it.

### Issue: Session Tokens Lost After Redeploy

**Expected Behavior:**
Railway uses ephemeral storage. Sessions reset on redeploy.

**Solutions:**
1. Use PostgreSQL for persistent token storage
2. Implement token backup/restore mechanism
3. Accept re-authentication after deploys (testing/development)

---

## Performance Optimization

### 1. Resource Limits

**Recommended Railway Plan:**
- Hobby: 1GB RAM, 1 vCPU (minimum)
- Pro: 2GB+ RAM for production (multiple sessions)

### 2. Concurrent Sessions

Adjust based on Railway plan:
```typescript
// config.ts
maxListeners: 5 // Start conservative, increase based on performance
```

### 3. Build Caching

Railway caches `node_modules` between builds. Use `yarn.lock` or `package-lock.json` for consistency.

---

## Alternative: Browserless Integration

If Puppeteer proves unreliable on Railway, use Browserless:

### Step 1: Add Browserless Service

1. Go to Railway Dashboard
2. Click "New" → "Template"
3. Search "Browserless"
4. Deploy Browserless template

### Step 2: Configure WPPConnect

1. Install `puppeteer-core` instead of `puppeteer`:
   ```bash
   yarn remove puppeteer
   yarn add puppeteer-core
   ```

2. Update config.ts:
   ```typescript
   puppeteer: {
     browserWSEndpoint: process.env.BROWSER_WS_ENDPOINT
   }
   ```

3. Add Environment Variable:
   ```
   BROWSER_WS_ENDPOINT=${{Browserless.BROWSER_WS_ENDPOINT}}
   ```

**Pros:**
- Dedicated browser service
- Better reliability
- Optimized for Railway

**Cons:**
- Additional service cost
- Slightly more complex setup

---

## Monitoring & Maintenance

### Railway Logs

```bash
# View real-time logs
railway logs

# Filter by keyword
railway logs | grep "error"
```

### Health Monitoring

Set up monitoring tools:
- [UptimeRobot](https://uptimerobot.com/) - Free health check monitoring
- [Better Uptime](https://betteruptime.com/) - Advanced monitoring
- Railway's built-in metrics

### Backup Strategy

1. **Export Sessions Regularly**
   - Use API endpoints to export session data
   - Store in external database or file storage

2. **Version Control**
   - Keep config.ts in version control
   - Document environment variable changes

---

## Security Considerations

### 1. Secret Key Management

Generate strong secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Add to Railway Variables (never commit to Git).

### 2. CORS Configuration

```typescript
// config.ts
cors: {
  origin: process.env.CORS_ORIGIN || 'https://yourdomain.com'
}
```

### 3. Rate Limiting

Implement rate limiting to prevent abuse:
```typescript
// Example using express-rate-limit
const rateLimit = require('express-rate-limit');
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);
```

---

## Cost Estimates

**Railway Pricing (as of 2025):**
- Hobby Plan: $5/month (512MB RAM, shared CPU)
- Pro Plan: Pay-as-you-go ($0.000463/GB-hour RAM)

**Estimated Monthly Costs:**
- Single instance (1GB RAM): ~$5-10/month
- With Browserless: +$5-15/month
- Production (2GB+ RAM): $15-30/month

---

## Resources

- [Railway Documentation](https://docs.railway.com/)
- [WPPConnect Server GitHub](https://github.com/wppconnect-team/wppconnect-server)
- [WPPConnect API Docs](https://wppconnect.io/swagger/wppconnect-server/)
- [Railway Discord](https://discord.gg/railway) - Community support
- [Puppeteer on Railway Template](https://railway.com/template/puppeteer-ts)

---

## Support

**Issues with WPPConnect:**
- GitHub: https://github.com/wppconnect-team/wppconnect-server/issues
- Discord: https://discord.gg/wppconnect

**Issues with Railway:**
- Help Station: https://help.railway.app
- Discord: https://discord.gg/railway
- Twitter: @Railway

---

## Quick Reference Commands

```bash
# Deploy
git push origin main

# View logs
railway logs

# Open deployed app
railway open

# Run local development
railway run npm run dev

# List environment variables
railway variables

# Restart service
railway restart
```

---

## Next Steps

1. ✅ Push configuration files to GitHub
2. ✅ Deploy to Railway
3. ✅ Configure environment variables
4. ✅ Test session creation
5. ✅ Monitor logs for errors
6. ✅ Set up health monitoring
7. ✅ Configure webhooks (if needed)

Good luck with your deployment! 🚀
