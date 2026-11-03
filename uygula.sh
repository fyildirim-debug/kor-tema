#!/usr/bin/env bash
# Kor temasini calisan Plasma oturumuna uygular. kur.sh cagirir; oturum disinda kurulduysa
# ilk giriste otomatik baslatmadan bir kez calisir ve kendi kaydini siler.
set -u
[ "${1:-}" = "--giriste" ] && sleep 6

kw() { kwriteconfig6 "$@"; }
EV="$HOME"

# Gorunum paketi: paneller, dok, saat, kordurum, Kor Masa, duvar kagidi, acilis ekrani
plasma-apply-lookandfeel -a org.furkan.kor --resetLayout || true
sleep 3

plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
plasma-apply-colorscheme Kor || true
/usr/lib/plasma-changeicons Kor 2>/dev/null || kw --file kdeglobals --group Icons --key Theme Kor
plasma-apply-cursortheme Bibata-Modern-Classic || true
plasma-apply-desktoptheme default || true
plasma-apply-wallpaperimage "$EV/.local/share/wallpapers/KorFurkan" || true

# yazi tipleri ve genel
kw --file kdeglobals --group General --key font "Ubuntu,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group General --key menuFont "Ubuntu,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group General --key toolBarFont "Ubuntu,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group General --key smallestReadableFont "Ubuntu,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group WM --key activeFont "JetBrainsMono Nerd Font,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1"
kw --file kdeglobals --group General --key TerminalApplication ghostty
kw --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
kw --file kdeglobals --group KDE --key AnimationDurationFactor 0.25
kw --file kdeglobals --group KDE --key contrast 4
kw --file kdeglobals --group KDE --key frameContrast 0.2
kw --file kdeglobals --group KDE --key widgetStyle Breeze
kw --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Classic
kw --file kcminputrc --group Mouse --key cursorSize 24

# pencere yoneticisi: Breeze kenar, sagda dugmeler, 4 calisma alani, efektler
kw --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
kw --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
kw --file kwinrc --group org.kde.kdecoration2 --key BorderSize None
kw --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kw --file kwinrc --group Desktops --key Number 4
kw --file kwinrc --group Desktops --key Rows 1
kw --file kwinrc --group Plugins --key blurEnabled false
kw --file kwinrc --group Plugins --key better_blur_dxEnabled true
kw --file kwinrc --group Plugins --key kwin4_effect_shapecornersEnabled true
kw --file kwinrc --group Plugins --key magiclampEnabled false
kw --file kwinrc --group Plugins --key squashEnabled true
while IFS='=' read -r a d; do kw --file kwinrc --group Effect-better-blur-dx --key "$a" "$d"; done <<'EOF'
BlurDecorations=true
BlurDocks=true
BlurMatching=false
BlurMenus=true
BlurNonMatching=true
BlurStrength=10
Brightness=105
CornerRadius=12
NoiseStrength=2
RefractionCornerRadius=12
RefractionEdgeSize=18
RefractionStrength=0
Saturation=115
EOF
while IFS='=' read -r a d; do kw --file kwinrc --group Round-Corners --key "$a" "$d"; done <<'EOF'
ActiveCornerRadius=10
ActiveOutlineAlpha=255
ActiveOutlineColor=238,90,54
ActiveOutlineColor2=242,170,60
ActiveOutlineGradientAngle=45
ActiveOutlineIsGradient=true
ActiveOutlineThickness=2
ActiveOutlineUseCustom=true
ActiveOutlineUsePalette=false
DisableOutlineFullScreen=true
DisableOutlineMaximize=true
InactiveCornerRadius=10
InactiveOutlineAlpha=255
InactiveOutlineColor=58,60,69
InactiveOutlineThickness=1
InactiveOutlineUseCustom=true
InactiveOutlineUsePalette=false
EOF

# Win tusu tek basina: Genel Bakis (tum acik pencereler)
kw --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Overview"
kw --file kwinrc --group Plugins --key overviewEnabled true

# acilis ve kilit ekrani
kw --file ksplashrc --group KSplash --key Theme org.furkan.kor
kw --file ksplashrc --group KSplash --key Engine KSplashQML
kw --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.image
kw --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General \
   --key Image "file://$EV/.local/share/wallpapers/KorFurkan/contents/images/3840x2160.png"

# Kate
kw --file katerc --group "KTextEditor Renderer" --key "Auto Color Theme Selection" false
kw --file katerc --group "KTextEditor Renderer" --key "Color Theme" Kor
kw --file katerc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true

# Win tusunu uygulama baslaticidan al (yalniz Alt+F1 kalsin); Win tek basina Genel Bakis'i acar
busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setForeignShortcutKeys 'asa(ai)' \
    4 plasmashell "activate application launcher" plasmashell "Uygulama Başlatıcısını Etkinleştir" \
    1 1 $(( 0x08000000 | 0x01000030 )) >/dev/null 2>&1 \
  || kw --file kglobalshortcutsrc --group plasmashell --key "activate application launcher" "Alt+F1,Meta\tAlt+F1,Uygulama Başlatıcısını Etkinleştir"

rm -f "$HOME/.config/autostart/kor-tema-uygula.desktop"
echo "Kor uygulandi."
