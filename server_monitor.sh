#!/usr/bin/env bash

# =========[ Configuration ]=========

TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"

THRESHOLD_CPU=80      # CPU usage %
THRESHOLD_RAM=90      # RAM usage %
THRESHOLD_DISK=90     # Root disk usage %

LOCK_FILE="/tmp/server_monitor.lock"
LOG_FILE="/var/log/server_monitor.log"

# =========[ Initialization ]=========
exec >> "$LOG_FILE" 2>&1  # Redirect output to log
echo "=== Monitoring started at $(date) ==="

# Check for bc dependency
if ! command -v bc &>/dev/null; then
    echo "Error: Please install bc (sudo apt install bc)"
    exit 1
fi

# Check internet connection
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "No internet connection, skipping check"
    exit 0
fi

# =========[ Flood protection ]=========
if [ -f "$LOCK_FILE" ]; then
    echo "Monitoring is already running"
    exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# =========[ Get metrics ]=========
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
RAM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df / | awk 'END{print $5}' | tr -d '%')

echo "CPU: ${CPU_USAGE%.*}% | RAM: ${RAM_USAGE%.*}% | Disk: $DISK_USAGE%"

# =========[ Threshold checks ]=========
CPU_ALERT=$(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l)
RAM_ALERT=$(echo "$RAM_USAGE > $THRESHOLD_RAM" | bc -l)
DISK_ALERT=$([ "$DISK_USAGE" -ge "$THRESHOLD_DISK" ] && echo 1 || echo 0)

# =========[ Send notification ]=========
if [ "$CPU_ALERT" -eq 1 ] || [ "$RAM_ALERT" -eq 1 ] || [ "$DISK_ALERT" -eq 1 ]; then
    MESSAGE="⚠️ *Server under heavy load!* ⚠️

*Host:* \`$(hostname)\`
*CPU:* \`${CPU_USAGE%.*}%\` $( [ "$CPU_ALERT" -eq 1 ] && echo "(>${THRESHOLD_CPU}%)" )
*RAM:* \`${RAM_USAGE%.*}%\` $( [ "$RAM_ALERT" -eq 1 ] && echo "(>${THRESHOLD_RAM}%)" )
*Disk:* \`${DISK_USAGE}%\` $( [ "$DISK_ALERT" -eq 1 ] && echo "(≥${THRESHOLD_DISK}%)" )

Time: \`$(date)\`"

    if curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown"; then
        echo "Notification sent successfully"
    else
        echo "Failed to send Telegram notification"
    fi
fi

echo "Monitoring completed"