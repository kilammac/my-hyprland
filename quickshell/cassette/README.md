# Cassette Deck

Lecteur QML/QtMultimedia pour Quickshell, inspiré des platines cassette.
Versions vérifiées : Quickshell 0.3.2, Qt/QtMultimedia 6.12.0,
backend FFmpeg, Hyprland 0.57.1 (configuration Lua existante).
Aucun paquet ajouté. Cava, déjà installé, sert aux aiguilles.
YouTube utilise mpv 0.41.0, yt-dlp 2026.10.26 et Deno déjà installés.

## Utilisation intégrée

Le shell principal importe `qs.cassette` et crée `DeckWindow { visible: false }`.
Afficher le lecteur depuis un terminal de la session :

```sh
qs ipc -p ~/.config/quickshell/shell.qml call cassette show
```

Autres méthodes IPC : `hide`, `play`, `pause`, `stop`, `next`, `previous`,
`status`, et `open file:///chemin/morceau.flac` (chargement sans lecture automatique).
Espace bascule lecture/pause ; Ctrl+O ouvre des fichiers ; Échap masque la fenêtre.
Masquer la fenêtre laisse la lecture continuer, mais suspend Cava et les aiguilles.
La fermeture par le gestionnaire de fenêtres masque aussi la fenêtre Quickshell.

Un raccourci global `quickshell:cassette` est enregistré. Pour lui attribuer
une touche, ajouter au fichier **actif** `~/.config/hypr/config/keymaps.lua`,
avec une combinaison libre de votre choix :

```lua
hl.bind("SUPER + ALT + C", hl.dsp.global("quickshell:cassette"))
```

Cette liaison clavier n'a pas été ajoutée automatiquement.
La règle `title = "^Cassette Deck$", float = true` a été ajoutée dans
`~/.config/hypr/modules/windowrules.lua`. Si nécessaire, exécuter
`hyprctl reload` puis `hyprctl configerrors` dans la session.

## YouTube (audio)

Cliquez sur **YouTube…**, collez le lien d’une vidéo, puis **Écouter**.
Les liens watch, youtu.be, Shorts et live sont acceptés. Les paramètres de
playlist sont retirés : une vidéo à la fois, sans prise en charge des playlists.
La lecture démarre automatiquement. Play, Pause, Stop, volume et déplacement
pilotent mpv ; les titres et durées remontent par JSON IPC.
La recherche dans le morceau est désactivée si le flux ne la permet pas.
Précédent revient au début ; Suivant est désactivé en mode YouTube.

Commande depuis un terminal de la session :

```sh
qs ipc -p ~/.config/quickshell/shell.qml call cassette youtube 'https://www.youtube.com/watch?v=IDENTIFIANT'
```

L’identifiant doit être celui d’une vidéo réelle (11 caractères).
Pour une instance autonome, utilisez le chemin `~/.config/quickshell/cassette`
avec `-p`. Votre fonction Bash `mpva` reste inchangée : Quickshell lance
`mpv` directement, sans charger `.bashrc`, avec `--no-video` et votre sélection
`234/233/bestaudio/best`. Le moteur utilise une instance mpv dédiée sans
configuration ni scripts utilisateur, avec une socket privée sous
`XDG_RUNTIME_DIR`. Il reste disponible au repos après Stop et s’arrête avec le
composant Quickshell.

### Historique YouTube

Le dialogue **YouTube…** affiche les **10 derniers liens ouverts**.
Cliquez sur une entrée pour la réécouter. Le lien réécouté remonte en tête,
sans doublon. Les titres reçus de mpv sont conservés ; avant leur réception,
le lien sert de libellé. Un lien valide reste dans l’historique même si son
chargement échoue, pour pouvoir réessayer.

La sauvegarde est indépendante de la playlist locale et persiste après
fermeture/rechargement du lecteur. Elle se trouve dans
`$XDG_STATE_HOME/quickshell-cassette.ini`, ou par défaut
`~/.local/state/quickshell-cassette.ini` (section `YouTubeHistory`).
Aucune donnée d’historique personnel n’est incluse dans le dossier partagé.

