# Photographic Volume

Expérience web immersive qui transforme des photographies en sculptures de particules 3D navigables, accompagnées d'un environnement sonore génératif qui réagit en temps réel à l'exploration.

![Three.js](https://img.shields.io/badge/Three.js-r128-black?logo=three.js)
![Vanilla JS](https://img.shields.io/badge/JavaScript-Vanilla-f7df1e?logo=javascript&logoColor=000)
![WebGL](https://img.shields.io/badge/WebGL-Enabled-red?logo=webgl)
![Web Audio API](https://img.shields.io/badge/Web_Audio-API-blue)

---

## Présentation

**Photographic Volume** est une application web monopage qui décompose des photographies en nuages de particules 3D interactifs. Chaque pixel échantillonné de l'image source devient un point coloré positionné dans un espace tridimensionnel. L'utilisateur navigue dans cet espace par le scroll — un cycle de zoom bidirectionnel infini qui fait pénétrer à l'intérieur de l'image puis en ressortir, déclenchant une transition vers la photographie suivante à chaque inversion.

Le parcours est structuré en **7 états de lecture** qui modifient progressivement les propriétés visuelles des particules (taille, profondeur, mouvement, dispersion) au fil du zoom, créant une progression dramaturgique du plat vers le volumétrique, de l'immobile vers l'animé.

Un **moteur audio génératif** à 5 thèmes sonores organiques — inspiré de Tim Hecker, Nils Frahm, Ryuichi Sakamoto et Biosphere — enveloppe l'expérience d'une nappe sonore qui évolue en fonction du niveau de zoom, de la vitesse de scroll et de la profondeur des particules.

Le curseur est masqué en permanence pour une immersion totale. Une page d'information sur le projet est accessible via **Alt**, **Esc** ou **clic droit**.

### Démo

> Ouvrir `index.html` via un serveur HTTP local dans un navigateur moderne avec support WebGL.

---

## Fonctionnalités

### Rendu visuel

- **Nuage de particules 3D** — Chaque pixel échantillonné devient un point dans l'espace (jusqu'à ~2.4M de particules sur desktop, résolution adaptée sur mobile)
- **Disparity dynamique** — Profondeur Z appliquée en temps réel via un attribut `normalizedDepth` par particule, avec lerp configurable. Pas de reconstruction de géométrie : update GPU direct par batch optimisé (loop unrolling ×4)
- **5 modes de mouvement** — Oscillation Z, plan XY, 3D complet, vague sinusoïdale, spirale. Chaque mode anime les positions via une fonction dispatch (pas de branches dans la boucle chaude)
- **Saturation chromatique** — Contrôle d'intensité des couleurs par interpolation vers la moyenne RGB
- **Filtrage des noirs** — Seuil configurable pour masquer les pixels sombres (séparation sujet/fond)
- **Randomisation déterministe** — Dispersion de la grille de particules avec hash seedé (`seededRandom`) pour des positions reproductibles entre rechargements
- **Formes** — Particules circulaires (gradient radial) ou carrées, avec textures cachées en Canvas 64×64

### Cycle de zoom

- **Bidirectionnel infini** — Zoom avant (0 → 0.826) puis zoom arrière (0.826 → 0.418), avec transition d'image au point d'inversion, zone morte au retour à l'état initial, puis reprise du cycle
- **Transitions fluides** — Interpolation linéaire des couleurs pixel par pixel entre l'ancienne et la nouvelle image, synchronisée sur la position de zoom (pas sur le temps)
- **Détection trackpad / molette** — Heuristique basée sur deltaY et fréquence des événements. Le trackpad utilise une sensibilité directe, la molette utilise un accumulateur virtuel avec lerp progressif (technique Lenis/smooth-scroll) pour lisser les clics discrets
- **Touch support** — Momentum avec inertie, friction configurable, vélocité trackée sur les 3 derniers points touch

### Audio génératif

- **5 thèmes sonores** — Résonance 01 (D2/A2, filtres Q=35), Micro-Friction 02 (+ couche krill haute fréquence), Résonance 03 Médium (A2/E3), Résonance 04 Cristallin (E3/B3, Q=45), Résonance 05 Spectral (B3/F#4, triangle, Q=50)
- **6 couches par thème** :
  - **Drone** — 2 fondamentales × 3 oscillateurs désaccordés (±detune), volume en arc sinusoïdal
  - **Résonances** — 4 filtres passe-bande à Q élevé sur bruit brownien, fréquences modulées lentement
  - **Sub-bass** — Oscillateur grave avec panning LFO, fréquence liée à la profondeur (disparity)
  - **Texture granulaire** — Bruit rose filtré, bande centrée qui monte avec le zoom
  - **Breath / mouvement** — Bruit modulé par LFO, intensité liée à la vélocité de mouvement
  - **Scroll whoosh** — Bruit blanc filtré en bande large, directionnel (pitch monte en avant, descend en arrière), style Sonar
- **Couche Krill** (thème 02) — 5 filtres bande étroite sur bruit blanc (3200–7900 Hz, Q=30), émerge au-delà de 40% du zoom, simule des micro-frictions
- **Chaîne master** — Filtre passe-bas 2 stages (-24dB/oct) → saturation chaude (waveshaper asymétrique, harmoniques paires) → compresseur (ratio 3.5, knee 16) → reverb convolution (IR synthétique brownienne) → master gain
- **Mapping zoom→fréquence** — Toutes les fréquences fondamentales sont multipliées par un `freqRangeMultiplier` qui va de ×1 (zoom min, grave) à ×1.5–2.5 (zoom max, aigu) selon le thème
- **Fondu automatique** — Le volume se coupe progressivement en fondu (0.8s) quand l'utilisateur quitte l'onglet, et revient en fondu (1.2s) quand il y retourne

### États de lecture (UX Journey)

- **7 états prédéfinis** — Chaque état définit taille, densité, disparity, mouvement, randomness, saturation, hideBlack, forme et mode de mouvement
- **Interpolation continue** — Les paramètres sont interpolés entre états adjacents en fonction de la position de zoom, avec 4 courbes d'easing au choix (linéaire, easeIn, easeOut, easeInOut)
- **Progression dramaturgique** — De l'image plate et immobile (état 1 : disparity 0, mouvement 0) vers une sculpture volumétrique animée (état 7 : disparity 2.77, mouvement 0.5)

### Interface

- **Curseur masqué** — `cursor: none` global pour une immersion totale
- **Page info** — Overlay accessible via Alt, Esc ou clic droit, présentant le projet. Curseur visible uniquement dans cet overlay
- **Panneau I** — Paramètres des particules (7 sliders + forme + mode de mouvement)
- **Panneau M** — États de lecture : visualisation, navigation (flèches haut/bas), ajout/suppression d'états, sélection de courbe d'interpolation, toggle du mode parcours
- **Panneau C** — Configuration scroll : sensibilité trackpad, seuil de détection, fréquence, multiplicateur molette, lerp molette, lerp zoom global, lerp disparity. Reset et export JSON
- **Panneau Z** — Debug temps réel : zoomLevel, targetZoomLevel, camera.position.z, scrollPhase, isTransitioning
- **Touche S** — Cycle entre les 5 thèmes sonores (ou OFF)
- **Indicateur de scroll** — SVG animé (souris desktop / geste swipe mobile) qui apparaît après le chargement, pulse après 5s d'inactivité, disparaît au premier scroll ou après 20s

### Optimisations

- **Early exit** — Le renderer ne dessine que si un changement visuel est détecté (`needsRender` flag)
- **Batch GPU** — Toutes les mises à jour de position sont accumulées et envoyées en un seul `needsUpdate = true`
- **Loop unrolling ×4** — La boucle de disparity traite 4 particules par itération (pattern SIMD-like)
- **Cache d'images** — `ImageData` et couleurs pré-extraites au chargement pour éviter les freezes pendant les transitions
- **Cache de textures** — Les textures circle/square sont créées une seule fois
- **Canvas réutilisable** — Un seul canvas offscreen pour toutes les opérations d'extraction de pixels
- **Throttle des reloads** — `requestAnimationFrame` pour éviter les reconstructions multiples par frame
- **DOM caché** — Les éléments UI (debug, sliders) ne sont mis à jour que si leur panneau est visible

---

## Installation

Aucun build, aucune dépendance à installer. Application client-side pure.

```bash
git clone https://github.com/Holosene/photographic-volume.git
cd photographic-volume
```

Servir avec n'importe quel serveur HTTP statique :

```bash
# Python
python3 -m http.server 8000

# Node.js (npx)
npx serve .

# PHP
php -S localhost:8000
```

Puis ouvrir `http://localhost:8000` dans le navigateur.

> **Note :** Ouvrir directement `index.html` en `file://` peut bloquer le chargement des images (politique CORS). Utiliser un serveur HTTP local.

---

## Contrôles

### Navigation

| Entrée | Action |
|--------|--------|
| **Scroll / Trackpad** | Cycle de zoom bidirectionnel (avant ↔ arrière) |
| **← / →** | Image précédente / suivante |
| **↑ / ↓** | Naviguer entre les états (panneau M ouvert) |
| **S** | Cycler entre les 5 thèmes sonores (ou OFF) |

### Panneaux

| Touche | Panneau |
|--------|---------|
| **I** | Paramètres des particules |
| **M** | États de lecture (UX Journey) |
| **C** | Configuration scroll |
| **Z** | Debug zoom / caméra |

### Info

| Entrée | Action |
|--------|--------|
| **Alt** | Ouvrir la page info du projet |
| **Esc** | Ouvrir / fermer la page info |
| **Clic droit** | Ouvrir la page info (remplace le menu contextuel) |

---

## Paramètres des particules

| Paramètre | Plage | Description |
|-----------|-------|-------------|
| `size` | 0 – 0.04 | Taille des particules en unités monde |
| `density` | 0 – 2 | Taux d'échantillonnage (1 = tous les pixels, 0.4 = 1 pixel sur ~2.5) |
| `disparity` | 0 – 16 | Écartement en profondeur (axe Z), appliqué dynamiquement sans reconstruction |
| `movement` | 0 – 0.5 | Amplitude d'oscillation des particules |
| `saturation` | 0 – 4 | Intensité des couleurs (1 = fidèle, >1 = saturé) |
| `hideBlack` | 0 – 1 | Seuil de luminosité sous lequel les pixels sont supprimés |
| `randomness` | 0 – 2 | Dispersion aléatoire de la grille (déterministe, seedée) |
| `shape` | circle / square | Forme des particules (texture Canvas 64×64) |
| `movementMode` | 1 – 5 | 1: Oscillation Z, 2: Plan XY, 3: 3D, 4: Vague, 5: Spirale |

---

## Thèmes sonores

| # | Nom | Fondamentales | Caractère |
|---|-----|---------------|-----------|
| 1 | Résonance 01 | D2, A2 | Chaud, filtres Q=35, reverb longue |
| 2 | Micro-Friction 02 | D2, A2 | Base similaire + couche krill 3.2–7.9 kHz |
| 3 | Résonance 03 — Médium | A2, E3 | Registre médium élargi, Q=40 |
| 4 | Résonance 04 — Cristallin | E3, B3 | Aigu, scintillant, Q=45 |
| 5 | Résonance 05 — Spectral | B3, F#4 | Ultra-aigu, triangle, Q=50, sub contrastant |

---

## Architecture

```
photographic-volume/
├── index.html              # Application complète (HTML + CSS + JS, ~3500 lignes)
├── Ressources/
│   ├── IMG_001.jpg          # Photographie 1
│   ├── IMG_002.jpg          # Photographie 2
│   ├── IMG_003.jpg          # Photographie 3
│   ├── logo.svg             # Logo Holosene (loading + info)
│   └── favicon.svg          # Favicon SVG
└── docs/
    ├── OPTIMISATION_ANALYSE.md       # Analyse d'optimisation phase 1
    └── OPTIMISATION_PHASE2_ANALYSE.md # Analyse d'optimisation phase 2
```

L'application est entièrement contenue dans un seul fichier HTML. Pas de bundler, pas de framework — Three.js est chargé depuis CDN.

### Pipeline de rendu

```
Images JPEG
  → THREE.TextureLoader
    → Canvas 2D (redimensionnement 1720×880 desktop / 640×960 mobile portrait)
      → ImageData (extraction pixels)
        → BufferGeometry (position + color + normalizedDepth + initialPosition)
          → THREE.Points (PointsMaterial, vertexColors, sizeAttenuation)
            → WebGL Render (conditionnel, early exit si aucun changement)
```

### Chaîne audio

```
Oscillateurs / Bruit (brownien, rose, blanc)
  → Filtres passe-bande (résonances, krill)
  → Bus commun
    → Muffle (passe-bas 2 stages, -24dB/oct)
      → Warmth (waveshaper saturation chaude)
        → Compresseur dynamique
          → Convolver (reverb IR synthétique)
            → Master Gain
              → AudioContext.destination
```

### Cycle de zoom

```
zoomIn (0 → 0.826)  ──→  transition image  ──→  zoomOut (0.826 → 0.418)
                                                         │
       dead zone (0.1)  ←─────────────────────────────────┘
              │
              └──→  zoomIn (reprise du cycle)
```

---

## Écran de chargement

Au lancement, un écran noir affiche le logo Holosene avec une animation de lueur pulsante (opacité 0.35 → 1, drop-shadow rouge variable). Toutes les images sont pré-chargées en arrière-plan. L'écran de chargement reste visible au minimum 2.2 secondes. Après le chargement, le logo disparaît en fondu (0.8s), suivi d'un **écran noir de 1.2 secondes** de silence visuel, avant l'apparition de la première image en particules.

---

## Ajouter des images

1. Placer les fichiers JPEG dans `Ressources/` en respectant la convention de nommage : `IMG_001.jpg`, `IMG_002.jpg`, etc.
2. Modifier `maxImageIndex` dans `index.html` pour correspondre au nombre total d'images.
3. Incrémenter `IMAGE_VERSION` si les images sont mises en cache par le navigateur.

Les images sont automatiquement redimensionnées et recadrées (cover sur desktop, contain sur mobile portrait).

---

## Compatibilité

- Navigateur moderne avec **WebGL** (Chrome, Firefox, Safari, Edge)
- **Web Audio API** pour l'audio génératif
- Desktop recommandé (trackpad ou molette)
- Support mobile (touch, momentum, résolution adaptée, FOV ajusté)
- Ratio pixel plafonné à 2× pour les performances
- ~500 Mo – 1 Go de RAM selon la densité de particules

---

## Technologies

| Technologie | Usage |
|-------------|-------|
| [Three.js](https://threejs.org/) r128 | Rendu WebGL, scène 3D, système de particules |
| Web Audio API | Moteur audio génératif, synthèse, filtrage, reverb convolution |
| JavaScript vanilla | Logique applicative, contrôles, gestion d'état |
| Canvas 2D | Traitement d'images, extraction de pixels, textures de particules |
| CSS | Interface utilisateur, panneaux de contrôle, animations |

---

## Licence

Tous droits réservés. © Holosene
