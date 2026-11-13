# Configuration Neovim

Configuration modulaire pour Neovim **0.12 ou supérieur**, avec `vim.pack`, le LSP natif, nvim-cmp, Conform, Oil et Telescope. Aucun Mason ou gestionnaire de plugins supplémentaire.

## Organisation

- `init.lua` : ordre de chargement et initialisation de la complétion au premier `InsertEnter` ou `CmdlineEnter`.
- `lua/config/options.lua` : options globales et leaders définis avant les plugins.
- `lua/config/plugins.lua` et `nvim-pack-lock.json` : dépendances et révisions des plugins.
- `lua/config/lsp.lua` : serveurs de langage et raccourcis locaux à leur attachement.
- `lua/config/format.lua` : politique unique de formatage et choix déterministe d’un seul LSP.
- `lua/config/util.lua` : seuil commun des gros buffers, actuellement **1 Mio**.
- `lua/config/treesitter.lua` : activation de la coloration native si un parseur est installé.
- `lua/config/git.lua` : navigation et aperçu des modifications Git.
- `after/ftplugin/` : exceptions d’indentation Python/Rust à quatre espaces et retour visuel Markdown.
- `lua/config/telescope.lua` : configuration initialisée au premier raccourci de recherche.

EditorConfig est intégré à Neovim. Les règles d’un `.editorconfig` de projet peuvent remplacer les valeurs d’indentation locales. Aucun fichier de projet n’est créé automatiquement.

## Outils externes

Les outils doivent être installés et accessibles depuis le `PATH` de Neovim. Leur installation et leurs mises à jour sont indépendantes de `vim.pack`.

| Serveur | Commande |
| --- | --- |
| Lua | `lua-language-server` |
| Python | `pyright-langserver` |
| JavaScript / TypeScript | `typescript-language-server` |
| ESLint | `vscode-eslint-language-server` |
| HTML / CSS / JSON | `vscode-html-language-server`, `vscode-css-language-server`, `vscode-json-language-server` |
| Tailwind | `tailwindcss-language-server` |
| Shell | `bash-language-server` |
| Rust | `rust-analyzer` ; `cargo` et Clippy pour les diagnostics demandés |
| C / C++ | `clangd` |
| Docker | `docker-langserver` |
| Docker Compose | `docker-compose-langserver` |
| Markdown | `marksman` |
| PHP | `intelephense` |
| YAML | `yaml-language-server` |
| Dart / Flutter | `dart` dans le SDK |

Formateurs : `stylua`, `isort`, `black`, `prettier`, `shfmt`, `rustfmt`.
Recherche : `rg` et `fd` ; Git : `git` ; presse-papiers Wayland : `wl-copy`, `wl-paste`.
Les commandes réellement choisies sont décrites par les configurations installées de nvim-lspconfig et Conform. La reconnaissance d’un projet et les versions installées restent importantes.

### Installation utilisateur du serveur Compose

Le serveur Compose a été installé sans privilèges système dans `stdpath('data')/tools`, habituellement `~/.local/share/nvim/tools`. Le LSP privilégie son chemin explicite s’il existe ; sinon il utilise la commande du `PATH`. Aucun profil du shell n’est modifié.

Pour reproduire l’installation, depuis n’importe quel dossier, avec Node.js 22 ou supérieur et npm :

```bash
npm install --global --prefix "$HOME/.local/share/nvim/tools" --ignore-scripts --no-audit --no-fund @microsoft/compose-language-service@1.0.0
```

Les fichiers `compose.yaml`, `compose.yml`, `docker-compose.yaml`, `docker-compose.yml` et leurs variantes `compose.*.yaml` / `docker-compose.*.yml` sont reconnus comme `yaml.docker-compose`.

## Formatage

- Sauvegarde : formatage synchrone avec un délai maximal demandé de **2 000 ms**.
- `Espace cf`, en mode normal ou visuel : formatage manuel asynchrone du fichier ou des lignes touchées par la sélection.
- `Espace uf` : activer/désactiver le formatage à la sauvegarde pour le buffer courant ; le choix n’est pas conservé après fermeture de Neovim.
- `Espace lf`, avec un LSP attaché : privilégier un LSP capable de formater ; utiliser Conform en secours si aucun n’est disponible.
- En l’absence de formateur externe disponible, Conform peut utiliser un seul serveur LSP selon la préférence du langage, puis son nom et son identifiant.
- Python exécute `isort` puis `black`. JSONC et YAML Compose utilisent Prettier.
- Au-delà de **1 Mio**, le formatage à la sauvegarde est ignoré ; le formatage manuel reste possible.

Le repli LSP n’est pas une relance automatique après tout échec de formateur. Les journaux et outils choisis sont accessibles avec `:ConformInfo`.

## Raccourcis principaux

Le leader est **Espace**. Les anciens `Espace f` et `gr` ont été retirés pour éviter les collisions de préfixe.

