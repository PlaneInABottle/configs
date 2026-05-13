## Service Placement Guide

| Service | Recommended Tier | Why |
|---------|-----------------|-----|
| Pi-hole | Tier 1 | Always-on, lightweight, network-wide |
| AdGuard Home | Tier 1 | Same as Pi-hole |
| Uptime Kuma | Tier 1 | Lightweight, always-on |
| Vaultwarden | Tier 1 | Should run 24/7 |
| Mosquitto | Tier 1 | IoT, needs 24/7 |
| Traefik | Tier 2 | Needs uptime, handles traffic |
| Nginx Proxy Manager | Tier 2 | Same as Traefik |
| Jellyfin | Tier 2 | Media + storage access |
| Sonarr/Radarr | Tier 2 | Needs to run scheduled tasks |
| Home Assistant | Tier 2 | Should run 24/7, needs DB |
| Immich | Tier 2 | Needs storage + PostgreSQL |
| Nextcloud | Tier 2 | File storage + DB |
| Ollama/AI | Tier 4 | GPU/hardware intensive |
| Kubernetes | Tier 4 | Requires cluster |
| GitLab | Tier 4 | Resource intensive |
| Proxmox | Tier 4 | Needs bare metal |
| NAS/Storage | Tier 3 | Needs physical drives |
