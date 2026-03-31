---
name: home-lab
description: "Transform old devices (phones, tablets, computers) into self-hosted servers running useful Docker services. Use when: repurposing old Android phones/tablets as home servers, setting up a home lab with multiple devices, setting up a home lab with Docker containers, asking about self-hosted alternatives to cloud services, guidance on hardware for home lab, running services like media server, photo backup, ad blocker, or understanding how different hardware devices work together."
---

# Home Lab Skill

---

## Device Preparation

### Old Android Phones/Tablets

1. **Factory Reset**: Settings → Reset → Factory data reset
2. **Remove Google Account**: Before resetting, remove FRP lock by removing account from Settings → Accounts
3. **Enable Developer Options**: Settings → About Phone → Tap Build Number 7 times
4. **Enable USB Debugging**: Developer Options → USB Debugging
5. **Keep Screen On** (optional): Developer Options → Stay Awake While Charging

### Old Computers

Recommended models:
- **Dell OptiPlex** (Gen 6-9) - $100-200 on eBay
- **HP EliteDesk** (Gen 6-8) - $100-150
- **Mini PCs** (Intel NUC, Gigabyte Brix, Beelink) - $150-250
- **Raspberry Pi 4/5** - Good starter option

---

## OS Options

### For Android Devices: Termux

**Termux** is a Linux environment for Android that works without rooting.

```bash
# Install Termux from F-Droid (not Google Play - outdated)
# Update packages
pkg update && pkg upgrade

# Install essentials
pkg install git curl wget vim

# Note: Native Docker on Termux requires complex setup
# See: https://github.com/termux/termux-docker
# Alternative: Use user-space Docker alternatives or SSH to another server
```

**Why Termux:**
- ~50MB footprint
- Runs most Linux software
- No root required
- Battery-powered option for low-power servers
- Can run lightweight services directly without Docker

### For Computers: Ubuntu Server / Proxmox

**Ubuntu Server** - Simple, well-documented
```bash
# Download from https://ubuntu.com/download/server
# Create bootable USB with Rufus or Etcher
# Follow installer prompts
```

**Proxmox** - Virtualization platform (run multiple VMs)
```bash
# Download from https://www.proxmox.com/
# Requires bare metal install
# Runs containers and VMs
```

---

## Multi-Device Architecture

A well-designed home lab uses different hardware for different purposes. Here's the 5-tier model:

### Tier 0: Network & Security
| Device | Purpose |
|--------|---------|
| ISP Gateway/ONT | Internet connection |
| pfSense/OPNsense | Firewall, router |
| Managed Switch | Network switching |
| WiFi Access Point | Wireless connectivity |

**Services:** Tailscale VPN, Unbound DNS, VLANs

---

### Tier 1: Lightweight Services (Always-On, Low Power)
Best for: Raspberry Pi, old phone, Docker stick
**Power:** <5W idle

| Service | Description | Docker Image |
|---------|-------------|--------------|
| **Pi-hole** | Network-wide ad blocking | `pihole/pihole` |
| **AdGuard Home** | Privacy DNS + ad blocking | `adguard/adguardhome` |
| **Uptime Kuma** | Service monitoring | `louislam/uptime-kuma` |
| **Vaultwarden** | Password manager | `vaultwarden/server` |
| **ntfy** | Push notifications | `binwiederhier/ntfy` |
| **Mosquitto** | MQTT broker (IoT) | `eclipse-mosquitto` |
| **Baikal** | CalDAV/CardDAV server | `ckulka/baikal` |

---

### Tier 2: Compute & Containers (Main Workloads)
Best for: N100 Mini PC, Dell OptiPlex, Raspberry Pi 5
**Power:** 10-30W

