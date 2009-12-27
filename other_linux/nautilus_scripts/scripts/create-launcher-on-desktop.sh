#!/bin/sh
launcher_path=~/Desktop/launcher-$(date +%d%m%Y-%H%M%S).desktop
touch $launcher_path
echo "[Desktop Entry]"   >> $launcher_path
echo "Version=1.0"       >> $launcher_path
echo "Encoding=UTF-8"    >> $launcher_path
echo "Name=$@"           >> $launcher_path
echo "Type=Application"  >> $launcher_path
echo "Terminal=false"    >> $launcher_path
echo "Exec=$@"           >> $launcher_path

