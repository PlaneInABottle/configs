# Playbook: Debugging & Profiling

**Goal:** Diagnose issues in running applications using lightweight, language-agnostic tools.

---

## View Application Logs

```bash
# PM2 logs
pm2 logs myapp

# Last 100 lines
pm2 logs myapp --lines 100

# Stream in real-time
pm2 logs myapp --nostream

# Docker logs
docker compose logs app
docker logs --tail 100 container_name
```

---

## Remote Debugging (Node.js)

```bash
# Start with debugging port
NODE_OPTIONS="--inspect=0.0.0.0:9229" pm2 start npm -- run dev

# In Chrome: chrome://inspect
# Add localhost:9229 to Remote Target
```

---

## Remote Debugging (Python)

```bash
# Start with debugging
python -m debugpy --listen 0.0.0.0:5678 -m uvicorn main:app

# Connect from VS Code:
# Use Python: Remote Attach configuration
```

---

## Profile CPU Usage

```bash
# Node.js CPU profiling
node --prof app.js
# After running...
node --prof-process isolate-*.log > processed.txt

# Using 0x (flame graphs)
npx 0x app.js
```

---

## Memory Leak Detection

```bash
# Node.js heap snapshots
# 1. Start app with heap snapshots
node --inspect app.js

# 2. In Chrome DevTools > Memory > Take heap snapshot
# 3. Compare snapshots after performing operations

# Using clinic.js
npx clinic doctor -- node app.js
npx clinic flame -- node app.js
```

---

## Network Debugging

```bash
# Check open connections
lsof -i -P | grep LISTEN

# Trace HTTP requests
curl -v http://localhost:8000/api/test

# Monitor network in container
docker exec container_name tcpdump -i eth0 -w /tmp/capture.pcap
docker cp container_name:/tmp/capture.pcap .
```

---

## Database Query Debugging

```bash
# PostgreSQL query logging
docker exec db psql -U app -d myapp -c "ALTER DATABASE myapp SET log_statement = 'all';"
docker exec db psql -U app -d myapp -c "ALTER DATABASE myapp SET log_min_duration_statement = 0;"

# View logs
docker logs db 2>&1 | grep "SELECT"

# Explain query
docker exec db psql -U app -d myapp -c "EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';"
```

---

## Quick Reference

| Task | Command |
|------|---------|
| PM2 logs | `pm2 logs myapp` |
| Docker logs | `docker compose logs app` |
| Node debug | `node --inspect app.js` |
| Python debug | `python -m debugpy --listen 0.0.0.0:5678` |
| CPU profile | `node --prof app.js` |
| Query debug | `docker exec db psql -c "EXPLAIN ANALYZE ..."` |