| Service | Description | Docker Image |
|---------|-------------|--------------|
| **Portainer** | Docker management UI | `portainer/portainer-ce` |
| **Traefik** | Reverse proxy + SSL | `traefik:v3` |
| **Nginx Proxy Manager** | GUI reverse proxy | `jc21/nginx-proxy-manager` |
| **Sonarr** | TV show automation | `lscr.io/linuxserver/sonarr` |
| **Radarr** | Movie automation | `lscr.io/linuxserver/radarr` |
| **Prowlarr** | Indexer manager | `lscr.io/linuxserver/prowlarr` |
| **qBittorrent** | Download client | `lscr.io/linuxserver/qbittorrent` |
| **Jellyfin** | Media server | `jellyfin/jellyfin` |
| **Jellyseerr** | Media requests | `lscr.io/linuxserver/jellyseerr` |
| **Navidrome** | Music streaming | `lscr.io/linuxserver/navidrome` |
| **Home Assistant** | Smart home | `homeassistant/home-assistant` |
| **Immich** | Photo backup | `ghcr.io/immich-app/immich` |
| **Nextcloud** | File sync & productivity | `nextcloud` |
| **Authentik** | SSO authentication | `authentik/authentik` |
| **Authelia** | SSO proxy | `authelia/authelia` |

---

### Tier 3: Storage & Media (High Capacity)
Best for: Synology NAS, DIY NAS (OpenMediaVault), external storage
**Power:** 10-40W

| Service | Description | Docker Image |
|---------|-------------|--------------|
| **SMB/CIFS** | File sharing | (native) |
| **NFS** | Network file system | (native) |
| **OpenMediaVault** | NAS OS | (standalone) |
| **TrueNAS Scale** | Enterprise NAS | (standalone) |
| **Frigate** | NVR video surveillance | `ghcr.io/blakeblackshear/frigate` |
| **MotionEye** | Camera system | `ccrisan/motioneye` |

**Use for:** Media storage, backups, Time Machine, photo library

---

### Tier 4: Specialized/AI/Cluster (High Performance)
Best for: Desktop with GPU, Dell R720, Proxmox cluster
**Power:** 50-200W (only when needed)

| Service | Description | Docker Image |
|---------|-------------|--------------|
| **Kubernetes (K3s/Talos)** | Container orchestration | (install) |
| **Proxmox** | Virtualization | (standalone) |
| **Ollama** | Local LLM runtime | `ollama/ollama` |
| **Open WebUI** | ChatGPT-style AI UI | `ghcr.io/open-webui/open-webui` |
| **ComfyUI** | AI image generation | `comfyanonymous/comfyui` |
| **PhotoPrism** | AI photo management | `photoprism/photoprism` |
| **GitLab** | DevOps platform | `gitlab/gitlab-ce` |
| **Jenkins** | CI/CD | `jenkins/jenkins` |

---

## Hardware Recommendations by Budget

### Starter ($0-100)
| Device | Specs | Best For |
|--------|-------|----------|
| Raspberry Pi 4 | 4GB, PoE hat | Pi-hole, Docker (light) |
| Old Android Phone | Any | Termux services |

### Basic ($100-300)
| Device | Specs | Best For |
|--------|-------|----------|
| N100 Mini PC | 8-16GB, 256GB SSD | Main Docker host |
| Raspberry Pi 5 | 8GB | Media server, NAS |
| Dell OptiPlex 7050 | i5-6500T, 32GB | Proxmox node |

### Intermediate ($300-600)
| Device | Specs | Best For |
|--------|-------|----------|
| N100 Mini PC | 16GB, RAID | All-in-one Docker |
| Synology DS223+ | 2× 4TB RAID1 | NAS + media |
| Dell R730 | 2× E5-2680, 128GB | Power compute |

### Advanced ($600+)
| Device | Specs | Best For |
|--------|-------|----------|
| 3× OptiPlex | Cluster | Proxmox HA |
| Beelink GTi 13 | i9, 64GB, iGPU | GPU media transcoding |
| Custom NAS | N100, 6+ bays | Mass storage |

---

## Self-Hosted Services (Complete List)

### Media & Entertainment

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Jellyfin** | Media server (Netflix alternative) | `jellyfin/jellyfin` | 2 |
| **Plex** | Media server (proprietary) | `plexinc/pms-docker` | 2 |
| **Navidrome** | Music streaming | `lscr.io/linuxserver/navidrome` | 2 |
| **Audiobookshelf** | Audiobooks | `adv4000/audiobookshelf` | 2 |
| **Komga** | Comics/manga reader | `gotson/komga` | 2 |
| **Calibre-Web** | E-books | `lscr.io/linuxserver/calibre-web` | 2 |
| **TubeArchivist** | YouTube downloader | `tubearchivist/tubearchivist` | 2 |