| Touche | Action |
| --- | --- |
| `Espace w`, `Ctrl-s` en mode normal | Sauvegarder |
| `Espace q` | Quitter la fenêtre courante |
| `Espace Q` | Quitter tout **sans sauvegarder** |
| `-` | Ouvrir le dossier parent dans Oil |
| `Espace ff`, `fg`, `fb`, `fh` | Fichiers, texte, buffers, aide |
| `Espace cf` | Formater le fichier ou les lignes sélectionnées |
| `Espace uf` | Basculer le formatage automatique du buffer |
| `Échap` en mode normal | Effacer le surlignage de recherche |
| `[d`, `]d` | Diagnostic précédent/suivant et fenêtre explicative |
| `Espace e`, `Espace dl` | Diagnostic flottant, liste locale des diagnostics |
| `Ctrl-h/j/k/l` | Fenêtre gauche/bas/haut/droite |
| `Espace sv`, `sh` | Division verticale/horizontale |
| `Espace sx`, `Espace x` | Fermer la fenêtre ; alias conservés |
| `Maj-h`, `Maj-l`, `Espace bd` | Buffer précédent/suivant, fermer le buffer |
| `Alt-j/k` | Déplacer la ligne ou la sélection |
| `Espace tt` | Terminal dans une division en bas |
| `Échap` en mode terminal | Revenir au mode normal du terminal |
| `gd`, `gD`, `gi`, `K` avec LSP | Définition, déclaration, implémentation, documentation |
| `grr`, `grn`, `gra`, `gri`, `grt` natifs | Références, renommage, actions, implémentations, définition du type |
| `Espace rn`, `F2` avec LSP | Renommer |
| `Espace ca`, `F4` avec LSP | Action de code |
| `[c`, `]c` avec Git | Modification précédente/suivante ; navigation native préservée en mode diff |
| `Espace hp`, `Espace hb` avec Git | Aperçu d’une modification, auteur de la ligne |

### Oil

`Ctrl-s` conserve la sauvegarde ; `Ctrl-h/l` conservent la navigation entre fenêtres. Pour ouvrir un fichier dans une division : `Ctrl-v` verticalement, `Ctrl-x` horizontalement. `gR` rafraîchit. `g?` affiche l’aide locale. Les autres raccourcis par défaut sont conservés.

### Complétion

`Tab` sélectionne la proposition suivante, ou développe/avance dans un snippet local ; `Maj-Tab` recule. `Ctrl-Espace` ouvre le menu et `Ctrl-e` annule. `Entrée` confirme un élément sélectionné ; aucune présélection automatique n’est demandée. La source de mots du buffer est exclue au-delà de 1 Mio, mais les autres sources restent disponibles.

### Recherche

La recherche inclut les fichiers cachés et respecte les exclusions Git par défaut. Les dossiers `.git`, `.next`, `node_modules`, `dist`, `build` et `target` sont exclus comme noms de dossiers, y compris sous un dossier parent. Un fichier caché ignoré par Git ne sera donc pas nécessairement proposé.

## Treesitter et mises à jour

La version installée utilise l’API moderne : coloration par `vim.treesitter.start`, sans ancien module `nvim-treesitter.configs`. Les parseurs ne sont jamais téléchargés automatiquement à chaque ouverture. JSONC utilise le parseur JSON.

Les 23 langages explicitement demandés lors de cette intervention (et leurs trois dépendances de requêtes) couvrent les langages configurés. Pour reproduire l’installation dans Neovim :

```vim
:TSInstall lua luadoc vim vimdoc query python javascript typescript tsx html css json yaml bash rust c cpp dockerfile markdown markdown_inline php php_only dart
```

Les buffers de plus de 1 Mio n’activent pas la coloration Treesitter via cette configuration ; la coloration déjà activée par un ftplugin natif est arrêtée lors de l’événement `FileType`. Ce seuil n’est pas un mode global « gros fichier » : il ne désactive pas les serveurs LSP, et un buffer qui grandit après ouverture n’est pas surveillé en continu.

Avant une future mise à jour, sauvegarder la configuration et le verrou. Dans Neovim :

```vim
:lua vim.pack.update()
```

Si nvim-treesitter est mis à jour, mettre ensuite à jour ses parseurs :

```vim
:TSUpdate
```

Les mises à jour des serveurs et formateurs restent gérées par leurs outils d’installation respectifs. `nvim-pack-lock.json` verrouille les plugins, pas les exécutables externes ni les parseurs compilés.

## Vérification manuelle

Depuis un projet représentatif, ouvrir un fichier avec `nvim`, puis :

```vim
:checkhealth vim.lsp
:checkhealth vim.provider
:checkhealth telescope
:ConformInfo
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
:verbose nmap <Space>cf
:verbose nmap grr
```

Le rapport HTML de l’intervention et la sauvegarde d’origine sont dans `/home/kilam/neovim`. Les contrôles automatisés utilisent des fichiers temporaires ; aucun fichier applicatif n’est formaté par ces contrôles.
