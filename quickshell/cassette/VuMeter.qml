import QtQuick
Rectangle {
    id: root
    property real level: 0
    property string channel: "L"
    implicitWidth: 275; implicitHeight: 106
    radius: 6; color: "#c9ba91"; border.color: "#0c0d0d"; border.width: 5
    Canvas {
        anchors.fill: parent
        onPaint: {
            const c = getContext('2d'); c.reset();
            const cx = width / 2, cy = height - 10, r = height - 30;
            for (let i = 0; i <= 12; i++) {
                const a = (-150 + i * 10) * Math.PI / 180;
                c.strokeStyle = i > 9 ? '#a53725' : '#403b30'; c.lineWidth = 2;
                c.beginPath(); c.moveTo(cx + Math.cos(a)*r, cy + Math.sin(a)*r);
                c.lineTo(cx + Math.cos(a)*(r-9), cy + Math.sin(a)*(r-9)); c.stroke();
            }
        }
    }
    Text { anchors.horizontalCenter: parent.horizontalCenter; y: 12; text: "−20    −10     −3    0   +3"; color: "#38362c"; font.pixelSize: 10 }
    Text { x: 18; y: 65; text: root.channel + "   VU"; color: "#5d4734"; font.bold: true }
    Item {
        x: parent.width/2; y: parent.height - 12
        rotation: -60 + Math.min(1, Math.max(0, root.level)) * 120
        Behavior on rotation { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        Rectangle { x: -1; y: -65; width: 2; height: 65; color: "#992e1f" }
        Rectangle { x: -5; y: -5; width: 10; height: 10; radius: 5; color: "#38362c" }
    }
}