### Automation (*arr Stack)

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Sonarr** | TV automation | `lscr.io/linuxserver/sonarr` | 2 |
| **Radarr** | Movie automation | `lscr.io/linuxserver/radarr` | 2 |
| **Lidarr** | Music automation | `lscr.io/linuxserver/lidarr` | 2 |
| **Readarr** | E-book automation | `lscr.io/linuxserver/readarr` | 2 |
| **Prowlarr** | Indexer manager | `lscr.io/linuxserver/prowlarr` | 2 |
| **Bazarr** | Subtitle automation | `lscr.io/linuxserver/bazarr` | 2 |
| **qBittorrent** | Torrent client | `lscr.io/linuxserver/qbittorrent` | 2 |
| **Transmission** | Torrent client | `lscr.io/linuxserver/transmission` | 2 |

### Photos & Backup

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Immich** | Photo backup (Google Photos alt) | `ghcr.io/immich-app/immich` | 2 |
| **PhotoPrism** | AI photo gallery | `photoprism/photoprism` | 2 |
| **LibrePhotos** | Photo gallery | `重新定义/librephotos` | 2 |
| **Paperless-ngx** | Document management | `ghcr.io/paperless-ngx/paperless-ngx` | 2 |
| **Duplicati** | Backup software | `linuxserver/duplicati` | 2 |
| **Restic** | Backup tool | `restic/restic` | 2 |

### Productivity & Collaboration

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Nextcloud** | File sync + office | `nextcloud` | 2 |
| **OwnCloud** | File sync | `owncloud/server` | 2 |
| **FileBrowser** | File manager | `filebrowser/filebrowser` | 1 |
| **Syncthing** | File sync | `lscr.io/linuxserver/syncthing` | 2 |
| **BookStack** | Wiki/knowledge base | `lscr.io/linuxserver/bookstack` | 2 |
| **Outline** | Team wiki | `outlinewiki/outline` | 2 |
| **Vikunja** | Todo/kanban | `vikunja/vikunja` | 2 |
| **Actual Budget** | Personal finance | `actualbudget/actual` | 2 |
| **Wallos** | Bill tracking | `bellamy/wallos` | 2 |

### Smart Home & IoT

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Home Assistant** | Smart home hub | `homeassistant/home-assistant` | 2 |
| **Node-RED** | Automation flows | `nodered/node-red` | 1 |
| **ESPHome** | IoT devices | `esphome/esphome` | 1 |
| **Mosquitto** | MQTT broker | `eclipse-mosquitto` | 1 |
| **Zigbee2MQTT** | Zigbee bridge | `koenkk/zigbee2mqtt` | 1 |
| **HomeBridge** | Apple HomeKit | `homebridge/homebridge` | 1 |

### Networking & Security

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Pi-hole** | Ad blocking DNS | `pihole/pihole` | 1 |
| **AdGuard Home** | DNS ad blocker | `adguard/adguardhome` | 1 |
| **Traefik** | Reverse proxy | `traefik:v3` | 2 |
| **Caddy** | Web server + auto SSL | `caddy:2` | 2 |
| **Nginx Proxy Manager** | GUI proxy | `jc21/nginx-proxy-manager` | 2 |
| **Cloudflared** | Tunnel to internet | `cloudflare/cloudflared` | 1 |
| **WireGuard** | VPN | `linuxserver/wireguard` | 1 |
| **Tailscale** | Mesh VPN | `tailscale/tailscale` | 1 |
| **Authentik** | SSO | `authentik/authentik` | 2 |
| **Authelia** | SSO proxy | `authelia/authelia` | 2 |
| **Keycloak** | Identity provider | `quay.io/keycloak/keycloak` | 2 |

