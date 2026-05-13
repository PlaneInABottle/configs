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
