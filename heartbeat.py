#!/usr/bin/env python3
import os
import time
import signal
import socket
import platform
import requests
import psutil
import atexit
import sys
from datetime import datetime

BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")
INTERVAL = int(os.environ.get("HEARTBEAT_INTERVAL", "600"))

if not BOT_TOKEN or not CHAT_ID:
    raise SystemExit("❌ BOT_TOKEN and CHAT_ID must be set as environment variables")

running = True

def check_internet(host="8.8.8.8", port=53, timeout=5):
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except Exception:
        return False

if not check_internet():
    print("❌ No internet connection. Exiting...")
    sys.exit(1)

def get_public_ip():
    try:
        return requests.get("https://api.ipify.org", timeout=5).text.strip()
    except Exception:
        return "Unknown"

def get_system_info():
    try:
        info = []
        info.append(f"🖥 OS: {platform.system()} {platform.release()}")
        info.append(f"🐍 Python: {platform.python_version()}")
        info.append(f"💾 RAM: {round(psutil.virtual_memory().total / (1024**3), 2)} GB")
        info.append(f"🖥 CPU: {psutil.cpu_count()} cores")
        uptime = int(time.time() - psutil.boot_time())
        info.append(f"⏳ Uptime: {uptime // 3600}h {(uptime % 3600) // 60}m")
        info.append(f"📡 Hostname: {socket.gethostname()}")
        return "\n".join(info)
    except Exception as e:
        return f"⚠️ Could not gather system info: {e}"

def send_message(text, retries=3, delay=5):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    for attempt in range(retries):
        try:
            r = requests.post(url, json={"chat_id": CHAT_ID, "text": text}, timeout=10)
            if r.status_code == 200:
                return True
        except Exception as e:
            print(f"⚠️ Failed to send message (attempt {attempt+1}):", e)
            time.sleep(delay)
    return False

def send_heartbeat():
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    ip = get_public_ip()
    msg = f"✅ Heartbeat\n🕒 {now}\n🌍 IP: {ip}\n\n{get_system_info()}"
    send_message(msg)
    print("Heartbeat sent.")

def send_offline():
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    ip = get_public_ip()
    msg = f"❌ Console closed\n🕒 {now}\n🌍 Last known IP: {ip}"
    send_message(msg)
    print("Offline message sent.")

def handle_exit(signum=None, frame=None):
    global running
    if running:
        print(f"Received signal {signum}, shutting down...")
        send_offline()
        running = False

for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
    signal.signal(sig, handle_exit)

atexit.register(handle_exit)

if __name__ == "__main__":
    send_heartbeat()
    while running:
        time.sleep(INTERVAL)
        if running:
            send_heartbeat()