// Kor duzeni: ustte ince cubuk (calisma alanlari | ortada saat | sistem durumu + tepsi),
// solda tam boy dok, ana ekranin masaustunde sag ustte Kor Masa (btop ozeti)
var MONO = "JetBrainsMono Nerd Font"
var DUVAR = "file://__EV__/.local/share/wallpapers/KorFurkan/contents/images/3840x2160.png"

var ust = new Panel
ust.location = "top"
ust.height = 2 * Math.round(gridUnit * 1.7 / 2)
ust.floating = false
ust.addWidget("org.kde.plasma.pager")
ust.addWidget("org.kde.plasma.panelspacer")
var saat = ust.addWidget("org.kde.plasma.digitalclock")
saat.currentConfigGroup = ["Appearance"]
saat.writeConfig("showDate", true)
saat.writeConfig("dateDisplayFormat", 1)
saat.writeConfig("dateFormat", "custom")
saat.writeConfig("customDateFormat", "ddd dd MMM")
saat.writeConfig("autoFontAndSize", false)
saat.writeConfig("fontFamily", MONO)
saat.writeConfig("fontWeight", 600)
saat.writeConfig("fontSize", 10)
ust.addWidget("org.kde.plasma.panelspacer")
ust.addWidget("org.furkan.kordurum")
ust.addWidget("org.kde.plasma.systemtray")

var dok = new Panel
dok.location = "left"
dok.height = 2 * Math.round(gridUnit * 3.4 / 2)
dok.floating = false
var gorev = dok.addWidget("org.kde.plasma.icontasks")
gorev.currentConfigGroup = ["General"]
gorev.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:google-chrome.desktop",
    "applications:mailhere.desktop",
    "applications:officehere.desktop",
    "applications:vscodium.desktop",
    "applications:com.mitchellh.ghostty.desktop",
    "applications:claude-code.desktop",
    "applications:org.kde.kate.desktop",
])
var izgara = dok.addWidget("org.kde.plasma.kickerdash")
izgara.currentConfigGroup = ["Shortcuts"]
izgara.writeConfig("global", "Alt+F1")
izgara.currentConfigGroup = ["General"]
izgara.writeConfig("icon", "view-app-grid-symbolic")

var masalar = desktops()
for (var i = 0; i < masalar.length; i++) {
    masalar[i].wallpaperPlugin = "org.kde.image"
    masalar[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"]
    masalar[i].writeConfig("Image", DUVAR)
}

// Kor Masa: panellerin bulundugu (ana) ekranin masaustunde, sag ustte
var anaEkran = ust.screen
for (var j = 0; j < masalar.length; j++) {
    if (masalar[j].screen === anaEkran) {
        var g = screenGeometry(anaEkran)
        masalar[j].addWidget("org.furkan.kormasa", g.width - 480, 64, 416, 704)
    }
}
