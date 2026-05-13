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
