#!/bin/bash

set -e

echo "======================================"
echo "     UBUNTU DEVELOPMENT SETUP"
echo "======================================"

echo
echo "[1/5] Updating Ubuntu..."
sudo apt update
sudo apt upgrade -y

echo
echo "[2/5] Installing GCC, G++, Python, pip and Snap..."
sudo apt install -y \
    gcc \
    g++ \
    python3 \
    python3-pip \
    python3-venv \
    snapd

echo
echo "[3/5] Installing/Updating gedit..."
sudo snap install gedit --classic 2>/dev/null || sudo snap refresh gedit

echo
echo "[4/5] Updating pip..."
python3 -m pip install --upgrade pip --user || \
python3 -m pip install --upgrade pip --break-system-packages

echo
echo "[5/5] Updating Snap packages..."
sudo snap refresh

echo
echo "======================================"
echo "       INSTALLED VERSIONS"
echo "======================================"

echo
echo "--- Ubuntu ---"
lsb_release -ds

echo
echo "--- Kernel ---"
uname -r

echo
echo "--- GCC ---"
gcc --version | head -n 1

echo
echo "--- G++ ---"
g++ --version | head -n 1

echo
echo "--- Python ---"
python3 --version

echo
echo "--- pip ---"
python3 -m pip --version

echo
echo "--- Snap ---"
snap --version

echo
echo "--- gedit ---"
snap list gedit

echo
echo "======================================"
echo "       SETUP & VERIFICATION DONE"
echo "======================================"
