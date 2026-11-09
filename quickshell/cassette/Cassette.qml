pragma ComponentBehavior: Bound
import QtQuick
Rectangle {
    id: root
    property bool playing: false
    property real progress: 0
    width: 560; height: 268; radius: 16
    gradient: Gradient {
        GradientStop { position: 0; color: "#41403c" }
        GradientStop { position: 0.45; color: "#242523" }
        GradientStop { position: 1; color: "#151615" }
    }
    border.color: "#77736a"; border.width: 2
    Repeater {
        model: 4
        Rectangle {
            required property int index
            x: index % 2 ? root.width - 24 : 12
            y: index < 2 ? 12 : root.height - 24
            width: 12; height: 12; radius: 6; color: "#8a8780"
            Rectangle { anchors.centerIn: parent; width: 8; height: 2; rotation: 25; color: "#222" }
        }
    }
    Rectangle {
        x: 35; y: 25; width: parent.width - 70; height: 48; radius: 4; color: "#b9b09a"
        Text { anchors.centerIn: parent; text: "ARCH • CHROME   /   HIGH BIAS Ⅱ"; color: "#25251e"; font.family: "monospace"; font.pixelSize: 17; font.bold: true }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 5; color: "#b2603e" }
    }
    Rectangle { x: 45; y: 87; width: parent.width - 90; height: 149; radius: 65; color: "#101312"; border.color: "#67685d" }
    Reel { x: 60; y: 91; spinning: root.playing; tape: 1 - root.progress }
    Reel { x: parent.width - width - 60; y: 91; spinning: root.playing; tape: root.progress }
    Rectangle {
        anchors.centerIn: parent; anchors.verticalCenterOffset: 23
        width: 112; height: 49; radius: 5; color: "#292c25"; border.color: "#737565"
        Text { anchors.centerIn: parent; text: "A   ▰▰▰   90"; color: "#a7ac8b"; font.family: "monospace" }
    }
    Text { anchors.bottom: parent.bottom; anchors.bottomMargin: 9; anchors.horizontalCenter: parent.horizontalCenter; text: "STEREO CASSETTE  •  DOLBY SYSTEM"; color: "#99988b"; font.pixelSize: 10; font.letterSpacing: 2 }
}
