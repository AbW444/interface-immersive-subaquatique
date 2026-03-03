# PROJECT SCOPE — Audit complet verifie

**Branche:** `claude/define-project-scope-KCpuT`
**Fichier:** `index.html` — 3831 lignes, ~141 Ko, fichier monolithique
**Date:** 3 mars 2026
**Comparaison:** `main` (1299 lignes) → cette branche (3831 lignes)

---

## 1. Architecture et structure du code

### Ce qui a change depuis main

Le fichier a triple en taille. L'architecture reste un monolithe `index.html` avec tout inline (CSS, HTML, JS), mais le contenu a radicalement evolue :

- **Avant (main):** 8 images, overlay d'intro "AURORA UNREALIS", etoiles/neige/lune, UI basique avec boutons, chemins d'images casses
- **Maintenant:** 3 images (IMG_001 a IMG_003), overlay info minimaliste "PHOTOGRAPHIC VOLUME", moteur audio generatif complet (~766 lignes), 4 panneaux de debug/config, systeme d'etats UX a 7 niveaux, cycle de zoom bidirectionnel, gestion touch avec momentum

### Structure actuelle

Le fichier s'organise en blocs clairs, bien commentes avec des separateurs visuels :

```
Lignes 1-12       : Head, meta, OG tags, favicon SVG
Lignes 13-828     : CSS (~815 lignes) — 5 blocs bien identifies
Lignes 829-1181   : HTML body — Google Fonts link, overlay info, loading screen,
                    scroll indicator, audio indicator, 4 panneaux UI
Lignes 1182-3831  : JavaScript (~2650 lignes) — detection mobile, Three.js r128,
                    audio engine IIFE, scroll, events, UI
```

### Monolithe : impact concret

3831 lignes dans un seul fichier. Le CSS fait 815 lignes. L'AudioEngine fait 766 lignes (1924-2689). Le systeme de scroll fait ~200 lignes. Chaque modification risque des effets de bord — tout partage le meme scope global avec 40+ variables globales (`zoomLevel`, `targetZoomLevel`, `isTransitioning`, `wheelScrollAccumulator`, `touchLastY`, etc.).

### Qualite du code JS

Deux "couches" stylistiques visibles :

1. **Couche prototype :** variables globales, logique procedurale, nommage mixte francais/anglais (`uxStates` avec `name: "Etat 1"`)
2. **Couche optimisee :** l'AudioEngine est un module IIFE propre avec encapsulation (lignes 1924-2689), `destroyLayers()` nettoie proprement, `movementFunctions` utilise un dispatch table (ligne 1853), loop unrolling x4 pour la disparity

L'AudioEngine est le code le mieux architecture du fichier — module autonome, API claire (`init`, `cycle`, `update`), nettoyage correct des noeuds Web Audio.

---

## 2. Bugs et problemes techniques

### BUG CRITIQUE — chemins d'images : RESOLU

Le bug fatal de main (`./Projet_test_HLS_LMPI/Ressources/`) est corrige. Les images chargent depuis `./Ressources/IMG_001.jpg` etc. (ligne 1394). Ce fix justifie cette branche.

### BUG MODERE — scrollConfig incoherence valeurs par defaut vs HTML

Verifie aux lignes exactes :

| Parametre | JS init (l.3122) | HTML slider (l.888) | JS reset (l.3209) |
|-----------|------------------|---------------------|--------------------|
| sensitivity | **0.000450** | **0.000334** | **0.000334** |
| zoomLerp | **0.18** (l.3133) | **0.22** (l.926) | non verifie |

L'utilisateur voit une valeur dans le slider, le code en utilise une autre au demarrage. Le reset ne revient pas a la valeur d'init mais a celle du slider.

### BUG MODERE — currentImageIndex initialisation

```javascript
let currentImageIndex = 3;  // Ligne 1223 — Commence a IMG_003
const maxImageIndex = 3;    // Ligne 1224 — 3 images
```

`availableImages` est peuple par `preloadAllImages()` qui est asynchrone. Si `loadImage(currentImageIndex)` est appele avant que le cache soit pret, double-chargement via le fallback.

### BUG MODERE — isPortrait calcule une seule fois

```javascript
const isPortrait = window.innerHeight > window.innerWidth; // Ligne 1189
```

Calcule au chargement, jamais mis a jour. Le resize handler (lignes 3083-3093) ajuste le FOV avec `window.innerHeight > window.innerWidth` inline mais ne met PAS a jour la variable `isPortrait`. Si l'utilisateur tourne son telephone, la resolution des particules garde les mauvaises valeurs.

### BUG MODERE — window.lastTransitionProgress pollution globale

```javascript
window.lastTransitionProgress = transitionProgress; // Ligne 2792
```

Variable stockee sur `window` (aussi lignes 2785, 2815, 3072). Anti-pattern — risque de collision. Utilisee par l'AudioEngine update.

### BUG MINEUR — disparity recharge inutilement

