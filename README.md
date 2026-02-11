# FailSafe Dashboard - Multi-Website Hosting Setup

This directory hosts multiple websites under a single domain using Docker and Nginx reverse proxy.

## 🌐 URL Structure

- `failsafe.amd.com/` → Static landing page
- `failsafe.amd.com/silicon-trace/` → Silicon Trace Streamlit dashboard
- `failsafe.amd.com/api/` → Silicon Trace FastAPI backend

## 🏗️ Architecture

```
Internet (Port 80/443)
         ↓
    Nginx (Reverse Proxy)
         ↓
    ├─→ Static Site (HTML/CSS/JS)
    ├─→ Streamlit Dashboard (Port 8501)
    └─→ FastAPI Backend (Port 8000)
         ↓
    PostgreSQL Database (Internal only)
```

## 🚀 Quick Start

### Start All Services

```bash
cd /home/ajayad/FailSafeDashboard
docker-compose up -d
```

### Stop All Services

```bash
docker-compose down
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f silicon_trace_frontend
docker-compose logs -f silicon_trace_backend
docker-compose logs -f nginx
```

### Rebuild After Code Changes

```bash
# Rebuild all
docker-compose up -d --build

# Rebuild specific service
docker-compose up -d --build silicon_trace_frontend
```

## 📁 Project Structure

```
FailSafeDashboard/
├── docker-compose.yml          # Master orchestrator
├── nginx.conf                  # Reverse proxy configuration
├── failsafedashboard.github.io/  # Static landing page
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── assets/
└── Silicon-Trace/              # Hardware failure analysis tool
    ├── backend/                # FastAPI application
    │   ├── main.py            # (Modified: root_path="/api")
    │   ├── Dockerfile
    │   └── ...
    ├── frontend/               # Streamlit dashboard
    │   ├── app.py             # (Modified: API_URL env var)
    │   ├── Dockerfile         # (New: baseUrlPath config)
    │   └── ...
    └── docker-compose.yml     # (Updated: Added frontend service)
```

## ✅ Testing

After starting services, verify each endpoint:

```bash
# Health check
curl http://localhost/health

# Static site
curl http://localhost/

# Streamlit (should return HTML)
curl http://localhost/silicon-trace/

# FastAPI
curl http://localhost/api/

# FastAPI docs (in browser)
http://localhost/api/docs
```

## 🔧 Configuration Changes Made

### 1. FastAPI Backend (`Silicon-Trace/backend/main.py`)
- Added `root_path="/api"` to FastAPI app initialization
- All routes automatically prefixed with `/api`

### 2. Streamlit Frontend (`Silicon-Trace/frontend/app.py`)
- Changed `BACKEND_URL` to use environment variable
- Falls back to `http://localhost:8000` for local development

### 3. Streamlit Dockerfile (`Silicon-Trace/frontend/Dockerfile`)
- Created new Dockerfile with `--server.baseUrlPath=/silicon-trace`
- Configures Streamlit to run at subpath

### 4. Silicon-Trace docker-compose.yml
- Added `frontend` service
- Removed exposed ports (internal communication only)
- Added Docker network for service communication

### 5. Master docker-compose.yml
- Orchestrates all services (Nginx, Backend, Frontend, Database)
- Only Nginx exposed to host (ports 80/443)

### 6. Nginx Configuration (`nginx.conf`)
- Routes `/` to static site
- Routes `/silicon-trace/` to Streamlit with WebSocket support
- Routes `/api/` to FastAPI with file upload support

## 🔐 Security Notes

- Database is not exposed to host (internal network only)
- File upload limit set to 100MB
- CORS configured in FastAPI backend
- Consider adding HTTPS/SSL for production

## 🐛 Troubleshooting

### Services won't start
```bash
# Check for port conflicts
sudo netstat -tulpn | grep -E ':(80|443|8000|8501|5432)'

# Check Docker logs
docker-compose logs
```

### Can't access services
```bash
# Verify containers are running
docker-compose ps

# Check Nginx config syntax
docker exec failsafe_nginx nginx -t
```

### Database connection issues
```bash
# Check database health
docker exec silicon_trace_db pg_isready -U silicon_user
```

### Streamlit WebSocket errors
- Ensure proxy_set_header Upgrade and Connection are set in nginx.conf
- Check browser console for WebSocket connection errors

## 🔄 Updating Code

After making code changes:

```bash
# Backend changes
docker-compose restart silicon_trace_backend

# Frontend changes (if Dockerfile changed)
docker-compose up -d --build silicon_trace_frontend

# Frontend changes (if only app.py changed)
docker-compose restart silicon_trace_frontend
```

## 📝 DNS Configuration

Point your domain to this server:

```
failsafe.amd.com  A  <YOUR_SERVER_IP>
```

## 🚀 Production Recommendations

1. **Enable HTTPS**: Use Let's Encrypt with Certbot
2. **Environment Variables**: Move sensitive data to `.env` files
3. **Backups**: Regular database backups
4. **Monitoring**: Add health check endpoints
5. **Logging**: Configure log rotation
6. **Security**: Update CORS settings in FastAPI
