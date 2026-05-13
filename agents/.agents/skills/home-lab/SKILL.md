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

See [references/hardware-recommendations.md](references/hardware-recommendations.md) for hardware recommendations by budget and recommended configs by hardware.

See [references/services-overview.md](references/services-overview.md) for the complete categorized service list.

See [references/placement-guide.md](references/placement-guide.md) for tier-based placement recommendations.

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

## Reference Map

Read the following reference files based on what you need:

- **Hardware recommendations & configs**: [`references/hardware-recommendations.md`](references/hardware-recommendations.md)
- **Service catalog (all categories)**: [`references/services-overview.md`](references/services-overview.md)
- **Service placement guide**: [`references/placement-guide.md`](references/placement-guide.md)

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

See [references/hardware-recommendations.md](references/hardware-recommendations.md).
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