Ligne 3719-3722 dans `updateParam()` :
```javascript
} else if (param === 'disparity') {
    particleParams.disparity = value;
    valueDisplay.textContent = value.toFixed(1);
    loadImage(currentImageIndex);  // INUTILE — disparity applique dynamiquement dans animate()
}
```

L'optimisation est faite dans `animate()` pour appliquer la disparity dynamiquement, mais le handler UI appelle encore `loadImage()`.

### BUG MINEUR — double declaration scrollConfigPanel

- Ligne 3139 : `const scrollConfigPanel = document.getElementById('scroll-config-panel');`
- Ligne 3460 : meme declaration dans le scope du keydown handler

Pas un crash (scopes differents) mais code redondant.

### BUG MINEUR — touchstart passive:false sans necessite

Ligne 3300-3307 : `touchstart` utilise `{ passive: false }` mais n'appelle jamais `preventDefault()`. Seul `touchmove` (ligne 3310) en a besoin.

---

## 3. UX et design

### Typographie

Police principale : **Roboto 400/700** via Google Fonts (ligne 829). Fallbacks : Arial, sans-serif. Police monospace : **Courier New** pour les panneaux debug (lignes 719, 752).

C'est un recul par rapport a `main` qui avait `new-astro` (Typekit) — une police distinctive. Pour un projet de recherche ENSAD sur le volume photographique, Roboto est trop generique.

### Palette de couleurs

Deux couleurs dominent :
- `#000000` — fond absolu
- `#55ffff` — cyan neon pour **toute** l'UI

**15 occurrences** de `#55ffff` dans le CSS/HTML : bordures, labels, sliders, boutons actifs, debug panel, scroll config. Aucune hierarchie visuelle — un panneau de debug et un bouton d'etat partagent la meme couleur d'accent.

Le violet de `main` a completement disparu.

### Layout et panneaux

4 panneaux superposes, actives par touches clavier :

| Touche | Panneau | Position | z-index |
|--------|---------|----------|---------|
| I | Settings (particules) | top right, 290px | 1000 |
| M | Etats de lecture | left center, 400px | 2000 |
| C | Scroll config | bottom center, 700px min | 1000 |
| Z | Debug zoom/camera | top center, 400px | 10000 |

Plus : info overlay (Alt/Esc/clic droit) a z-index 20000, loading screen a 9999.

**Problemes :**
1. Aucune indication visuelle que ces panneaux existent. L'overlay info ne mentionne que "Naviguez en scrollant"
2. Le scroll config (`min-width: 700px`) est inutilisable en portrait mobile
3. Les 4 panneaux peuvent etre ouverts simultanement et se superposent

### Interactions

**Ce qui marche bien :** Le scroll indicator adaptatif (mouse icon desktop / rectangle mobile) avec timings precis :
- Apparition : 1200ms apres chargement (ligne 1775)
- Pulse : apres 5000ms si pas de scroll (ligne 1778)
- Disparition : apres 20000ms ou premier scroll (ligne 1782)

**Problemes :**
- `cursor: none` sur `*` (ligne 14) — curseur masque en permanence, desorientant avec les sliders des panneaux
- Audio auto-start au premier geste (lignes 3395-3404 : wheel/touchstart/click declenchent `cycleAudioTheme()`) sans indication visuelle prealable
- Sur mobile, l'indicateur audio ET le bouton sont `display: none !important` (lignes 824-825) — l'audio demarre sans moyen de le couper

### Contenu textuel visible

1. "PHOTOGRAPHIC VOLUME" — titre overlay
2. "Une exploration immersive de la photographie en volume." — description
3. "Naviguez a travers les couches de l'image en scrollant..." — instruction
4. "Holosene — 2025" — credit
5. "Appuyez sur Esc ou cliquez pour revenir" — hint
6. Scroll indicator (SVG sans texte)
7. Audio indicator ("OFF" / "1/5 Resonance 01" etc.)

Aucun texte pendant l'experience principale. L'overlay info ne s'ouvre que via Alt (intercepte par le browser), Esc, ou clic droit (intercepte le menu contextuel natif).

---

## 4. Performance

### Render loop (animate())

**Bonne architecture :** systeme early-exit (lignes 2720-2726). `needsRender` n'est active que si zoom, transition, mouvement ou disparity sont actifs. Quand l'utilisateur ne scroll pas et que le mouvement est a 0, le GPU est au repos.

### Point chaud : mouvement des particules

Lignes 3032-3034 : quand `movement > 0`, chaque frame itere sur TOUS les vertices :
```javascript
for (let i = 0; i < positions.length; i += 3) {
    movementFunc(positions, initialPositions, i, time, movementDouble);
}
```

Estimation particules :
- Desktop (1720x1024, density 0.6) : ~1.5M particules → 4.5M floats
- Mobile (640x960) : ~600K particules

