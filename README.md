# FailSafe Dashboard - Multi-Website Hosting Setup

This repository hosts multiple web applications under a single domain (`failsafe.amd.com`) using Docker Compose and an Nginx reverse proxy. It contains four git submodules for the individual projects.

## 🌐 URL Structure

All services are accessible through Nginx on **port 80**:

| URL | Application | Description |
|-----|-------------|-------------|
| `failsafe.amd.com/` | Static Landing Page | Main portal with links to all apps |
| `failsafe.amd.com/silicon-trace/` | Silicon Trace Dashboard | Streamlit-based hardware failure analysis |
| `failsafe.amd.com/api/` | Silicon Trace API | FastAPI backend for Silicon Trace |
| `failsafe.amd.com/api/docs` | Silicon Trace API Docs | Swagger/OpenAPI interactive docs |
| `failsafe.amd.com/silicon-trace-docs/` | Silicon Trace Docs | MkDocs documentation site |
| `failsafe.amd.com/lab-dashboard/` | L3 Debug Lab Dashboard | React-based lab system management |
| `failsafe.amd.com/lab-dashboard-api/docs` | Lab Dashboard API Docs | Swagger/OpenAPI interactive docs |
| `failsafe.amd.com/L3-Debug-Doc/` | L3 Debug Documentation | MkDocs documentation site |
| `failsafe.amd.com/adminer/` | Adminer | Lightweight database browser |
| `failsafe.amd.com:3000` | DrawDB | Database schema visualizer |
| `failsafe.amd.com/health` | Health Check | Returns `healthy` if Nginx is up |

## 🏗️ Architecture

```
Internet (Port 80)
         │
    Nginx (Reverse Proxy)
         │
    ├─→ /                      → Static Site (HTML/CSS/JS)
    ├─→ /silicon-trace/        → Streamlit Dashboard (internal :8501)
    ├─→ /api/                  → Silicon Trace FastAPI (internal :8000)
    ├─→ /silicon-trace-docs/   → MkDocs Static Site
    ├─→ /lab-dashboard/        → React/Vite Frontend (internal :5173)
    ├─→ /lab-dashboard-api/    → L3 Debug FastAPI (internal :8000)
    ├─→ /L3-Debug-Doc/         → MkDocs Static Site
    ├─→ /adminer/              → Adminer (internal :8080)
    └─→ :3000                  → DrawDB (direct port)
         │
    Databases & Services
    ├─→ PostgreSQL (Silicon Trace) - internal :5432
    ├─→ PostgreSQL (L3 Debug)     - internal :5432
    ├─→ Redis (L3 Debug)          - internal :6379
    ├─→ Elasticsearch (L3 Debug)  - internal :9200
    └─→ MCP Server (Silicon Trace)- internal :8000
```

## 🐳 Docker Services & Ports

| Service | Container Name | Internal Port | External Port | Description |
|---------|---------------|---------------|---------------|-------------|
| **Nginx** | `failsafe_nginx` | 80 | **80** | Reverse proxy / entry point |
| **Silicon Trace DB** | `silicon_trace_db` | 5432 | **5432** | PostgreSQL 16 for Silicon Trace |
| **Silicon Trace MCP** | `silicon_trace_mcp` | 8000 | **8300** | MCP server for AI tools |
| **Silicon Trace Backend** | `silicon_trace_backend` | 8000 | — | FastAPI (proxied via `/api/`) |
| **Silicon Trace Frontend** | `silicon_trace_frontend` | 8501 | — | Streamlit (proxied via `/silicon-trace/`) |
| **L3 Debug DB** | `l3debug_postgres` | 5432 | **5433** | PostgreSQL 16 for Lab Dashboard |
| **L3 Debug Redis** | `l3debug_redis` | 6379 | **6379** | Redis 7 cache |
| **L3 Debug Elasticsearch** | `l3debug_elasticsearch` | 9200 | **9200** | Elasticsearch 8.12.2 for search |
| **L3 Debug Backend** | `l3debug_backend` | 8000 | **8001** | FastAPI (proxied via `/lab-dashboard-api/`) |
| **L3 Debug Frontend** | `l3debug_frontend` | 5173 | **5173** | React/Vite (proxied via `/lab-dashboard/`) |
| **Adminer** | `adminer` | 8080 | **8080** | Database browser (proxied via `/adminer/`) |
| **DrawDB** | `drawdb` | 80 | **3000** | Database schema visualizer |

