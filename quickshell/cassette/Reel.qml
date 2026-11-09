pragma ComponentBehavior: Bound
import QtQuick
Rectangle {
    id: root
    property bool spinning: false
    property real tape: 0.5
    width: 142; height: width; radius: width / 2
    color: "#15130f"; border.color: "#6a5540"; border.width: 2
    Rectangle {
        anchors.centerIn: parent
        width: 64 + 65 * root.tape; height: width; radius: width / 2
        color: "#3d2b20"; border.color: "#74523b"; border.width: 3
    }
    Item {
        id: wheel; anchors.fill: parent
        NumberAnimation on rotation {
            from: 0; to: 360; duration: 2400; loops: Animation.Infinite
            running: true; paused: !root.spinning
        }
        Repeater {
            model: 6
            Rectangle {
                required property int index
                x: root.width / 2 - width / 2; y: root.height / 2 - height / 2
                width: 13; height: 65; radius: 3; color: "#b5b2a5"
                rotation: index * 60
            }
        }
        Rectangle {
            anchors.centerIn: parent; width: 38; height: width; radius: width / 2
            color: "#d3cec0"; border.color: "#55514a"; border.width: 4
            Rectangle { anchors.centerIn: parent; width: 15; height: 15; radius: 3; color: "#151515" }
        }
    }
}
