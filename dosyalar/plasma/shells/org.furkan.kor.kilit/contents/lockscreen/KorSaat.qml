// Kor kilit ekrani saati: eş aralıklı saat, kor vurgu, commit cizgisi motifi
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.clock as PlasmaClock

ColumnLayout {
    id: root
    spacing: 6

    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property color kor: "#EE5A36"
    readonly property color amber: "#F2AA3C"
    readonly property color metin: "#E8E6E3"
    readonly property color soluk: "#8A8B93"
    readonly property color hat: "#4A4C56"
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    component Yazi: Text {
        font.family: root.mono
        color: root.metin
        textFormat: Text.StyledText
        renderType: Text.NativeRendering
        style: root.softwareRendering ? Text.Outline : Text.Normal
        styleColor: "#0e0f12"
        Layout.alignment: Qt.AlignHCenter
    }

    Yazi {
        text: '<font color="' + root.soluk + '">~/kor</font> <font color="' + root.kor + '">❯</font> <font color="' + root.soluk + '">kilitli</font>'
        font.pointSize: 11
    }

    Yazi {
        readonly property var p: Qt.formatTime(saat.dateTime, "HH:mm").split(":")
        text: p[0] + '<font color="' + root.kor + '">:</font>' + p[1]
        font.pointSize: 72
        font.weight: Font.Bold
        font.letterSpacing: 2
    }

    Yazi {
        text: Qt.locale("tr_TR").toString(saat.dateTime, "dddd, d MMMM").toLocaleLowerCase(Qt.locale("tr_TR"))
        color: root.soluk
        font.pointSize: 14
        font.letterSpacing: 1
    }

    // commit cizgisi: gunun saatine gore HEAD ilerler
    Yazi {
        Layout.topMargin: 10
        readonly property int uzun: 29
        readonly property int head: Math.round((saat.dateTime.getHours() * 60 + saat.dateTime.getMinutes()) / 1440 * (uzun - 1))
        text: {
            var s = ""
            for (var i = 0; i < uzun; i++) {
                if (i === head) s += '<font color="' + root.kor + '"><b>●</b></font>'
                else if (i % 4 === 0) s += '<font color="' + (i < head ? root.amber : root.hat) + '">' + (i < head ? '●' : '○') + '</font>'
                else s += '<font color="' + (i < head ? root.kor : root.hat) + '">─</font>'
            }
            return s
        }
        font.pointSize: 11
    }

    PlasmaClock.Clock {
        id: saat
        trackSeconds: false
    }
}
