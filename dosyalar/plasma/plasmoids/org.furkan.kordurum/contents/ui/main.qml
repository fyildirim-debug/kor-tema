// Kor Durum: ust cubukta islemci, sicaklik, ekran karti, bellek ve ag durumu (tiklayinca btop)
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: kok

    readonly property color vurgu: "#EE5A36"
    readonly property color soluk: "#8A8B93"
    readonly property string yazi: "JetBrainsMono Nerd Font"
    readonly property real boy: 9.5

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    toolTipMainText: "Sistem durumu"
    toolTipSubText: "Ayrıntı için tıkla (btop)"

    function hiz(b) {
        if (!(b >= 0)) return "0B"
        if (b < 1024) return Math.round(b) + "B"
        if (b < 1048576) return Math.round(b / 1024) + "K"
        return (b / 1048576).toFixed(1) + "M"
    }

    Sensors.Sensor { id: islemci; sensorId: "cpu/all/usage"; updateRateLimit: 1500 }
    Sensors.Sensor { id: isi; sensorId: "cpu/all/averageTemperature"; updateRateLimit: 3000 }
    Sensors.Sensor { id: ekran; sensorId: "gpu/all/usage"; updateRateLimit: 3000 }
    Sensors.Sensor { id: bellek; sensorId: "memory/physical/used"; updateRateLimit: 3000 }
    Sensors.Sensor { id: indir; sensorId: "network/all/download"; updateRateLimit: 1500 }
    Sensors.Sensor { id: yukle; sensorId: "network/all/upload"; updateRateLimit: 1500 }

    P5Support.DataSource {
        id: calistir
        engine: "executable"
        onNewData: (kaynak) => disconnectSource(kaynak)
    }

    component Oge: RowLayout {
        id: oge
        property string etiket
        property string deger
        property string kalip: "000%"
        spacing: 5
        Text {
            text: oge.etiket
            color: kok.vurgu
            font.family: kok.yazi
            font.pointSize: kok.boy
            font.weight: Font.Bold
        }
        Text {
            text: oge.deger
            color: Kirigami.Theme.textColor
            font.family: kok.yazi
            font.pointSize: kok.boy
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: olcu.advanceWidth
            TextMetrics { id: olcu; font.family: kok.yazi; font.pointSize: kok.boy; text: oge.kalip }
        }
    }

    component Ayrac: Text {
        text: "│"
        color: kok.soluk
        opacity: 0.45
        font.family: kok.yazi
        font.pointSize: kok.boy
    }

    fullRepresentation: MouseArea {
        Layout.minimumWidth: satir.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        Layout.fillHeight: true
        cursorShape: Qt.PointingHandCursor
        onClicked: calistir.connectSource("ghostty -e btop")

        RowLayout {
            id: satir
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing
            Oge { etiket: "cpu"; deger: Math.round(islemci.value || 0) + "%"; kalip: "00%" }
            Oge { etiket: "tmp"; deger: Math.round(isi.value) + "°"; kalip: "000°"; visible: isi.value > 0 }
            Oge { etiket: "gpu"; deger: Math.round(ekran.value) + "%"; visible: ekran.value >= 0 }
            Oge { etiket: "mem"; deger: ((bellek.value || 0) / 1073741824).toFixed(1) + "G"; kalip: "00.0G" }
            Ayrac {}
            Oge { etiket: "↓"; deger: kok.hiz(indir.value); kalip: "000.0M" }
            Oge { etiket: "↑"; deger: kok.hiz(yukle.value); kalip: "000.0M" }
        }
    }
}