## 🚀 Quick Start

### Start All Services

```bash
cd /home/ajayad/FailSafeDashboard
./start.sh
# or
docker-compose up -d
```

### Stop All Services

```bash
./stop.sh
# or
docker-compose down
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f silicon_trace_frontend
docker-compose logs -f l3debug_backend
docker-compose logs -f nginx
```

### Rebuild After Code Changes

```bash
# Rebuild all
docker-compose up -d --build

# Rebuild specific service
docker-compose up -d --build silicon_trace_frontend
docker-compose up -d --build l3debug_backend
```

## 📁 Project Structure

```
FailSafeDashboard/
├── docker-compose.yml              # Master orchestrator (12 services)
├── nginx.conf                      # Reverse proxy routing
├── nginx.Dockerfile                # Nginx image with static files
├── start.sh / stop.sh              # Convenience scripts
├── failsafedashboard.github.io/    # Static landing page (submodule)
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── assets/
├── Silicon-Trace/                  # Hardware failure analysis (submodule)
│   ├── backend/                    # FastAPI app (root_path="/api")
│   ├── frontend/                   # Streamlit dashboard
│   └── docs/                       # MkDocs documentation
├── L3_Debug/                       # L3 Debug tools & lab dashboard (submodule)
│   ├── webapp/
│   │   ├── backend/                # FastAPI app
│   │   └── frontend/               # React/Vite app
│   └── docs/                       # MkDocs documentation
└── swinfra-agent-mcp-platform/     # MCP server platform (submodule)
    └── src/servers/silicon_trace/   # Silicon Trace MCP server
```

## ✅ Testing

After starting services, verify each endpoint:

```bash
# Health check
curl http://failsafe.amd.com/health

# Static landing page
curl -s http://failsafe.amd.com/ | head -5

# Silicon Trace - Streamlit
curl -s http://failsafe.amd.com/silicon-trace/ | head -5

# Silicon Trace - FastAPI
curl http://failsafe.amd.com/api/docs

# Lab Dashboard - React
curl -s http://failsafe.amd.com/lab-dashboard/ | head -5

# Lab Dashboard - FastAPI
curl http://failsafe.amd.com/lab-dashboard-api/docs

# Databases
docker exec silicon_trace_db pg_isready -U silicon_user
docker exec l3debug_postgres pg_isready -U postgres
docker exec l3debug_redis redis-cli ping
curl -s http://localhost:9200/_cluster/health | python3 -m json.tool
```

## 🔐 Security Notes

- All traffic routed through Nginx (port 80) — only necessary ports exposed
- File upload limits: 100MB (API), 200MB (Streamlit)
- CORS configured in both FastAPI backends
- GitHub Enterprise OAuth (github.amd.com) for Lab Dashboard authentication

## 🐛 Troubleshooting

### Services won't start
```bash
# Check for port conflicts
sudo netstat -tulpn | grep -E ':(80|3000|5173|5432|5433|6379|8001|8080|8300|9200)'

# Check Docker logs
docker-compose logs --tail=50
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
# Silicon Trace DB
docker exec silicon_trace_db pg_isready -U silicon_user

# L3 Debug DB
docker exec l3debug_postgres pg_isready -U postgres
```

### WebSocket errors (Streamlit or Vite HMR)
- Ensure `proxy_set_header Upgrade` and `Connection "upgrade"` are set in nginx.conf
- Check browser console for WebSocket connection errors

## 🔄 Updating Code

After making code changes:

```bash
# Silicon Trace backend
docker-compose restart silicon_trace_backend

# Silicon Trace frontend (Streamlit)
docker-compose up -d --build silicon_trace_frontend

# Lab Dashboard backend
docker-compose restart l3debug_backend

# Lab Dashboard frontend (React/Vite - picks up changes via HMR in dev)
docker-compose restart l3debug_frontend
```

## 📝 DNS Configuration

Point your domain to this server:

```
failsafe.amd.com  A  <SERVER_IP>
```

Host: `xsjengvm210143`

## 🚀 Production Recommendations

1. **Enable HTTPS**: Use Let's Encrypt with Certbot
2. **Environment Variables**: Move secrets to `.env` files
3. **Backups**: Regular PostgreSQL database backups
4. **Monitoring**: Use `/health` endpoint with uptime monitoring
5. **Logging**: Configure log rotation for Docker containers
6. **Security**: Restrict external port exposure, update CORS settings
