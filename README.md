Heartbeat Telegram Bot

This bot sends periodic heartbeat messages to a Telegram chat, including:
- Public IP
- System info (CPU, RAM, OS, uptime, hostname)
- Online/offline notifications

Features
- Safe startup only if internet is available
- Works with systemd for auto-start
- Compiles to a binary with PyInstaller (source code hidden)
- Environment variables for BOT_TOKEN, CHAT_ID, and interval
- Safe uninstall script included

Ethical Use Warning ⚠️
This tool collects system and network information and sends it to a remote service.  
Do not use it on devices you do not own or have explicit permission to monitor.
Unauthorized use can be illegal and unethical.

Setup
1. Clone the repository:
`bash
git clone https://github.com/yourusername/heartbeat-bot.git

cd heartbeat-bot

on target machine 

#!/bin/bash
git clone https://github.com/yourusername/heartbeat-bot.git

cd heartbeat-bot

sudo cp heartbeat.env.example /etc/heartbeat.env

sudo nano /etc/heartbeat.env

chmod +x install_heartbeat.sh

./install_heartbeat.sh

then 
sudo cp heartbeat.env.example /etc/heartbeat.env

sudo nano /etc/heartbeat.env

add your 
bot_token
and 
chat_id

then make installer script executable 

chmod +x install_heartbeat.sh

./install_heartbeat.sh

in case to uninstall 

chmod +x uninstall_heartbeat.sh

./uninstall_heartbeat.sh


get all logs
journalctl -u heartbeat -f




