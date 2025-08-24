#!/bin/bash
SERVICE_NAME="heartbeat"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
ENV_FILE="/etc/heartbeat.env"
INSTALL_DIR="/opt/heartbeat"

echo "🔴 Stopping Heartbeat service..."
sudo systemctl stop $SERVICE_NAME 2>/dev/null
echo "🔴 Disabling Heartbeat service..."
sudo systemctl disable $SERVICE_NAME 2>/dev/null
echo "🗑 Removing service file..."
sudo rm -f $SERVICE_FILE
echo "🗑 Removing environment file..."
sudo rm -f $ENV_FILE
echo "🗑 Removing installed directory..."
sudo rm -rf $INSTALL_DIR
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
echo "✅ Heartbeat bot has been uninstalled completely."