// Kor Masa: masaustunde surekli duran btop ozeti, tamamen ASCII kipinde 
import QtQuick
import QtQuick.Layouts
import QtQml
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: kok

    readonly property string kor: "#EE5A36"
    readonly property string amber: "#F2AA3C"
    readonly property string metin: "#E8E6E3"
    readonly property string soluk: "#8A8B93"
    readonly property string hat: "#4A4C56"
    readonly property string iz: "#2E3038"
    readonly property string yazi: "JetBrainsMono Nerd Font"
    readonly property int gen: 48          // kutu genisligi (karakter)
    readonly property int ici: gen - 4       // kutu ici
    readonly property int grafikSatir: 4
    readonly property int agSatir: 2

    property var cpuGecmis: []
    property var inGecmis: []
    property var outGecmis: []
    property var surecler: []
    property string ekranMetni: ""

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    toolTipMainText: "Kor Masa"
    toolTipSubText: "btop özeti"

    // ---- yardimcilar ----
    function kac(s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") }
    function tekrar(c, n) { var s = ""; for (var i = 0; i < n; i++) s += c; return s }
    function sag(s, n) { s = String(s); return s.length >= n ? s.slice(0, n) : tekrar(" ", n - s.length) + s }
    function sol(s, n) { s = String(s); return s.length >= n ? s.slice(0, n) : s + tekrar(" ", n - s.length) }
    function hiz(b) {
        if (!(b >= 0)) return "0B"
        if (b < 1024) return Math.round(b) + "B"
        if (b < 1048576) return Math.round(b / 1024) + "K"
        if (b < 1073741824) return (b / 1048576).toFixed(b < 104857600 ? 1 : 0) + "M"
        return (b / 1073741824).toFixed(1) + "G"
    }
    function gb(b) { return ((b || 0) / 1073741824).toFixed(1) }
    function sure(sn) {
        sn = Math.floor(sn || 0)
        var g = Math.floor(sn / 86400), s = Math.floor(sn % 86400 / 3600), d = Math.floor(sn % 3600 / 60)
        return (g > 0 ? g + "g " : "") + (g > 0 || s > 0 ? s + "sa " : "") + d + "dk"
    }
    function ekle(dizi, deger) {
        var y = dizi.slice(-(ici - 1))
        y.push(deger || 0)
        return y
    }
    function yuzdeRenk(v) { return v > 70 ? kor : (v > 35 ? amber : metin) }

    // satir: [[metin, renk], ...] parcalarindan olusur
    function boya(parcalar) {
        var h = ""
        for (var i = 0; i < parcalar.length; i++) {
            var p = parcalar[i]
            h += p[1] ? '<span style="color:' + p[1] + '">' + kac(p[0]) + '</span>' : kac(p[0])
        }
        return h
    }
    function uzunluk(parcalar) { var n = 0; for (var i = 0; i < parcalar.length; i++) n += String(parcalar[i][0]).length; return n }
    function ust(no, ad, sagYazi) {
        var sg = sagYazi ? " " + sagYazi + " " : ""
        var dolgu = gen - 2 - (no + ad).length - sg.length - 2
        return boya([["╭─", hat], [no, soluk], [ad, kor], [tekrar("─", Math.max(0, dolgu)), hat], [sg, soluk], ["─╮", hat]])
    }
    function alt(sagYazi) {
        var sg = sagYazi ? " " + sagYazi + " " : ""
        return boya([["╰", hat], [tekrar("─", gen - 3 - sg.length), hat], [sg, soluk], ["─╯", hat]])
    }
    function ic(parcalar) {
        var bos = ici - uzunluk(parcalar)
        return boya([["│ ", hat]].concat(parcalar).concat([[tekrar(" ", Math.max(0, bos)), null], [" │", hat]]))
    }
    function cubuk(oran, n) {
        oran = Math.min(1, Math.max(0, oran || 0))
        var dolu = Math.round(oran * n)
        var p = []
        for (var i = 0; i < dolu; i++) p.push(["■", i / n < 0.6 ? amber : kor])
        p.push([tekrar("■", n - dolu), iz])
        return p
    }
    // blok grafik: satirlar ustten alta
    function grafik(veri, satir, tavan, renkUst, renkAlt) {
        var bloklar = " ▁▂▃▄▅▆▇█"
        var ustSinir = tavan > 0 ? tavan : Math.max.apply(null, veri.concat([2048]))
        var cizgiler = []
        for (var r = 0; r < satir; r++) {
            var s = tekrar(" ", ici - veri.length)
            for (var i = 0; i < veri.length; i++) {
                var h = Math.min(1, (veri[i] || 0) / ustSinir) * satir * 8
                var seviye = Math.max(0, Math.min(8, Math.round(h - (satir - 1 - r) * 8)))
                s += bloklar.charAt(seviye)
            }
            cizgiler.push(ic([[s, r < satir / 2 ? renkUst : renkAlt]]))
        }
        return cizgiler
    }

    function ciz() {
        var L = []
        var cpu = islemci.value || 0

        // ---- cpu ----
        var cpuSag = Math.round(cpu) + "% " + (isi.value > 0 ? Math.round(isi.value) + "° " : "") + ((frekans.value || 0) / 1000).toFixed(1) + "GHz"
        L.push(ust("¹", "cpu", cpuSag))
        L = L.concat(grafik(cpuGecmis, grafikSatir, 100, kor, amber))
        var n = cekirdekler.count
        var sutun = 3, satirSay = Math.ceil(n / sutun)
        for (var r = 0; r < satirSay; r++) {
            var p = []
            for (var s = 0; s < sutun; s++) {
                var k = s * satirSay + r
                if (k >= n) break
                var o = cekirdekler.objectAt(k)
                var v = o ? (o.value || 0) : 0
                if (s > 0) p.push(["  ", null])
                p.push([sol("C" + k, 4), soluk])
                p = p.concat(cubuk(v / 100, 5))
                p.push([sag(Math.round(v) + "%", 4), yuzdeRenk(v)])
            }
            L.push(ic(p))
        }
        L.push(alt("up " + sure(acik.value)))

        // ---- sistem ----
        L.push(ust("²", "mem", pil.value > 0 ? "bat " + Math.round(pil.value) + "%" : ""))
        function olcer(ad, oran, deger) {
            return ic([[sol(ad, 5), kor]].concat(cubuk(oran, ici - 5 - 11)).concat([[sag(deger, 11), metin]]))
        }
        L.push(olcer("mem", (bellek.value || 0) / (bellekTop.value || 1), gb(bellek.value) + "/" + Math.round((bellekTop.value || 0) / 1073741824) + "G"))
        if (takasTop.value > 0)
            L.push(olcer("swap", (takas.value || 0) / (takasTop.value || 1), gb(takas.value) + "/" + Math.round((takasTop.value || 0) / 1073741824) + "G"))
        if (ekran.value >= 0)
            L.push(olcer("gpu", (ekran.value || 0) / 100, Math.round(ekran.value || 0) + "%" + (ekranIsi.value > 0 ? " " + Math.round(ekranIsi.value) + "°" : "")))
        L.push(olcer("disk", (disk.value || 0) / 100, Math.round((diskKul.value || 0) / 1073741824) + "/" + Math.round((diskTop.value || 0) / 1073741824) + "G"))
        L.push(alt(""))

        // ---- ag ----
        L.push(ust("³", "net", "↓" + hiz(indir.value) + " ↑" + hiz(yukle.value)))
        L = L.concat(grafik(inGecmis, agSatir, 0, kor, kor))
        L = L.concat(grafik(outGecmis, agSatir, 0, amber, amber))
        L.push(alt(""))

        // ---- surecler ----
        L.push(ust("⁴", "proc", "cpu     mem"))
        for (var i = 0; i < 5; i++) {
            var sr = surecler[i]
            if (!sr) { L.push(ic([])); continue }
            L.push(ic([[sol(sr.ad, ici - 15), i === 0 ? metin : soluk],
                       [sag(sr.cpu.toFixed(1) + "%", 7), yuzdeRenk(sr.cpu)],
                       [sag(hiz(sr.rss), 8), soluk]]))
        }
        L.push(alt(makine.value ? "kor ❯ " + makine.value : ""))

        ekranMetni = '<pre style="font-family:\'' + yazi + '\'; margin:0">' + L.join("\n") + '</pre>'
    }

    // ---- sensorler ----
    Sensors.Sensor { id: islemci; sensorId: "cpu/all/usage"; updateRateLimit: 1500 }
    Sensors.Sensor { id: isi; sensorId: "cpu/all/averageTemperature"; updateRateLimit: 3000 }
    Sensors.Sensor { id: frekans; sensorId: "cpu/all/averageFrequency"; updateRateLimit: 3000 }
    Sensors.Sensor { id: cekirdek; sensorId: "cpu/all/coreCount" }
    Instantiator {
        id: cekirdekler
        model: Math.max(0, cekirdek.value || 0)
        delegate: Sensors.Sensor { sensorId: "cpu/cpu" + index + "/usage"; updateRateLimit: 1500 }
    }
    Sensors.Sensor { id: bellek; sensorId: "memory/physical/used"; updateRateLimit: 3000 }
    Sensors.Sensor { id: bellekTop; sensorId: "memory/physical/total" }
    Sensors.Sensor { id: takas; sensorId: "memory/swap/used"; updateRateLimit: 5000 }
    Sensors.Sensor { id: takasTop; sensorId: "memory/swap/total" }
    Sensors.Sensor { id: ekran; sensorId: "gpu/all/usage"; updateRateLimit: 3000 }
    Sensors.Sensor { id: ekranIsi; sensorId: "gpu/gpu0/temperature"; updateRateLimit: 5000 }
    Sensors.Sensor { id: disk; sensorId: "disk/all/usedPercent"; updateRateLimit: 30000 }
    Sensors.Sensor { id: diskKul; sensorId: "disk/all/used"; updateRateLimit: 30000 }
    Sensors.Sensor { id: diskTop; sensorId: "disk/all/total"; updateRateLimit: 30000 }
    Sensors.Sensor { id: indir; sensorId: "network/all/download"; updateRateLimit: 1500 }
    Sensors.Sensor { id: yukle; sensorId: "network/all/upload"; updateRateLimit: 1500 }
    Sensors.Sensor { id: acik; sensorId: "os/system/uptime"; updateRateLimit: 60000 }
    Sensors.Sensor { id: makine; sensorId: "os/system/hostname" }
    Sensors.Sensor { id: pil; sensorId: "power/00001/chargePercentage"; updateRateLimit: 30000 }

    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            kok.cpuGecmis = kok.ekle(kok.cpuGecmis, islemci.value)
            kok.inGecmis = kok.ekle(kok.inGecmis, indir.value)
            kok.outGecmis = kok.ekle(kok.outGecmis, yukle.value)
            kok.ciz()
        }
    }

    // en yogun surecler (anlik cpu icin top'un ikinci olcumu)
    readonly property string surecKomutu: "LC_ALL=C top -b -n2 -d0.4 -w 200 -o %CPU | awk '/^top -/{n++} n==2 && /^ *[0-9]+ /{print $12\"|\"$9\"|\"$6; if(++c==5) exit}'"
    P5Support.DataSource {
        id: kabuk
        engine: "executable"
        onNewData: (kaynak, veri) => {
            disconnectSource(kaynak)
            if (kaynak !== kok.surecKomutu) return
            var satirlar = (veri.stdout || "").trim().split("\n")
            var y = []
            for (var i = 0; i < satirlar.length; i++) {
                var p = satirlar[i].split("|")
                if (p.length < 3) continue
                y.push({ ad: p[0], cpu: parseFloat(p[1]) || 0, rss: (parseFloat(p[2]) || 0) * 1024 })
            }
            kok.surecler = y
        }
    }
    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: kabuk.connectSource(kok.surecKomutu)
    }

    fullRepresentation: Item {
        id: alan
        Layout.minimumWidth: ekranYazi.implicitWidth + 28
        Layout.preferredWidth: Layout.minimumWidth
        Layout.minimumHeight: ekranYazi.implicitHeight + 28
        Layout.preferredHeight: Layout.minimumHeight

        Rectangle {
            anchors.centerIn: ekranYazi
            width: ekranYazi.implicitWidth + 28
            height: ekranYazi.implicitHeight + 24
            radius: 12
            color: "transparent"
        }

        Text {
            id: ekranYazi
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            text: kok.ekranMetni
            color: kok.metin
            font.family: kok.yazi
            font.pointSize: 9
        }
    }
}
