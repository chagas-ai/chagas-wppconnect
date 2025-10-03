# mise Task Runner Usage Guide

This project uses [mise](https://mise.jdx.dev/) as a task runner for convenient development commands.

## Installation

### Install mise

**macOS (Homebrew):**
```bash
brew install mise
```

**Linux/macOS (curl):**
```bash
curl https://mise.run | sh
```

**Other methods:**
See [mise installation docs](https://mise.jdx.dev/getting-started.html)

### Activate mise

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
eval "$(mise activate bash)"  # for bash
eval "$(mise activate zsh)"   # for zsh
```

Reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## Available Tasks

### List All Tasks

```bash
mise tasks
```

Output:
```
local-start         Start WPPConnect locally with Docker
local-stop          Stop local WPPConnect container
local-logs          View local container logs
local-restart       Restart local container
local-clean         Stop and remove all local data (INCLUDING TOKENS)
railway-deploy      Deploy to Railway (requires Railway CLI)
railway-logs        View Railway logs
test-api            Test local API health
test-swagger        Open Swagger docs in browser
setup-env           Create .env file from example
generate-secret     Generate a random SECRET_KEY
help                Show available tasks
```

---

## Task Reference

### Local Development

#### Start Server
```bash
mise run local-start
```
Starts WPPConnect using the start-local.sh script.

#### Stop Server
```bash
mise run local-stop
```
Stops the Docker container gracefully.

#### View Logs
```bash
mise run local-logs
```
Follows Docker container logs in real-time (Ctrl+C to exit).

#### Restart Server
```bash
mise run local-restart
```
Restarts the Docker container without losing data.

#### Clean Everything
```bash
mise run local-clean
```
⚠️ **WARNING**: Removes all session tokens! Prompts for confirmation.

---

### Railway Deployment

#### Deploy to Railway
```bash
mise run railway-deploy
```
Requires Railway CLI. Deploys current code to Railway.

#### View Railway Logs
```bash
mise run railway-logs
```
Tails Railway deployment logs in real-time.

---

### Testing & Utilities

#### Test API Health
```bash
mise run test-api
```
Checks if the local API is responding at http://localhost:21465/api/health

#### Open Swagger UI
```bash
mise run test-swagger
```
Opens Swagger documentation in your default browser.

#### Setup Environment
```bash
mise run setup-env
```
Creates `.env` file from `.env.example` if it doesn't exist.

#### Generate Secret Key
```bash
mise run generate-secret
```
Generates a cryptographically secure SECRET_KEY for your `.env` file.

Example output:
```
SECRET_KEY=a8f5f167f44f4964e6c998dee827110c03b42e7f726c0d27964f89a29c9e3c0d
```

---

## Quick Examples

### First-Time Setup

```bash
# 1. Setup environment
mise run setup-env

# 2. Generate secret
mise run generate-secret
# Copy the output and add to .env

# 3. Start server
mise run local-start

# 4. Open Swagger UI
mise run test-swagger
```

### Daily Development

```bash
# Start work
mise run local-start

# View logs while developing
mise run local-logs

# Test API
mise run test-api

# Stop work
mise run local-stop
```

### Troubleshooting

```bash
# Check logs
mise run local-logs

# Restart if having issues
mise run local-restart

# Nuclear option - clean everything
mise run local-clean
mise run local-start
```

### Railway Deployment

```bash
# Deploy to Railway
railway login
mise run railway-deploy

# Monitor deployment
mise run railway-logs
```

---

## Task Configuration

Tasks are defined in `.mise.toml` at the project root.

### Example Task Definition

```toml
[tasks.local-start]
description = "Start WPPConnect locally with Docker"
run = "./start-local.sh"
```

### Custom Tasks

You can add your own tasks by editing `.mise.toml`:

```toml
[tasks.my-custom-task]
description = "My custom task description"
run = '''
echo "Running custom task..."
# Your commands here
'''
```

---

## Shortcuts

You can create shell aliases for frequently used tasks:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias wpp-start="mise run local-start"
alias wpp-stop="mise run local-stop"
alias wpp-logs="mise run local-logs"
alias wpp-test="mise run test-api"
```

Then use:
```bash
wpp-start  # instead of mise run local-start
wpp-logs   # instead of mise run local-logs
```

---

## Why mise?

- ✅ **Cross-platform** - Works on macOS, Linux, Windows
- ✅ **No dependencies** - Single binary, no Python/Ruby/etc needed
- ✅ **Version management** - Can also manage Node.js, Python versions
- ✅ **Fast** - Rust-based, extremely fast execution
- ✅ **Standardized** - Single `.mise.toml` file
- ✅ **IDE support** - Compatible with most editors

---

## Comparison with make

| Feature | make | mise |
|---------|------|------|
| Cross-platform | ❌ Windows issues | ✅ All platforms |
| Syntax | Tab-sensitive | TOML format |
| Speed | Fast | Very fast |
| Version management | ❌ No | ✅ Yes |
| Modern tooling | ❌ 1970s | ✅ 2020s |

---

## Advanced Usage

### Run Multiple Tasks

```bash
# Sequential
mise run local-start && mise run test-api

# Background
mise run local-start &
sleep 10
mise run test-api
```

### Task Dependencies

You can define task dependencies in `.mise.toml`:

```toml
[tasks.test-full]
description = "Start server and run tests"
depends = ["local-start"]
run = '''
sleep 5
mise run test-api
'''
```

### Environment Variables

Tasks can use environment variables:

```toml
[tasks.deploy-prod]
description = "Deploy to production"
env = { NODE_ENV = "production" }
run = "railway up"
```

---

## Troubleshooting

### mise: command not found

Make sure mise is installed and activated:
```bash
which mise
eval "$(mise activate zsh)"
```

### Tasks not showing

Check `.mise.toml` syntax:
```bash
cat .mise.toml
```

### Task fails to run

Run with verbose output:
```bash
mise run -v local-start
```

---

## Resources

- [mise Documentation](https://mise.jdx.dev/)
- [mise GitHub](https://github.com/jdx/mise)
- [Task Configuration](https://mise.jdx.dev/tasks/)

---

## Summary

```bash
# Essential commands
mise tasks                    # List all tasks
mise run <task-name>         # Run a task
mise run -v <task-name>      # Verbose output

# Common tasks
mise run local-start         # Start server
mise run local-logs          # View logs
mise run generate-secret     # Generate key
mise run test-api            # Test health
```

Happy coding! 🚀
