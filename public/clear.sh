#!/bin/bash

USER_HOME="bmsit"

# Delete files directly in home
find "$USER_HOME" -maxdepth 1 -type f -delete

# Empty standard folders but keep the folders
find "$USER_HOME/Desktop"    -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Downloads"  -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Documents"  -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Pictures"   -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Videos"     -mindepth 1 -delete 2>/dev/null
find "$USER_HOME/Music"      -mindepth 1 -delete 2>/dev/null

# Remove all other directories in home except these
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

cd $USER_HOME
sudo dnf install -y xdg-user-dirs
xdg-user-dirs-update --force
exit 0