Le dispatch table (ligne 1853) elimine les branches. Mais chaque `movementFunc` fait 2-3 `Math.sin()/Math.cos()` — CPU lourd. Ce traitement devrait etre dans un **vertex shader** pour eliminer le transfert CPU→GPU de ~18 Mo/frame.

### Memoire

**Bon :** `dispose()` appele sur geometry/material avant chaque nouvelle creation (lignes 1608-1612). Caches (`imageCache`, `colorCache`, `textureCache`) evitent les rechargements.

**Probleme :** `oldColors` et `newColors` (lignes 1739, 1743) sont des copies completes. Pour 1.5M particules x 3 composantes x 4 bytes = ~18 Mo par tableau, ~36 Mo pendant une transition.

### GPU

- `devicePixelRatio` cappe a 2 (ligne 1209)
- Antialias desactive sur mobile
- `powerPreference: "high-performance"`
- **Pas de post-processing** (pas de bloom, pas de tone mapping, pas d'EffectComposer)

---

## 5. Ce qui marche bien vs ce qui pose probleme

### Ce qui marche bien

- **Cycle de zoom bidirectionnel** : zoom in → inversion → transition couleurs → zoom out → dead zone → reprise. Transition basee sur la position de zoom (pas le temps) = controle direct
- **Systeme d'etats UX** : 7 etats interpoles le long du zoom. Progression "plat → volumetrique → anime" = dramaturgie reelle
- **Moteur audio generatif** : 766 lignes IIFE, 5 themes avec 6+ couches (drone, resonances, sub-bass, grain, breath, scroll whoosh), mapping zoom→frequence perceptivement coherent
- **Detection trackpad vs molette** avec accumulateur virtuel et lerp
- **Adaptation mobile** serieuse : resolution reduite, FOV ajuste, contain vs cover, touch momentum avec inertie

### Ce qui pose probleme

- **Profondeur Z aleatoire** (ligne 1581) : `seededRandom(x, y, 3) - 0.5` — la disparity n'a aucun rapport avec le contenu de l'image. Un pixel de ciel et un pixel de corail ont la meme probabilite d'etre devant ou derriere. La promesse du projet n'est pas tenue par le code
- **Pas de transition structurelle entre images** : l'interpolation est uniquement sur les couleurs, pas les positions. C'est un fondu enchaine, pas une transformation volumetrique
- **4 panneaux debug/config invisibles** : aucune affordance, ~600 lignes de code pour du tooling inaccessible
- **Overlay info quasi inaccessible** : Alt (intercepte par browsers), Esc (logique inversee), clic droit (hostile)
- **Roboto** : police la plus generique du web pour un projet de recherche ENSAD

---

## 6. Recommandations par priorite

### P0 — Critique (impacte la proposition de valeur)

**1. Depth-based Z au lieu d'aleatoire**

Remplacer `seededRandom(x, y, 3)` par un calcul base sur la luminance du pixel (ligne 1581) :
```javascript
const lum = 0.299 * r + 0.587 * g + 0.114 * b;
const normalizedDepth = (lum - 0.5) + (seededRandom(x, y, 3) - 0.5) * 0.15;
```
Pixels clairs avancent, pixels sombres reculent → vrai volume photographique. Fix de 2 lignes, impact maximal.

**2. Separer le fichier**

Au minimum : `index.html` (structure), `style.css`, `main.js`, `audio-engine.js`. Copier-couper sans refonte.

### P1 — Important (qualite de l'experience)

**3. Remplacer Roboto** par une police distinctive (Space Grotesk, Syne, ou similaire).

**4. Rendre l'overlay info accessible** — petit "i" ou "?" fixe visible, lister les controles clavier, retirer le hijack du clic droit.

**5. Fix bug isPortrait statique** — recalculer dans le resize handler, rebuild particules si orientation change.

**6. Harmoniser scrollConfig** — aligner JS defaults, HTML slider values, et reset values.

**7. Deplacer mouvement particules dans un vertex shader** — uniform `uTime` dans un `ShaderMaterial`, eliminer transfert CPU→GPU.

### P2 — Nice to have

**8. Bloom post-processing** — `UnrealBloomPass` (Three.js r128), strength 0.3, radius 0.5, threshold 0.85.

**9. Nettoyer le debug en production** — conditionner les 4 panneaux derriere `const DEBUG = location.search.includes('debug')`.

**10. Transition geometrique entre images** — dispersion/recomposition des positions en plus du color crossfade.

**11. Audio mobile** — retirer `display: none !important` sur `#mobile-audio-btn` pour permettre le controle audio.

---

## Ressources du projet

```
photographic-volume/
├── index.html              (3831 lignes — monolithe)
├── README.md
├── Ressources/
│   ├── IMG_001.jpg
│   ├── IMG_002.jpg
│   ├── IMG_003.jpg
│   ├── favicon.svg
│   └── logo.svg
└── docs/
    ├── OPTIMISATION_ANALYSE.md
    ├── OPTIMISATION_PHASE2_ANALYSE.md
    └── PROJECT_SCOPE.md     (ce fichier)
```