### Monitoring & Observability

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Uptime Kuma** | Uptime monitoring | `louislam/uptime-kuma` | 1 |
| **Grafana** | Metrics dashboard | `grafana/grafana` | 2 |
| **Prometheus** | Metrics collection | `prom/prometheus` | 2 |
| **Loki** | Log aggregation | `grafana/loki` | 2 |
| **Glances** | System monitoring | `nicolargo/glances` | 1 |
| **Netdata** | Real-time monitoring | `netdata/netdata` | 1 |
| **GoAccess** | Log analytics | `allinurl/goaccess` | 1 |
| **Watchtower** | Auto-update containers | `containrrr/watchtower` | 1 |

### DevOps & Development

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Portainer** | Docker UI | `portainer/portainer-ce` | 2 |
| **Docker Garage** | Docker UI | `qmcgaw/docker-garage` | 2 |
| **Gitea** | Git self-hosted | `gitea/gitea` | 2 |
| **GitLab** | DevOps platform | `gitlab/gitlab-ce` | 4 |
| **Jenkins** | CI/CD | `jenkins/jenkins` | 4 |
| **Drone CI** | CI/CD | `drone/drone` | 2 |
| **DokuWiki** | Wiki | `linuxserver/dokuwiki` | 2 |

### AI & Machine Learning

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Ollama** | Local LLM | `ollama/ollama` | 4 |
| **Open WebUI** | ChatGPT UI | `ghcr.io/open-webui/open-webui` | 4 |
| **ComfyUI** | AI image generation | `comfyanonymous/comfyui` | 4 |
| **Stable Diffusion WebUI** | AI images | `sdwebui/sdwebui` | 4 |
| **Text Generation WebUI** | Text AI | `huggingface/text-generation-webui` | 4 |
| **LocalAI** | OpenAI-compatible API | `mudler/localai` | 4 |

### Dashboards & Portals

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Homepage** | App dashboard | `gethomepage/homepage` | 2 |
| **Dashy** | Custom startpage | `lissy93/dashy` | 1 |
| **Heimdall** | App launcher | `linuxserver/heimdall` | 1 |
| **Flame** | App dashboard | `火光(Firewalk)/flame` | 1 |

### Communication

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Mattermost** | Slack alternative | `mattermost/mattermost` | 2 |
| **Rocket.Chat** | Team chat | `rocket.chat` | 2 |
| **Matrix/Synapse** | Fediverse chat | `matrixdotorg/synapse` | 2 |
| **Gotify** | Notifications | `gotify/server` | 1 |
| **Joplin Server** | Notes sync | `joplin/server` | 2 |

### Home Inventory & Lifestyle

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **HomeBox** | Home inventory | `hay-kot/homebox` | 2 |
| **Mealie** | Recipe manager | `hay-kot/mealie` | 2 |
| **Pet喂** | Pet care | `petbib/petbib` | 2 |
| **LinkStack** | Link in bio | `linkstack/linkstack` | 2 |
| **Shlink** | URL shortener | `shlinkio/shlink` | 2 |

### News & RSS

| Service | Description | Image | Tier |
|---------|-------------|-------|------|
| **Miniflux** | RSS reader | `miniflux/miniflux` | 1 |
| **FreshRSS** | RSS aggregator | `freshrss/freshrss` | 1 |
| **Wallabag** | Save for later | `wallabag/wallabag` | 1 |

---

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

---

## Docker Installation

### On Ubuntu
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in
```

### On Raspberry Pi
```bash
curl -fsSL https://get.docker.com | sh
```

### On Termux (Android)
```bash
# Docker on Termux requires Docker-in-Docker setup
# See: https://github.com/termux/termux-docker
# This is complex and has limitations on ARM devices

# Alternative: Use lightweight services directly in Termux
# Or SSH to another Docker host in your network
```

---

## Networking & External Access

### Cloudflare Tunnel (Recommended)
Expose services to internet without port forwarding.

```bash
# Install cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared
chmod +x cloudflared

# Authenticate
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create my-home-lab

# Configure services
# Edit ~/.cloudflared/config.yml
```

**config.yml example:**
```yaml
tunnel: your-tunnel-id
credentials-file: /path/to/credentials.json

