#!/usr/bin/env bash
# Kor kurulumundan onceki ayarlara doner (en son yedek ya da verilen yedek klasoru).
set -euo pipefail
YER="$HOME/.local/share/kor-tema"
Y="${1:-$(ls -d "$YER"/yedek/* 2>/dev/null | sort | tail -1)}"
[ -n "$Y" ] && [ -d "$Y" ] || { echo "Yedek bulunamadi."; exit 1; }
echo "Geri yukleniyor: $Y"
cp -a "$Y/." "$HOME/.config/"
rm -f "$HOME/.config/systemd/user/plasma-kwin_wayland.service.d/kor-kilit.conf" \
      "$HOME/.config/autostart/kor-tema-uygula.desktop"
systemctl --user daemon-reload 2>/dev/null || true
echo "Tamam. Degisikliklerin tamami icin oturumu kapatip yeniden gir."
echo "Tema dosyalari (~/.local/share/plasma/...) yerinde kalir; Sistem Ayarlari'ndan baska tema secebilirsin."
