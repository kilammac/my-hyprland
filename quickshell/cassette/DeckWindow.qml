pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

FloatingWindow {
    id: window
    onClosed: window.visible = false
    property alias face: face
    title: "Cassette Deck"
    implicitWidth: 680; implicitHeight: 950
    minimumSize: Qt.size(640, 880)
    color: "#121413"
    DeckController { id: deck }
    MeterFeed { id: meters; active: deck.playing && window.visible }
    FileDialog {
        id: files; title: "Ouvrir des morceaux"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Audio (*.mp3 *.flac *.ogg *.opus *.wav *.m4a *.aac *.aiff *.wma)", "Tous les fichiers (*)"]
        onAccepted: deck.load(selectedFiles)
    }
    FolderDialog { id: folder; title: "Ouvrir un dossier musical"; onAccepted: deck.openFolder(selectedFolder) }
    Popup {
        id: youtubeDialog
        parent: window.contentItem
        anchors.centerIn: parent
        width: Math.min(560, window.contentItem.width - 40)
        padding: 20; modal: true; focus: true
        background: Rectangle { color: "#20271f"; radius: 8; border.color: "#70816a" }
        onOpened: { linkError.text = ""; linkInput.forceActiveFocus(); }
        function submit() {
            if (deck.openYoutube(linkInput.text)) close();
            else linkError.text = "Collez un lien vers une vidéo YouTube individuelle.";
        }
        contentItem: ColumnLayout {
            spacing: 12
            Label { text: "Écouter YouTube"; color: "#d0c6ad"; font.pixelSize: 20 }
            TextField {
                id: linkInput
                Layout.fillWidth: true
                placeholderText: "https://www.youtube.com/watch?v=…"
                color: "#d7dfcf"; placeholderTextColor: "#8b9582"
                selectByMouse: true
                background: Rectangle { color: "#121812"; radius: 4; border.color: linkInput.activeFocus ? "#8db197" : "#54604d" }
                onAccepted: youtubeDialog.submit()
            }
            Label { text: "Audio uniquement · une vidéo à la fois"; color: "#a2ac97" }
            Label {
                text: "Historique · 10 derniers liens"
                color: "#d0c6ad"; font.bold: true
            }
            Label { visible: deck.youtubeHistory.length === 0; text: "Vos liens apparaîtront ici."; color: "#a2ac97" }
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(260, contentHeight)
                clip: true; spacing: 4
                model: deck.youtubeHistory
                delegate: ItemDelegate {
                    id: historyRow
                    required property var modelData
                    width: ListView.view.width; height: 50
                    Accessible.name: "Réécouter " + modelData.title
                    background: Rectangle { color: historyRow.hovered ? "#35422e" : "#192016"; radius: 4 }
                    contentItem: Column {
                        spacing: 2
                        Label { width: parent.width; text: "▶  " + historyRow.modelData.title; elide: Text.ElideRight; color: "#d7dfcf" }
                        Label { width: parent.width; text: historyRow.modelData.url; elide: Text.ElideRight; color: "#95a388"; font.pixelSize: 10 }
                    }
                    onClicked: { if (deck.openYoutube(modelData.url)) youtubeDialog.close(); }
                }
                ScrollBar.vertical: ScrollBar {}
            }
            Label { id: linkError; Layout.fillWidth: true; wrapMode: Text.Wrap; color: "#e49b86" }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                DeckButton { text: "Annuler"; onClicked: youtubeDialog.close() }
                DeckButton { text: "Écouter"; onClicked: youtubeDialog.submit() }
            }
        }
    }
    GlobalShortcut {
        appid: "quickshell"
        name: "cassette"
        onPressed: window.visible = !window.visible
    }
    IpcHandler {
        target: "cassette"
        function show(): void { window.visible = true; }
        function hide(): void { window.visible = false; }
        function play(): void { deck.play(); }
        function pause(): void { deck.pause(); }
        function stop(): void { deck.stop(); }
        function next(): void { deck.next(); }
        function previous(): void { deck.previous(); }
        function open(url: string): void { deck.load([url]); }
        function youtube(url: string): bool { window.visible = true; return deck.openYoutube(url); }
        function status(): string { return JSON.stringify({ title: deck.title, index: deck.index, count: deck.tracks.length, position: deck.position, duration: deck.duration, playing: deck.playing, loading: deck.loading, source: deck.online ? "youtube" : "local", error: deck.error }); }
    }
    Shortcut { enabled: !youtubeDialog.opened; sequence: "Space"; onActivated: deck.playing ? deck.pause() : deck.play() }
    Shortcut { sequence: "Ctrl+O"; onActivated: files.open() }
    Shortcut { enabled: !youtubeDialog.opened; sequence: "Escape"; onActivated: window.visible = false }
    ColumnLayout {
        id: face
        anchors.fill: parent; anchors.margins: 26; spacing: 12
        RowLayout {
            Layout.fillWidth: true
            Label { text: "CASSETTE / 01"; color: "#d0c6ad"; font.pixelSize: 22; font.letterSpacing: 3; font.bold: true; Layout.fillWidth: true }
            Label { text: deck.loading ? "◌ CHARGEMENT" : deck.playing ? "● RUNNING" : "○ STANDBY"; color: deck.playing ? "#6bbfa0" : "#8a8d82"; font.family: "monospace" }
        }
        Label { text: "STEREO TAPE DECK  /  ARCH LINUX"; color: "#7a8177"; font.pixelSize: 10; font.letterSpacing: 2 }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#44473f" }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            VuMeter { Layout.fillWidth: true; channel: "L"; level: meters.left }
            ColumnLayout {
                spacing: 9
                Repeater {
                    model: 3
                    delegate: Item {
                        required property int index
                        implicitWidth: 34
                        implicitHeight: index === 1 ? 16 : 30
                        Rectangle {
                            anchors.centerIn: parent
                            visible: parent.index !== 1
                            width: 29; height: 29; radius: 15
                            color: "#15191c"; border.color: "#373e43"; border.width: 2
                            Rectangle {
                                id: peakLamp
                                anchors.centerIn: parent
                                width: 19; height: 19; radius: 10
                                readonly property bool peak: (parent.parent.index === 0 ? meters.left : meters.right) > 0.9
                                gradient: Gradient {
                                    GradientStop { position: 0; color: peakLamp.peak ? "#ffa463" : "#777b79" }
                                    GradientStop { position: 1; color: peakLamp.peak ? "#b62e17" : "#303637" }
                                }
                            }
                        }
                        Label {
                            anchors.centerIn: parent
                            visible: parent.index === 1
                            text: "PEAK"; color: "#737b7e"; font.bold: true; font.pixelSize: 10
                        }
                    }
                }
            }
            VuMeter { Layout.fillWidth: true; channel: "R"; level: meters.right }
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: "COMPACT CASSETTE PLAYER"; color: "#969fa6"
                font.italic: true; font.bold: true; font.pixelSize: 16
            }
            Rectangle {
                implicitWidth: 110; implicitHeight: 26; color: "#ff7900"
                Label { anchors.centerIn: parent; text: "STEREO"; color: "#fff3da"; font.italic: true; font.bold: true; font.pixelSize: 18 }
            }
        }
        Cassette { Layout.alignment: Qt.AlignHCenter; playing: deck.playing; progress: deck.duration ? deck.position / deck.duration : 0 }
        Label { text: meters.status; color: "#868e80"; font.pixelSize: 10 }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 68; radius: 5; color: "#1e2822"; border.color: "#455448"
            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 5
                Label { width: parent.width; text: deck.title; elide: Text.ElideRight; color: "#bdd0a8"; font.pixelSize: 18; font.family: "monospace" }
                Label { width: parent.width; text: deck.artist; elide: Text.ElideRight; color: "#8d9e7e" }
            }
        }
        RowLayout {
            Label { text: deck.time(deck.position); color: "#d0c6ad" }
            DeckSlider {
                Layout.fillWidth: true; from: 0; to: Math.max(1, deck.duration)
                enabled: deck.seekable
                value: deck.position
                onMoved: deck.seek(value)
                Accessible.name: "Position de lecture"
            }
            Label { text: deck.time(deck.duration); color: "#d0c6ad" }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            DeckButton { text: "⏮"; enabled: deck.index >= 0; onClicked: deck.previous(); Accessible.name: "Précédent" }
            DeckButton { text: "▶ Play"; enabled: deck.index >= 0; onClicked: deck.play() }
            DeckButton { text: "Ⅱ Pause"; enabled: deck.playing || deck.loading; onClicked: deck.pause() }
            DeckButton { text: "■ Stop"; enabled: deck.index >= 0; onClicked: deck.stop() }
            DeckButton { text: "⏭"; enabled: deck.index >= 0 && deck.index + 1 < deck.tracks.length; onClicked: deck.next(); Accessible.name: "Suivant" }
        }
        RowLayout {
            DeckButton { text: "Fichiers…"; onClicked: files.open() }
            DeckButton { text: "Dossier…"; onClicked: folder.open() }
            DeckButton { text: "YouTube…"; onClicked: youtubeDialog.open() }
            Label { text: "VOL"; color: "#b7b9aa" }
            DeckSlider { Layout.fillWidth: true; from: 0; to: 1; value: deck.volume; onMoved: deck.volume = value; Accessible.name: "Volume" }
            Label { text: Math.round(deck.volume * 100) + "%"; color: "#b7b9aa" }
        }
        Label { visible: deck.error.length > 0; text: deck.error; color: "#e49b86"; Layout.fillWidth: true; wrapMode: Text.Wrap }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 55
            clip: true; model: deck.tracks; spacing: 2
            delegate: ItemDelegate {
                required property int index
                required property string modelData
                width: ListView.view.width; height: 32
                text: (index === deck.index ? "▶  " : "    ") + deck.trackLabel(modelData)
                highlighted: index === deck.index
                palette.text: "#c6cdb9"
                palette.highlightedText: "#e5efdc"
                palette.highlight: "#38463a"
                onClicked: deck.choose(index, true)
            }
            ScrollBar.vertical: ScrollBar {}
        }
    }
}
