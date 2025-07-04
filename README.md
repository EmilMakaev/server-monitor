# 🖥️ Server Monitoring Script

Lightweight Bash script for monitoring critical server resources and sending Telegram alerts when thresholds are exceeded.  
Ideal for VPS or low-resource environments (tested on 1 CPU / 1 GB RAM systems).

---

## ✨ Key Features

✅ **Real-time Monitoring** of:

- CPU usage (%)
- RAM utilization (%)
- Disk space (root partition)

✅ **Smart Thresholds** with configurable limits

✅ **Telegram Notifications** with Markdown formatting

✅ **Anti-Flood Protection** using lockfiles

✅ **Low Resource Usage** (minimal dependencies)

---

## ⚙️ Technical Specifications

- **Dependencies:**
  - `bc` (for calculations)
  - `curl` (Telegram API)
- **Logging:**
  - Optional file logging (disabled by default)
- **Cron Integration:**
  - Designed for 5-minute intervals
- **Security:**
  - Runs with root privileges for accurate metrics

---

## 💡 Recommended Use

- Basic server health monitoring
- Resource usage trend analysis
- Incident response triggering
- Low-budget monitoring solution

---

## 🛠️ Maintenance

The script automatically maintains its lockfile and requires no ongoing maintenance beyond initial setup.

---

## ⚙️ Configuration

Edit these variables in the script:

```bash
# Thresholds (percentage)
THRESHOLD_CPU=80      # CPU usage %
THRESHOLD_RAM=90      # RAM usage %
THRESHOLD_DISK=90     # Disk usage %

# Telegram settings
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"

---

## 🚀 Installation
Download the script and make it executable:

curl -o /opt/server_monitor.sh https://raw.githubusercontent.com/EmilMakaev/server-monitor/main/server_monitor.sh
chmod +x /opt/server_monitor.sh

Set up cron to run every 5 minutes:

(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/server_monitor.sh >/dev/null 2>&1") | crontab -

---

```
