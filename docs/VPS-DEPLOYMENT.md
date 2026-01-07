# VPS Deployment Guide

> Complete guide to deploying ALFA Dashboard on a VPS

## Prerequisites

- VPS with Ubuntu 22.04+ or Debian 12+
- Minimum 2GB RAM, 20GB storage
- Domain name with DNS access
- SSH access to the server

## Step 1: Server Preparation

### Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt install docker-compose-plugin -y

# Verify installation
docker compose version
```

### Install Essential Tools

```bash
sudo apt install -y git curl htop ncdu ufw fail2ban
```

## Step 2: Security Configuration

### Configure Firewall

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Verify
sudo ufw status
```

### Configure Fail2Ban

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Create Deployment User

```bash
# Create user
sudo adduser alfa --disabled-password
sudo usermod -aG docker alfa

# Setup SSH key authentication
sudo mkdir -p /home/alfa/.ssh
sudo cp ~/.ssh/authorized_keys /home/alfa/.ssh/
sudo chown -R alfa:alfa /home/alfa/.ssh
```

## Step 3: DNS Configuration

Create the following DNS records pointing to your VPS IP:

| Type | Name | Value |
|------|------|-------|
| A | @ | YOUR_VPS_IP |
| A | n8n | YOUR_VPS_IP |
| A | auth | YOUR_VPS_IP |
| A | status | YOUR_VPS_IP |
| A | traefik | YOUR_VPS_IP |

Allow 5-10 minutes for DNS propagation.

## Step 4: Clone and Configure

### Clone Repository

```bash
cd /home/alfa
git clone https://github.com/yourusername/ALFA-Agent-Method.git
cd ALFA-Agent-Method/alfa-dashboard
```

### Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with production values:

```bash
# Domain Configuration
DOMAIN=yourdomain.com
ACME_EMAIL=admin@yourdomain.com

# Generate secure secrets
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60)
N8N_JWT_SECRET=$(openssl rand -base64 32)
```

Save the generated secrets securely!

## Step 5: Launch Stack

### Start Services

```bash
docker compose up -d
```

### Verify All Services

```bash
docker compose ps
```

Expected output:
```
NAME                   STATUS                   PORTS
alfa-traefik           running (healthy)        80, 443
alfa-postgres          running (healthy)        5432
alfa-redis             running (healthy)        6379
alfa-authentik         running                  9000
alfa-authentik-worker  running
alfa-n8n               running (healthy)        5678
alfa-uptime-kuma       running (healthy)        3001
```

## Step 6: Initial Setup

### Authentik Admin Setup

```bash
# Create recovery key (save this!)
docker exec -it alfa-authentik ak create_recovery_key 10 admin
```

Visit `https://auth.yourdomain.com/` and use the recovery key to set up your admin account.

### n8n Setup

Visit `https://n8n.yourdomain.com/` and create your owner account.

### Uptime Kuma Setup

Visit `https://status.yourdomain.com/` and create your admin account.

## Step 7: Configure Systemd Service

### Create Service File

```bash
sudo nano /etc/systemd/system/alfa-dashboard.service
```

```ini
[Unit]
Description=ALFA Dashboard Docker Stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/alfa/ALFA-Agent-Method/alfa-dashboard
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=alfa
Group=alfa

[Install]
WantedBy=multi-user.target
```

### Enable Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable alfa-dashboard
sudo systemctl start alfa-dashboard
```

## Step 8: Configure Watchdog

### Install Watchdog Service

```bash
sudo nano /etc/systemd/system/alfa-watchdog.service
```

```ini
[Unit]
Description=ALFA Dashboard Watchdog
After=alfa-dashboard.service

[Service]
Type=simple
WorkingDirectory=/home/alfa/ALFA-Agent-Method/alfa-dashboard
ExecStart=/home/alfa/ALFA-Agent-Method/alfa-dashboard/scripts/alfa-watchdog.sh daemon 30
Restart=always
User=alfa
Group=alfa

[Install]
WantedBy=multi-user.target
```

### Enable Watchdog

```bash
sudo systemctl daemon-reload
sudo systemctl enable alfa-watchdog
sudo systemctl start alfa-watchdog
```

## Step 9: Configure Backups

### Create Backup Script

```bash
mkdir -p /home/alfa/backups
chmod +x /home/alfa/ALFA-Agent-Method/alfa-dashboard/scripts/backup.sh
```

### Configure Cron

```bash
crontab -e
```

Add:
```
# Daily backup at 3 AM
0 3 * * * /home/alfa/ALFA-Agent-Method/alfa-dashboard/scripts/backup.sh
```

## Step 10: SSL Certificate Verification

### Check Certificates

```bash
# Check Traefik logs for certificate issuance
docker logs alfa-traefik | grep -i cert

# Test HTTPS
curl -I https://n8n.yourdomain.com
```

## Maintenance Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
```

### Update Stack

```bash
cd /home/alfa/ALFA-Agent-Method/alfa-dashboard
git pull
docker compose pull
docker compose up -d
```

### Restart Services

```bash
# All services
sudo systemctl restart alfa-dashboard

# Specific service
docker compose restart n8n
```

### Check Status

```bash
./scripts/alfa-watchdog.sh status
```

## Troubleshooting

### Certificate Not Issuing

```bash
# Check Traefik logs
docker logs alfa-traefik | grep -i error

# Verify DNS
dig n8n.yourdomain.com

# Ensure port 80 is accessible
curl -I http://n8n.yourdomain.com
```

### Service Won't Start

```bash
# Check logs
docker logs alfa-<service>

# Check dependencies
docker compose ps

# Recreate service
docker compose up -d --force-recreate <service>
```

### Database Issues

```bash
# Connect to database
docker exec -it alfa-postgres psql -U alfa

# List databases
\l

# Check connections
SELECT * FROM pg_stat_activity;
```

## Security Hardening

### Restrict SSH

Edit `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
```

Restart SSH: `sudo systemctl restart sshd`

### Automatic Updates

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

### Monitor Logs

```bash
# Install log monitoring
sudo apt install logwatch
```

## Monitoring Checklist

- [ ] All services healthy in Uptime Kuma
- [ ] SSL certificates valid (check expiry)
- [ ] Disk space > 20% free
- [ ] Memory usage < 80%
- [ ] Daily backups running
- [ ] Watchdog active

---

Your ALFA Dashboard is now deployed and production-ready!
