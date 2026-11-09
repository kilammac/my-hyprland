import QtQuick

Item {
    id: root
    readonly property var youtubeHistory: history.entries
    property bool online: false
    property real volume: 0.5
    property string validationError: ""
    readonly property var tracks: online ? [youtube.url] : local.tracks
    readonly property int index: online ? (youtube.url ? 0 : -1) : local.index
    readonly property bool playing: online ? youtube.playing : local.playing
    readonly property bool loading: online ? youtube.loading : local.scanning
    readonly property string title: online ? youtube.title : local.title
    readonly property string artist: online ? youtube.artist : local.artist
    readonly property string error: validationError || (online ? youtube.error : local.error)
    readonly property real position: online ? youtube.position : local.player.position
    readonly property real duration: online ? youtube.duration : local.player.duration
    readonly property bool seekable: online ? youtube.seekable : local.player.seekable
    function time(ms) { return local.time(ms); }
    function load(urls) { validationError = ""; youtube.stop(); online = false; local.load(urls); }
    function openFolder(url) { validationError = ""; youtube.stop(); online = false; local.stop(); local.openFolder(url); }
    function openYoutube(url) {
        if (!youtube.normalize(url)) { validationError = "Lien YouTube invalide : choisissez une vidéo individuelle."; return false; }
        validationError = ""; local.stop(); local.scanning = false; online = true;
        const accepted = youtube.open(url);
        if (accepted) history.remember(youtube.url);
        return accepted;
    }
    function play() { validationError = ""; online ? youtube.play() : local.play(); }
    function pause() { online ? youtube.pause() : local.player.pause(); }
    function stop() { online ? youtube.stop() : local.stop(); }
    function seek(ms) { if (online) youtube.seek(ms); else if (seekable) local.player.position = ms; }
    function next() { if (!online) local.next(); }
    function previous() { if (online) youtube.seek(0); else local.previous(); }
    function choose(i, autoplay) { if (online) { if (autoplay) youtube.play(); } else local.choose(i, autoplay); }
    function trackLabel(url) { return online ? youtube.title : decodeURIComponent(String(url).split('/').pop()); }
    DeckEngine { id: local; volume: root.volume }
    YoutubeHistory { id: history }
    YoutubeEngine {
        id: youtube; volume: root.volume
        onTitleResolved: (url, title) => history.updateTitle(url, title)
    }
}