Les fichiers locaux utilisent toujours QtMultimedia. Ouvrir une source arrête
l’autre moteur. Aucun téléchargement de fichier permanent n’est effectué.
Les flux privés, soumis à connexion ou refusés par YouTube peuvent échouer ;
aucun cookie de navigateur n’est importé automatiquement.
Si le streaming échoue, vérifier d’abord le même lien avec `mpva 'URL'`.
Le test de lecture Internet n’a pas pu aboutir dans l’environnement restreint
(DNS YouTube inaccessible, sockets Unix refusées).

## Lancement autonome

```sh
qs -p ~/.config/quickshell/cassette
```

Éviter de lancer simultanément les versions autonome et intégrée : elles
utilisent le même nom de raccourci global. L'IPC autonome utilise
`qs ipc -p ~/.config/quickshell/cassette call cassette show`.

## Modules

- `DeckController.qml` : commandes communes et sélection exclusive de la source.
- `YoutubeHistory.qml` : historique persistant de 10 liens, titres et déduplication.
- `YoutubeEngine.qml` : mpv audio et connexion JSON IPC, avec yt-dlp pour YouTube.
- `DeckEngine.qml` : MediaPlayer, AudioOutput, playlist, métadonnées,
  navigation et lecture d'un dossier avec FolderListModel.
- `DeckWindow.qml` : fenêtre native Quickshell, dialogues Qt, IPC et raccourci.
- `Cassette.qml`, `Reel.qml` : façade et bobines, animation suspendue en pause.
- `VuMeter.qml`, `MeterFeed.qml` : aiguilles et analyse Cava stéréo.
- `DeckButton.qml`, `DeckSlider.qml` : contrôles sombres indépendants du style Qt.

Les dossiers sont parcourus au premier niveau, triés par nom ; pas de scan récursif.
Ouvrir des fichiers/dossiers remplace la playlist et attend Play.
La fin d'un morceau passe au suivant ; la fin de playlist arrête la lecture.
Précédent revient au début après trois secondes, sinon au morceau précédent.
La playlist et le volume ne sont pas persistés entre deux lancements.
Ce lecteur ne publie pas de service MPRIS : le service `Players.qml` du dashboard
reste réservé aux lecteurs MPRIS existants.

## Source des vumètres

Cava analyse la sortie **système**, avec `pulse/auto`, comme le visualiseur
existant. D'autres applications peuvent donc influencer les aiguilles.
Deux bandes spectrales stéréo sont affichées : ce ne sont pas des mesures VU
RMS calibrées en dB, ni une analyse isolée du morceau. Aucun niveau aléatoire
n'est utilisé en fonctionnement normal. Si Cava échoue, les aiguilles reviennent
à zéro ; la lecture reste disponible.

## Vérification

```sh
~/.config/quickshell/cassette/tests/run.sh
```

Le script utilise les outils installés (`ffmpeg`, Python 3, Quickshell,
`/usr/lib/qt6/bin/qmllint`) et génère deux WAV de quatre secondes dans
`/tmp/cassette-test-audio`. Il vérifie dossier/URL accentuée, métadonnées,
durée, volume, lecture, pause, stop, seek, navigation, fin de playlist et
fichier absent. Une commande Cava simulée vérifie parsing stéréo et redémarrage.
`TestYoutube.qml` vérifie les URL, commandes et événements IPC simulés,
les métadonnées et le changement d’état entre deux vidéos.
`TestHistory.qml` vérifie la limite, l’ordre, les doublons, les titres et
la restauration dans un second processus ; les tests utilisent un dossier
d’état temporaire et ne touchent pas l’historique personnel.
`TestVisual.qml` produit `/tmp/cassette-preview.png`.

Le lint Qt 6 désactive uniquement les catégories import et unresolved-type,
car les métadonnées installées de Quickshell ne résolvent pas PostReloadHook /
GlobalShortcut dans qmllint. Le chargement réel dans Quickshell valide ces types.

Résultats dans l'environnement restreint : tests moteur, vumètres simulés,
rendu hors écran et syntaxe Lua réussis ; import `qs.cassette` vérifié séparément.
Sortie sonore, dialogues natifs, IPC de session, raccourci global et placement
Hyprland doivent encore être confirmés depuis le bureau : accès aux sockets
PipeWire/PulseAudio/Wayland/DBus refusé dans l'environnement d'exécution.

## Retirer l’intégration

Supprimer l’import `qs.cassette` et l’instance `DeckWindow` du shell,
puis la règle Hyprland dédiée et l’éventuel raccourci clavier.
Les sauvegardes initiales ont été supprimées à la demande du propriétaire.
