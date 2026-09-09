# 🪶 Grav Caddy

[![Build and Publish](https://github.com/HomelessAvatar/grav-caddy/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/HomelessAvatar/grav-caddy/actions/workflows/docker-publish.yml)
[![Docker Image Size](https://img.shields.io/badge/image_size-~110MB-blue.svg)](https://github.com/HomelessAvatar/grav-caddy/pkgs/container/grav-caddy)
[![PHP Version](https://img.shields.io/badge/php-8.4-777bb4.svg)](https://php.net/)
[![Web Server](https://img.shields.io/badge/webserver-caddy_v2-1f88c0.svg)](https://caddyserver.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

An ultra-lightweight, high-performance, containerized [Grav CMS](https://getgrav.org/) environment powered by **Alpine Linux**, **PHP 8.4-FPM**, and **Caddy v2** with native **HTTP/3 (QUIC)** and **Zstandard** compression.

---

## 🚀 Why Grav Caddy?

The official Grav Docker image bundles Apache (`mpm_prefork`) which consumes **~150–250 MB of RAM** even while idling. **Grav Caddy** replaces Apache with **Caddy v2** and an optimized on-demand PHP 8.4-FPM pool:

| Feature | Official Grav Image | 🪶 Grav Caddy |
| :--- | :--- | :--- |
| **Base OS** | Debian / Ubuntu (~850 MB) | **Alpine Linux (~110 MB)** |
| **Web Server** | Apache (mpm_prefork) | **Caddy v2 (HTTP/3 + QUIC)** |
| **PHP Version** | PHP 8.3 | **PHP 8.4-FPM** |
| **Idle RAM Usage**| ~180 – 250 MB | 🟢 **~20 – 35 MB** |
| **Security Rules**| Basic `.htaccess` | **Canonical Grav 2.0 Caddy Regex Rules** |
| **Multi-Arch** | amd64 | **linux/amd64, linux/arm64** |

---

## 📦 Quick Start with Docker Compose

```yaml
services:
  grav:
    image: ghcr.io/homelessavatar/grav-caddy:latest
    container_name: grav-caddy
    restart: unless-stopped
    ports:
      - "127.0.0.1:8089:80"
    environment:
      - TZ=Europe/Istanbul
      - PUID=1000
      - PGID=1000
    volumes:
      - /opt/grav/html:/var/www/html
```

---

## ⚙️ Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `TZ` | `UTC` | Container timezone (e.g. `Europe/Istanbul`) |
| `PUID` | `82` | User ID for file permissions (matches `www-data` on host) |
| `PGID` | `82` | Group ID for file permissions |
| `GRAV_VERSION` | `latest` | Grav version to auto-download if volume is empty |

---

## 🔒 Security

This image ships with the official Grav CMS security rules:
* Blocks direct access to `/.git`, `/cache`, `/bin`, `/logs`, `/backups`, `/tests`.
* Protects `/user/config` and `/user/env` from being accessed via HTTP.
* Blocks unauthorized script execution inside user and system paths.

---

## 📄 License

MIT License © [Ersan Genç](https://github.com/HomelessAvatar)
