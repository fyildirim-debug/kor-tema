#!/usr/bin/env bash
# Kor temasi kurucusu (Arch / CachyOS + KDE Plasma 6)
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/fyildirim-debug/kor-tema/main/kur.sh)
#
# Secenekler:
#   --paketsiz    paket kurulumunu atla
#   --sistemsiz   sudo gerektiren sistem adimlarini (paketler, SDDM) atla
#   --ertele      yalniz dosya ve ayarlari kur, Plasma'ya uygulamayi sonraki girise birak
set -euo pipefail

DEPO_URL="https://github.com/fyildirim-debug/kor-tema.git"
YER="$HOME/.local/share/kor-tema"

PAKETSIZ=0; SISTEMSIZ=0; ERTELE=0
for a in "$@"; do
    case "$a" in
        --paketsiz) PAKETSIZ=1 ;;
        --sistemsiz) SISTEMSIZ=1; PAKETSIZ=1 ;;
        --ertele) ERTELE=1 ;;
        -h|--help) sed -n 2,9p "$0"; exit 0 ;;
        *) echo "Bilinmeyen secenek: $a" >&2; exit 2 ;;
    esac
done

k="\033[38;2;238;90;54m"; s="\033[38;2;138;139;147m"; y="\033[38;2;92;190;120m"; z="\033[0m"
adim() { printf "${k}❯${z} %s\n" "$*"; }
bilgi() { printf "  ${s}%s${z}\n" "$*"; }
tamam() { printf "  ${y}✓${z} %s\n" "$*"; }
hata() { printf "${k}✗ %s${z}\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------- depo
KOK="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -z "$KOK" ] || [ ! -d "$KOK/dosyalar" ]; then
    command -v git >/dev/null || { adim "git kuruluyor"; sudo pacman -S --needed --noconfirm git; }
    if [ -d "$YER/depo/.git" ]; then
        adim "Kor deposu guncelleniyor"
        git -C "$YER/depo" fetch -q origin main && git -C "$YER/depo" reset -q --hard origin/main
    else
        adim "Kor deposu indiriliyor"
        mkdir -p "$YER"; git clone -q --depth 1 "$DEPO_URL" "$YER/depo"
    fi
    exec bash "$YER/depo/kur.sh" "$@"
fi
D="$KOK/dosyalar"

# ---------------------------------------------------------------- denetim
[ "$(id -u)" -ne 0 ] || hata "Bu betigi root olarak degil, kendi kullanicinla calistir."
command -v pacman >/dev/null || hata "Yalniz Arch tabanli dagitimlar (CachyOS, Arch, EndeavourOS) desteklenir."
command -v plasmashell >/dev/null || hata "KDE Plasma kurulu degil."
PV="$(plasmashell --version 2>/dev/null | grep -oE '[0-9]+' | head -1)"
[ "${PV:-0}" -ge 6 ] || hata "Plasma 6 gerekli (bulunan: $(plasmashell --version 2>/dev/null))."

printf "\n${k}kor${z} ${s}❯ tema kurulumu${z}\n\n"

# ---------------------------------------------------------------- paketler
DEPO_PAKETLER=(git base-devel librsvg papirus-icon-theme ttf-ubuntu-font-family ttf-jetbrains-mono-nerd
               ghostty starship zoxide btop fastfetch kate qt6-5compat)
AUR_PAKETLER=(bibata-cursor-theme-bin kwin-effect-rounded-corners kwin-effects-better-blur-dx)

aur_kur() {
    local p="$1"
    if command -v paru >/dev/null; then paru -S --needed --noconfirm --skipreview "$p" && return 0
    elif command -v yay >/dev/null; then yay -S --needed --noconfirm --answerdiff None --answerclean None "$p" && return 0
    fi
    [ -n "$(git ls-remote "https://aur.archlinux.org/$p.git" HEAD 2>/dev/null)" ] || return 1
    local t r=0; t="$(mktemp -d)"
    if git clone -q --depth 1 "https://aur.archlinux.org/$p.git" "$t/$p" \
        && (cd "$t/$p" && makepkg -si --needed --noconfirm); then r=0; else r=1; fi
    rm -rf "$t"; return $r
}

if [ "$PAKETSIZ" -eq 0 ]; then
    adim "Paketler"
    eksik=()
    for p in "${DEPO_PAKETLER[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 || eksik+=("$p"); done
    if [ ${#eksik[@]} -gt 0 ]; then
        bilgi "depodan: ${eksik[*]}"
        sudo pacman -S --needed --noconfirm "${eksik[@]}"
    fi
    for p in "${AUR_PAKETLER[@]}"; do
        if pacman -Qq "$p" >/dev/null 2>&1 || pacman -Qq "$p-git" >/dev/null 2>&1; then continue; fi
        if pacman -Si "$p" >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "$p"
        else
            bilgi "AUR: $p"
            aur_kur "$p" || aur_kur "$p-git" || hata "$p kurulamadi."
        fi
    done
    tamam "paketler hazir"
fi

# ---------------------------------------------------------------- yedek
YEDEK="$YER/yedek/$(date +%Y%m%d-%H%M%S)"
adim "Yedek: $YEDEK"
mkdir -p "$YEDEK"
for f in kdeglobals kwinrc ksplashrc kscreenlockerrc kcminputrc katerc plasmashellrc plasmarc \
         plasma-org.kde.plasma.desktop-appletsrc starship.toml xdg-terminals.list \
         ghostty btop fastfetch gtk-3.0 gtk-4.0 fish/config.fish; do
    [ -e "$HOME/.config/$f" ] && { mkdir -p "$YEDEK/$(dirname "$f")"; cp -a "$HOME/.config/$f" "$YEDEK/$f"; }
done
tamam "eski ayarlar yedeklendi"

# ---------------------------------------------------------------- dosyalar
adim "Tema dosyalari"
P="$HOME/.local/share/plasma"
mkdir -p "$P/look-and-feel" "$P/plasmoids" "$P/shells" "$HOME/.local/share/color-schemes" \
         "$HOME/.local/share/wallpapers" "$HOME/.local/share/org.kde.syntax-highlighting/themes"
yerlestir() { rm -rf "$2"; cp -r "$1" "$2"; }
yerlestir "$D/plasma/look-and-feel/org.furkan.kor"  "$P/look-and-feel/org.furkan.kor"
yerlestir "$D/plasma/plasmoids/org.furkan.kordurum" "$P/plasmoids/org.furkan.kordurum"
yerlestir "$D/plasma/plasmoids/org.furkan.kormasa"  "$P/plasmoids/org.furkan.kormasa"
yerlestir "$D/plasma/shells/org.furkan.kor.kilit"   "$P/shells/org.furkan.kor.kilit"
yerlestir "$D/wallpapers/KorFurkan"                 "$HOME/.local/share/wallpapers/KorFurkan"
cp "$D/color-schemes/Kor.colors" "$HOME/.local/share/color-schemes/Kor.colors"
cp "$D/syntax-highlighting/themes/kor.theme" "$HOME/.local/share/org.kde.syntax-highlighting/themes/kor.theme"
sed -i "s|__EV__|$HOME|g" "$P/look-and-feel/org.furkan.kor/contents/layouts/org.kde.plasma.desktop-layout.js"
tamam "Plasma paketleri, renk semasi, duvar kagidi"

# simge temasi: Papirus-Dark + kor rengi klasorler (Papirus'a baglanti)
I="$HOME/.local/share/icons/Kor"
rm -rf "$I"; mkdir -p "$I"; cp "$D/icons/Kor/index.theme" "$I/"
n=0
while IFS=$'\t' read -r ad hedef; do
    [ -e "/usr/share/icons/Papirus/$hedef" ] || continue
    mkdir -p "$I/$(dirname "$ad")"; ln -sf "/usr/share/icons/Papirus/$hedef" "$I/$ad"; n=$((n+1))
done < "$D/icons/Kor/linkler.tsv"
tamam "Kor simge temasi ($n klasor simgesi)"

# uygulama ayarlari
C="$HOME/.config"
mkdir -p "$C/ghostty/themes" "$C/btop/themes" "$C/fastfetch" "$C/gtk-3.0" "$C/gtk-4.0" "$C/fish"
cp "$D/config/ghostty/config" "$C/ghostty/config"
cp "$D/config/ghostty/themes/kor" "$C/ghostty/themes/kor"
cp "$D/config/btop/themes/kor.theme" "$C/btop/themes/kor.theme"
cp "$D/config/fastfetch/config.jsonc" "$C/fastfetch/config.jsonc"
cp "$D/config/starship.toml" "$C/starship.toml"
cp "$D/config/gtk-3.0/settings.ini" "$C/gtk-3.0/settings.ini"
cp "$D/config/gtk-4.0/settings.ini" "$C/gtk-4.0/settings.ini"
B="$C/btop/btop.conf"
if [ -f "$B" ]; then
    sed -i -E 's|^color_theme = .*|color_theme = "kor"|; s|^theme_background = .*|theme_background = false|; s|^rounded_corners = .*|rounded_corners = true|; s|^graph_symbol = .*|graph_symbol = "braille"|' "$B"
else
    printf 'color_theme = "kor"\ntheme_background = false\nrounded_corners = true\ngraph_symbol = "braille"\n' > "$B"
fi
F="$C/fish/config.fish"
touch "$F"
if ! grep -q "starship init fish" "$F"; then
    cat >> "$F" <<'EOF'

# >>> kor-tema >>>
if status is-interactive
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source
end
# <<< kor-tema <<<
EOF
fi
if [ -f "$HOME/.bashrc" ] && ! grep -q "starship init bash" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# >>> kor-tema >>>
if [[ $- == *i* ]]; then
    command -v starship >/dev/null && eval "$(starship init bash)"
    command -v zoxide >/dev/null && eval "$(zoxide init bash)"
fi
# <<< kor-tema <<<
EOF
fi
echo "com.mitchellh.ghostty.desktop" > "$C/xdg-terminals.list"
tamam "Ghostty, btop, fastfetch, starship, zoxide, GTK"

# kilit ekrani: Kor Kilit kabugu yalniz KWin'e (dolayisiyla kscreenlocker'a) tanitilir
mkdir -p "$C/systemd/user/plasma-kwin_wayland.service.d"
cp "$D/systemd/plasma-kwin_wayland.service.d/kor-kilit.conf" "$C/systemd/user/plasma-kwin_wayland.service.d/kor-kilit.conf"
systemctl --user daemon-reload 2>/dev/null || true
tamam "Kor kilit ekrani (sonraki giriste etkin)"

# uygulama betigi
mkdir -p "$YER"
cp "$KOK/uygula.sh" "$YER/uygula.sh"; chmod +x "$YER/uygula.sh"

# ---------------------------------------------------------------- sistem (sudo)
if [ "$SISTEMSIZ" -eq 0 ]; then
    adim "Giris ekrani (SDDM)"
    sudo install -d /usr/share/wallpapers/KorFurkan
    sudo cp -r "$D/wallpapers/KorFurkan/." /usr/share/wallpapers/KorFurkan/
    sudo install -d /etc/sddm.conf.d
    printf '[Theme]\nCurrent=breeze\nCursorTheme=Bibata-Modern-Classic\nCursorSize=24\n' | sudo tee /etc/sddm.conf.d/kor.conf >/dev/null
    printf '[General]\ntype=image\nbackground=/usr/share/wallpapers/KorFurkan/contents/images/3840x2160.png\n' \
        | sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null
    tamam "SDDM: Breeze + Kor duvar kagidi + Bibata imlec"
fi

# ---------------------------------------------------------------- uygula
if [ "$ERTELE" -eq 0 ] && pgrep -u "$USER" -x plasmashell >/dev/null && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    adim "Plasma'ya uygulaniyor"
    "$YER/uygula.sh"
else
    mkdir -p "$C/autostart"
    cat > "$C/autostart/kor-tema-uygula.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Kor temasini uygula
Exec=$YER/uygula.sh --giriste
X-KDE-autostart-phase=2
NoDisplay=true
EOF
    adim "Plasma oturumu bulunamadi: tema bir sonraki giriste uygulanacak"
fi

printf "\n${k}kor${z} ${s}❯ kuruldu.${z} Kilit ekrani ve pencere efektlerinin tam oturmasi icin oturumu kapatip yeniden gir.\n"
printf "  ${s}yedek: %s${z}\n\n" "$YEDEK"
