# server-monitor

/// заменить переменные
TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"

curl -o /opt/server_monitor.sh https://raw.githubusercontent.com/EmilMakaev/server-monitor/main/server_monitor.sh
chmod +x /opt/server_monitor.sh

////
и потом вот так запускаю
crontab -e

_/5 _ \* \* \* /opt/server_monitor.sh >/dev/null 2>&1

// проверить робоспособность
stress-ng --cpu 1 --vm 1 --vm-bytes 500M --timeout 30s
