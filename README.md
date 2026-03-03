# Photographic Volume

Espace immersif de photographies rendues en particules 3D dans le navigateur.

![Three.js](https://img.shields.io/badge/Three.js-r128-black?logo=three.js)
![Vanilla JS](https://img.shields.io/badge/JavaScript-Vanilla-f7df1e?logo=javascript&logoColor=000)
![WebGL](https://img.shields.io/badge/WebGL-Enabled-red?logo=webgl)

---

## Présentation

**Photographic Volume** transforme des photographies en nuages de particules 3D interactifs. Chaque pixel de l'image devient un point dans l'espace, créé à partir de sa couleur et de sa position. L'utilisateur navigue entre les images via un cycle de zoom bidirectionnel contrôlé au scroll, tandis que 7 états de lecture prédéfinis modifient progressivement la densité, la profondeur, le mouvement et la saturation des particules.

### Démo

> Ouvrir `index.html` dans un navigateur moderne avec support WebGL.

---

## Fonctionnalités

- **Rendu en particules** — Chaque pixel échantillonné devient un point 3D coloré (jusqu'à ~2.4M de particules)
- **Cycle de zoom bidirectionnel** — Zoom avant → zoom arrière → zoom avant, avec transitions d'images au point de retournement
- **7 états de lecture** — Interpolation fluide des paramètres visuels en fonction de la position de zoom
- **5 modes de mouvement** — Oscillation Z, plan XY, 3D, vague, spirale
- **Détection trackpad / molette** — Stratégie d'easing adaptée automatiquement au périphérique d'entrée
- **Transitions d'images** — Interpolation de couleurs entre les images, sans gel ni freeze
- **Contrôles temps réel** — Panneaux UI pour ajuster tous les paramètres à la volée
- **Randomisation déterministe** — Positions reproductibles entre les rechargements (hash seedé)

---

## Installation

Aucun build, aucune dépendance à installer. C'est une application client-side pure.

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
| **Scroll / Trackpad** | Cycle de zoom (avant ↔ arrière) |
| **← / →** | Image précédente / suivante |
| **↑ / ↓** | Naviguer entre les états (panneau M ouvert) |

### Panneaux UI

| Touche | Panneau |
|--------|---------|
| **I** | Paramètres des particules (taille, densité, profondeur, mouvement, saturation, seuil noir, randomisation) |
| **M** | États de lecture (7 presets visuels interpolés) |
| **C** | Configuration scroll (sensibilité trackpad, multiplicateur molette, lerp) |
| **Z** | Debug (niveau de zoom, position caméra, phase de scroll, état de transition) |

---

## Paramètres des particules

| Paramètre | Plage | Description |
|-----------|-------|-------------|
| `size` | 0 – 0.04 | Taille des particules en unités monde |
| `density` | 0 – 2 | Taux d'échantillonnage (1 = tous les pixels) |
| `disparity` | 0 – 16 | Écartement en profondeur (axe Z) |
| `movement` | 0 – 0.5 | Amplitude d'oscillation |
| `saturation` | 0 – 4 | Intensité des couleurs |
| `hideBlack` | 0 – 1 | Seuil de suppression des pixels sombres |
| `randomness` | 0 – 2 | Décalage aléatoire de la grille |
| `shape` | circle / square | Forme des particules |
| `movementMode` | 1 – 5 | Mode d'animation (Z, XY, XYZ, vague, spirale) |

---

## Architecture

```
photographic-volume/
├── index.html              # Application complète (HTML + CSS + JS)
├── Ressources/
│   ├── IMG_001.jpg          # Photo 1
│   ├── IMG_002.jpg          # Photo 2
│   └── IMG_003.jpg          # Photo 3
└── docs/
    ├── OPTIMISATION_ANALYSE.md       # Analyse phase 1
    └── OPTIMISATION_PHASE2_ANALYSE.md # Analyse phase 2
```

L'application est entièrement contenue dans un seul fichier HTML. Pas de bundler, pas de framework — Three.js est chargé depuis CDN.

### Pipeline de rendu

```
Images (JPEG)
  → TextureLoader (Three.js)
    → Canvas 2D (redimensionnement 1720×880, crop/letterbox)
      → ImageData (extraction pixels)
        → BufferGeometry (positions + couleurs)
          → Points (Three.js PointsMaterial)
            → WebGL Render
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

## Ajouter des images

1. Placer les fichiers JPEG dans `Ressources/` en respectant la convention de nommage : `IMG_001.jpg`, `IMG_002.jpg`, etc.
2. Modifier `maxImageIndex` dans `index.html` pour correspondre au nombre total d'images.
3. Incrémenter `IMAGE_VERSION` si les images sont mises en cache par le navigateur.

Les images sont automatiquement redimensionnées et recadrées à **1720×880** pixels.

---

## Technologies

| Technologie | Usage |
|-------------|-------|
| [Three.js](https://threejs.org/) r128 | Rendu WebGL, scène 3D, système de particules |
| JavaScript vanilla | Logique applicative, contrôles, gestion d'état |
| Canvas 2D | Traitement d'images, extraction de pixels |
| CSS | Interface utilisateur, panneaux de contrôle |

---

## Compatibilité

- Navigateur moderne avec **WebGL** (Chrome, Firefox, Safari, Edge)
- Desktop recommandé (trackpad ou molette)
- Ratio pixel plafonné à 2× pour les performances
- ~500 Mo – 1 Go de RAM selon la densité de particules

---

## Licence

Tous droits réservés. © Holosene
