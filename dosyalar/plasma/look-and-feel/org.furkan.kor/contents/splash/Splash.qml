// Kor acilis ekrani: murekkep zemin, duvar kagidindaki commit cizgisi.
// Her oturum asamasinda bir commit yanar; son asamada HEAD parlar.
import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root
    color: "#0e0f12"

    property int stage
    readonly property int adim: 6
    readonly property color kor: "#ee5a36"
    readonly property color amber: "#f2aa3c"
    readonly property color sonuk: "#3a3c45"
    readonly property string mono: "JetBrainsMono Nerd Font"

    onStageChanged: {
        if (stage == 1) giris.running = true
    }

    // alttan yukselen sicak isik
    Shape {
        anchors.fill: parent
        opacity: icerik.opacity * 0.55
        ShapePath {
            strokeWidth: -1
            fillGradient: RadialGradient {
                centerX: root.width / 2; centerY: root.height * 1.05
                focalX: centerX; focalY: centerY
                centerRadius: root.height * 0.75
                focalRadius: 0
                GradientStop { position: 0.0; color: "#80ee5a36" }
                GradientStop { position: 0.45; color: "#26ee5a36" }
                GradientStop { position: 1.0; color: "#00ee5a36" }
            }
            startX: 0; startY: 0
            PathLine { x: root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }

    Item {
        id: icerik
        anchors.fill: parent
        opacity: 0

        NumberAnimation on opacity {
            id: giris
            running: false
            from: 0; to: 1
            duration: 500
            easing.type: Easing.OutCubic
        }

        Item {
            id: hat
            width: Math.min(root.width * 0.42, 820)
            height: 40
            anchors.centerIn: parent

            // sonuk ana cizgi
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 2
                color: root.sonuk
            }
            // ilerleyen kor cizgi
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 2
                width: parent.width * Math.min(root.stage, root.adim) / root.adim
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.kor }
                    GradientStop { position: 1.0; color: root.amber }
                }
                Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
            }

            Repeater {
                model: root.adim + 1
                Rectangle {
                    readonly property bool yandi: index <= root.stage
                    readonly property bool head: index == root.adim
                    x: hat.width * index / root.adim - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: head ? 16 : 10
                    height: width
                    radius: width / 2
                    color: yandi ? (head ? root.kor : root.color) : root.color
                    border.width: 2
                    border.color: yandi ? (index == 0 ? root.kor : root.amber) : root.sonuk
                    Behavior on border.color { ColorAnimation { duration: 300 } }

                    // HEAD parlamasi
                    Rectangle {
                        visible: parent.head && parent.yandi
                        anchors.centerIn: parent
                        width: 64; height: 64; radius: 32
                        color: root.kor
                        opacity: 0.18
                        SequentialAnimation on scale {
                            running: parent.visible
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.6; to: 1.1; duration: 900; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.1; to: 0.6; duration: 900; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: hat.horizontalCenter
            anchors.bottom: hat.top
            anchors.bottomMargin: 36
            text: "kor"
            color: "#e8e6e3"
            font.family: root.mono
            font.pixelSize: 44
            font.weight: Font.Bold
            font.letterSpacing: 6
        }

        Text {
            anchors.horizontalCenter: hat.horizontalCenter
            anchors.top: hat.bottom
            anchors.topMargin: 28
            text: "~/kor ❯ " + (root.stage >= root.adim ? "hazır" : "oturum açılıyor")
            color: "#96969e"
            font.family: root.mono
            font.pixelSize: 14
        }
    }
}
