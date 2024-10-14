#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Set same default compilation flags as abuild.
function log {
    echo ">>> $*"
}


#
# Install required packages.
#
apk --no-cache add \
    curl \
    p7zip \
    shadow \
    su-exec \
    wine \
    xvfb-run \

#
# Install MKVCleaver.
#

export WINEPREFIX=/opt/myapp
export WINEDLLOVERRIDES="mscoree,mshtml="
export XDG_CACHE_HOME=/tmp/xdg_cache


log "Creating Wine environment..."
useradd --system app
mkdir /opt/myapp
chown app:app /opt/myapp

#lolo
cp -r /mp3tag/* /opt/myapp

su-exec app wineboot
su-exec app wineserver -w
chown -R root:root /opt/myapp

#additional stuff for mp3tag
mkdir /opt/myapp/drive_c/users/app/AppData/Roaming/Mp3tag
chmod 777 /opt/myapp/drive_c/users/app/AppData/Roaming/Mp3tag
chmod 777 /opt/myapp/drive_c/users/app/Temp/

wineserver -w


log "Adjusting Wine environment..."

# Enable font smoothing.
wine64 reg add 'HKCU\Control Panel\Desktop' /v FontSmoothing /t REG_SZ /d 2 /f
wine64 reg add 'HKCU\Control Panel\Desktop' /v FontSmoothingGamma /t REG_DWORD /d 0x578 /f
wine64 reg add 'HKCU\Control Panel\Desktop' /v FontSmoothingOrientation /t REG_DWORD /d 1 /f
wine64 reg add 'HKCU\Control Panel\Desktop' /v FontSmoothingType /t REG_DWORD /d 2 /f
wineserver -w


mkdir /defaults
for F in user.reg system.reg; do
    mv /opt/myapp/"$F" /defaults/
    ln -s /tmp/"$F" /opt/myapp/"$F"
done

