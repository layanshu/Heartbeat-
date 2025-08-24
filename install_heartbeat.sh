#!/bin/bash
REPO_URL="https://github.com/yourusername/heartbeat-bot.git"
INSTALL_DIR="/opt/heartbeat"
ENV_FILE="/etc/heartbeat.env"
SERVICE_FILE="/etc/systemd/system/heartbeat.service"
SERVICE_NAME="heartbeat"

if ! command -v pyinstaller &> /dev/null; then
    echo "📦 Installing PyInstaller..."
    sudo apt update
    sudo apt install -y python3-pip
    pip3 install pyinstaller
fi

echo "📥 Cloning repository..."
sudo rm -rf $INSTALL_DIR
sudo git clone $REPO_URL $INSTALL_DIR

echo "⚙️ Compiling Python script to binary..."
cd $INSTALL_DIR
pyinstaller --onefile heartbeat.py
sudo mv dist/heartbeat $INSTALL_DIR/heartbeat
sudo chmod +x $INSTALL_DIR/heartbeat
rm -rf build dist __pycache__ heartbeat.spec heartbeat.py

if [ ! -f "$ENV_FILE" ]; then
  echo "⚙️ Creating environment file at $ENV_FILE"
  sudo bash -c "cat > $ENV_FILE" <<EOF
BOT_TOKEN=your-bot-token-here
CHAT_ID=your-chat-id-here
HEARTBEAT_INTERVAL=600
EOF
  sudo chmod 600 $ENV_FILE
  sudo chown root:root $ENV_FILE
else
  echo "ℹ️ Environment file already exists at $ENV_FILE"
fi

echo "⚙️ Creating systemd service..."
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Heartbeat Telegram Bot
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/heartbeat
WorkingDirectory=$INSTALL_DIR
Restart=always
RestartSec=10
User=$USER
EnvironmentFile=$ENV_FILE

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

echo "🎉 Heartbeat Bot installed successfully!"
echo "👉 Edit $ENV_FILE to add your BOT_TOKEN and CHAT_ID"
echo "👉 Binary located at $INSTALL_DIR/heartbeat"
echo "👉 Check logs: journalctl -u $SERVICE_NAME -f"