ingress:
  - hostname: jellyfin.yourdomain.com
    service: http://localhost:8096
  - hostname: homeassistant.yourdomain.com
    service: http://localhost:8123
  - service: http_status:404
```

### Port Forwarding (Alternative)
Forward ports on router to home server:
1. Access router admin panel
2. Find "Port Forwarding" or "Virtual Server"
3. Forward external port to internal IP:port

**Warning:** Use strong passwords and consider VPN/Cloudflare Tunnel.

---

## Power Solutions

### For Phones/Tablets

**USB Charger Hack:**
- Cut USB cable, connect to phone's USB-C/Lightning pins
- Phone stays on while charging
- Use a smart plug to control power

**Battery as UPS:**
- Connect phone to power bank
- When power cuts, battery keeps running

**Always-On Charging:**
- Lithium battery with charge controller
- Set "Stay Awake While Charging" in developer options

### For Computers

**UPS:** APC Back-UPS (~$80-150)
- Provides 30-60 minutes of backup power
- USB connection for graceful shutdown

**PoE (Power over Ethernet):**
- Use PoE switch or injector
- Single cable for power + network

---

## Power Consumption by Tier

| Tier | Devices | Idle Power | Max Power |
|------|---------|-----------|-----------|
| 0 | Router, AP, Switch | 10-15W | 20W |
| 1 | Pi + Phone | 3-5W | 10W |
| 2 | N100/OptiPlex | 10-15W | 40W |
| 3 | NAS | 15-30W | 50W |
| 4 | Server/GPU | 50-200W | 400W |

**Total idle (all tiers):** ~40-60W (very reasonable!)

---

## Recommended Configs by Hardware

### Raspberry Pi (ARM64) - Tier 1
```
• Pi-hole
• Uptime Kuma
• Vaultwarden
• Mosquitto
• AdGuard Home
• Node-RED
• Miniflux
• Gotify
• Glances
```

### N100 Mini PC (x86-64) - Tier 2
```
• Portainer + Docker
• Traefik
• Jellyfin + *arr Stack
• Immich
• Home Assistant
• Nextcloud
• Homepage Dashboard
• Watchtower
• Authentik
• Uptime Kuma
```

### Desktop with GPU - Tier 4
```
• Kubernetes (K3s/Talos)
• Ollama + Open WebUI
• ComfyUI
• Proxmox
• GitLab
• Jenkins
• Plex/Jellyfin (with GPU transcoding)
```

### Synology/NAS - Tier 3
```
• SMB/NFS shares
• Photo storage
• Backups (hyper backup)
• Time Machine
• Surveillance Station
• Docker (if supported)
```

---

## Cross-Device Patterns

### Shared Storage (NFS)
```yaml
# On compute node (Tier 2)
services:
  jellyfin:
    volumes:
      - nfs:/media:ro  # Read-only mount from NAS
```

### Database on Separate Node
```yaml
# Database node
services:
  postgres:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data

# App node
services:
  app:
    environment:
      - DATABASE_URL=postgres://user:pass@db-node:5432/db
```

### GPU Passthrough
```yaml
# For Jellyfin hardware transcoding
services:
  jellyfin:
    devices:
      - /dev/dri:/dev/dri  # Intel GPU
```

### Backup Chain
```
Tier 2 (Docker) ──rsync──► Tier 3 (NAS) ──rsync──► Tier 4 (Cloud/Offsite)
```

---

## Troubleshooting

### Docker on Termux Issues
- Use `dockerd` to start daemon manually
- Check with `docker ps`
- Some features may be limited on ARM

### Networking Issues
- Check firewall: `sudo ufw status`
- Verify port forwarding on router
- Use `netstat -tulpn` to check listening ports

### Performance
- Monitor with Portainer or `docker stats`
- Limit container memory/CPU
- Use SSD for database containers
- Place databases on faster storage

---

## Resources

- r/homelab on Reddit
- r/selfhosted on Reddit
- LinuxServer.io Docker images
- Awesome Self-Hosted list
- Home Assistant community
- Pi-hole documentation
- selfhosting.sh
- Technotim YouTube
