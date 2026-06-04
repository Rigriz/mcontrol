#!/bin/bash

USER_HOME="/home/bmsit"

find "$USER_HOME" -maxdepth 1 -type f ! -name ".*" -delete

find "$USER_HOME/Desktop"    -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Downloads"  -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Documents"  -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Pictures"   -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Videos"     -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Music"      -mindepth 1 -delete 2>/dev/null

find "$USER_HOME" -maxdepth 1 -mindepth 1 -type d \
    ! -name Desktop \
    ! -name Downloads \
    ! -name Documents \
    ! -name Pictures \
    ! -name Videos \
    ! -name Music \
    ! -name Public \
    ! -name Templates \
    ! -name snap \
    ! -name .config \
    ! -name .local \
    -exec rm -rf {} +
    
cp /etc/skel/.bashrc ~/.bashrc
cp /etc/skel/.bash_profile ~/.bash_profile
source ~/.bashrc
dnf install -y xdg-user-dirs

sudo -u bmsit HOME=/home/bmsit xdg-user-dirs-update --force

exit 0
