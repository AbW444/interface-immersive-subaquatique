# VOLUME PHOTOGRAPHIQUE — Rapport technique v17 (5 mars 2026)

## Résumé exécutif

Application web mono-fichier (~4 500 lignes) construite sur THREE.js. Transforme des photographies en nuages de particules 3D navigables par scroll, avec un moteur audio génératif procédural synchronisé aux paramètres visuels. Aucun framework, aucun bundler, aucune dépendance npm — un seul `index.html` + ressources images/fonts.

---

## I. ARCHITECTURE MOTEUR — Vue d'ensemble

### Pipeline de rendu

```
Photographies JPG
       ↓
  Canvas 2D (extraction pixels)
       ↓
  Float32Array (positions, couleurs, profondeurs)
       ↓
  THREE.BufferGeometry (attributs GPU)
       ↓
  THREE.PointsMaterial (rendu particules)
       ↓
  WebGL Renderer (render-on-demand)
```

### Pipeline audio

```
Oscillateurs + Bruit (Brown/Pink)
       ↓
  Layers: Drone → Résonance → Sub-Bass → Grain → Breath → Scroll → Bell → Krill
       ↓
  Muffle (passe-bas -24dB/oct, 2 stages)
       ↓
  Warmth (waveshaper, saturation tape)
       ↓
  Compressor (-12dB threshold, ratio 3.5:1)
       ↓
  Convolver (reverb IR synthétique)
       ↓
  Master Gain → AudioContext.destination
```

---

## II. MOTEUR DE PARTICULES 3D

### 2.1 Configuration THREE.js

| Paramètre | Valeur | Raison |
|-----------|--------|--------|
| Renderer | `WebGLRenderer` antialias, high-performance | Qualité maximale |
| Pixel ratio | `min(devicePixelRatio, 3)` | Cap à 3× pour éviter la surcharge GPU sur écrans 4K+ |
| Camera | `PerspectiveCamera` 75° (65° mobile portrait) | FOV réduit sur mobile pour compenser le rapport d'aspect |
| Near/Far | 0.1 / 1000 | Range étendu pour le zoom |
| Camera Z initiale | 25 (zoomed out) → -2 (max zoom) | Déplacement caméra, pas des particules |

**Architecture Scene** : `Scene → Group (sceneGroup) → Points (particles)`. Le `sceneGroup` sert d'intermédiaire pour les animations de scale (entrée depuis le landing : scale 0.55 → 1.0).

### 2.2 Extraction image → particules

Chaque photographie est convertie en nuage de particules via un processus en 4 étapes :

**Étape 1 — Chargement** : `THREE.TextureLoader` charge le JPG, dessine sur un canvas off-screen de taille fixe (`TARGET_WIDTH × TARGET_HEIGHT`).

**Étape 2 — Échantillonnage** : Parcours du canvas pixel par pixel avec un pas `step = max(1, floor(1 / density))`. À density=0.6 (défaut), `step=1` → chaque pixel est traité. Le seuil alpha > 0.5 filtre les pixels transparents.

**Étape 3 — Calcul position** :
```
posX = (x - width/2) / scaleFactor   // Centrage horizontal
posY = (y - height/2) / scaleFactor   // Centrage vertical
posZ = 0                              // Plat initialement
```
`scaleFactor` : 50 (desktop), 55 (mobile portrait), 58 (mobile paysage). Un bruit positionnel `seededRandom` déterministe ajoute du jitter contrôlé par `randomness` (0 = grille parfaite, 1 = désorganisé).

**Étape 4 — Calcul couleur et profondeur** :
- Couleur : RGB normalisé 0–1, saturation ajustable via `saturateColor(r, g, b, intensity)` qui mélange vers la moyenne `avg = (r+g+b)/3`
- Profondeur : Luminance Rec.601 (`0.299R + 0.587G + 0.114B`) centrée sur 0, range [-0.5, +0.5]. Micro-bruit seeded ±0.06 pour casser les plans iso-luminance
- Filtrage : `hideBlack` élimine les pixels sous un seuil de luminosité

### 2.3 Attributs GPU (BufferGeometry)

4 attributs par particule :

| Attribut | Type | Usage |
|----------|------|-------|
| `position` | Float32×3 | Position XYZ courante (modifiée chaque frame) |
| `color` | Float32×3 | Couleur RGB (modifiée pendant les transitions) |
| `normalizedDepth` | Float32×1 | Profondeur normalisée [-0.5, +0.5] |
| `initialPosition` | Float32×3 | Position d'origine (référence pour mouvement/disparité) |

### 2.4 Matériau et texture

`THREE.PointsMaterial` standard (pas de shaders custom) :
- `vertexColors: true` — couleur par sommet
- `sizeAttenuation: true` — les particules diminuent avec la distance
- `depthWrite: false` — transparence correcte
- `blending: NormalBlending`
- `map` : Texture 64×64 canvas (`circle` = gradient radial soft, `square` = blanc plein)

**Aucun shader custom (vertex/fragment)** n'est utilisé. Tous les effets sont obtenus par manipulation des attributs de buffer côté CPU.

### 2.5 Système de disparité (profondeur 3D)

Transforme les images 2D en volumes 3D pseudo-stéréoscopiques :

```
position.z = normalizedDepth × disparity
```

- `disparity = 0` → image plate
- `disparity = 2.5` → volume prononcé (pixels clairs en avant, sombres en arrière)
- Interpolation smooth via lerp (`disparityLerp = 0.23`)
- **Loop unrolling ×4** pour optimisation SIMD-like sur le calcul de position Z

### 2.6 Modes de mouvement (5 modes)

Système de dispatch par table de fonctions (pas de if/else dans le hot loop) :

| Mode | Nom | Axes affectés | Comportement |
|------|-----|---------------|-------------|
| 1 | Z-only | Z | Oscillation sinusoïdale pure en profondeur |
| 2 | XY | X, Y | Mouvement planaire (sin X, cos Y) — **défaut** |
| 3 | XYZ | X, Y, Z | Mouvement spatial complet |
| 4 | WAVE | X, Y, Z | Onde propagée (phase dépend de X initial) |
| 5 | SPIRAL | X, Y, Z | Spirale (cos/sin en fonction du rayon) |

Amplitude contrôlée par `movement × 2` (doublée pour visibilité).

---

## III. SYSTÈME DE NAVIGATION ET SCROLL

### 3.1 Modèle de zoom

Le scroll contrôle un `zoomLevel` normalisé [0, 0.826632] :

```
Camera Z = 25 - (25 - (-2)) × zoomLevel = 25 - 27 × zoomLevel
```

| zoomLevel | Camera Z | Phase |
|-----------|----------|-------|
| 0.000 | 25.0 | Image plate, vue éloignée |
| 0.418 | 13.7 | Transition image terminée |
| 0.827 | 2.7 | Max zoom, déclenche transition |

### 3.2 Détection trackpad vs molette

Deux régimes de scroll indépendants :

**Trackpad** : Détecté par `deltaY < threshold` OU `deltaTime < frequencyThreshold`. Utilise un accumulateur d'inertie avec drain linéaire :
```
trackpadScrollAccumulator += deltaY × sensitivity
// drain par frame :
trackpadScrollAccumulator -= drainRate
```

**Molette** : Grosses impulsions `deltaY > threshold`. Utilise un accumulateur virtuel lissé (technique Lenis/smooth-scroll) :
```
wheelScrollAccumulator += deltaY × sensitivity × wheelMultiplier
// drain par frame :
wheelScrollAccumulator *= 0.88  // friction exponentielle
```

**Touch (mobile)** : Système de momentum avec vélocité lissée :
```
touchVelocity = touchVelocity × 0.4 + instantVelocity × 0.6
touchMomentum *= 0.92  // decay par frame
```

### 3.3 Cycle de scroll bidirectionnel infini

```
Phase zoomIn:  scroll → zoomLevel monte 0 → 0.827 → déclenche transition
Phase zoomOut: scroll → zoomLevel descend 0.827 → 0 → reset cycle
```

Dead zone après le cycle complet pour éviter les déclenchements accidentels. Le scroll est toujours unidirectionnel `Math.abs(deltaY)` : on ne recule jamais.

---

## IV. SYSTÈME DE TRANSITIONS INTER-IMAGES

### 4.1 Déclenchement

Quand `zoomLevel ≥ MAX_ZOOM_LEVEL (0.826632)`, `transitionToNextImage()` :
1. Sauvegarde couleurs et profondeurs actuelles (`oldColors`, `oldDepths`)
2. Extrait couleurs et profondeurs de l'image suivante (depuis le cache)
3. Passe en mode `isTransitioning = true`

### 4.2 Interpolation basée sur la position (pas le temps)

```
transitionProgress = (MAX_ZOOM_LEVEL - zoomLevel) / TRANSITION_DISTANCE
```

- `TRANSITION_DISTANCE = 0.408516`
- Le dézoom pilote la transition : à 0.827 → progress=0, à 0.418 → progress=1
- Les couleurs ET les profondeurs sont lerp'd simultanément :

```javascript
colors[i] = oldColors[i] + (newColors[i] - oldColors[i]) × progress
depths[i] = oldDepths[i] + (newDepths[i] - oldDepths[i]) × progress
```

**Avantage** : L'utilisateur contrôle directement la vitesse de transition par sa vitesse de scroll. Pas de timeline imposée.

---

## V. SYSTÈME D'ÉTATS UX (7 ÉTATS)

### 5.1 Architecture

7 états prédéfinis interpolés linéairement en fonction du `zoomLevel` :

| État | disparity | movement | Effet visuel |
|------|-----------|----------|-------------|
| 1 (z=0) | 0 | 0 | Image plate, immobile |
| 2 | 2.5 | 0.031 | Volume léger, micro-mouvement |
| 3 | 2.5 | 0.063 | Mouvement visible |
| 4 | 2.5 | 0.088 | Mouvement modéré |
| 5 | 2.5 | 0.25 | Mouvement prononcé |
| 6 | 2.5 | 0.5 | Mouvement fort |
| 7 (z=max) | 2.77 | 0.5 | Maximum, disparité maximale |

Paramètres communs : `size=0.04, density=0.6, randomness=0.4, saturation=1.0, shape=circle, movementMode=2 (XY)`.

### 5.2 Interpolation continue

À chaque frame, `zoomLevel` est mappé sur l'intervalle [0, numStates-1]. Les deux états encadrants sont interpolés linéairement sur chaque paramètre :

```javascript
const t = zoomLevel * (numStates - 1);
const lowerIdx = floor(t);
const upperIdx = min(lowerIdx + 1, numStates - 1);
const frac = t - lowerIdx;
particleParams.size = lower.size + (upper.size - lower.size) × frac;
// ... idem pour tous les paramètres
```

Clamping forcé à État 1 quand `zoomLevel < 0.001` et à État 7 quand `zoomLevel > 0.999` pour garantir la stabilité aux extrêmes.

---

## VI. MOTEUR AUDIO GÉNÉRATIF

### 6.1 Architecture du signal

```
AudioContext (Web Audio API)
├── Drone Layer (2-3 oscillateurs sin/tri, LFO amplitude/fréquence)
├── Résonance Layer (4 filtres BPF haute Q, excités par bruit rose)
├── Sub-Bass Layer (oscillateur grave + LFO pan stéréo)
├── Grain Layer (bruit brownien → BPF bande étroite)
├── Breath Layer (bruit brownien loopé, LFO amplitude lent)
├── Scroll Layer (bruit → BPF, déclenché par vélocité scroll)
├── Transition Bell Layer (4 oscillateurs harmoniques, déclenché par transitions)
└── Krill Layer (5 filtres très haute fréquence, thèmes 2-5 seulement)
      ↓ (tous convergent vers)
  Muffle (2× BiquadFilter lowpass, -24dB/oct)
      ↓
  Warmth (WaveShaper, courbe de saturation tape douce)
      ↓
  DynamicsCompressor (threshold -12dB, ratio 3.5:1, attack 80ms, release 400ms)
      ↓
  Convolver (IR synthétique brownienne × decay exponentiel × passe-bas)
      ↓
  Master Gain (0 → 0.634 en fondu)
      ↓
  AudioContext.destination
```

### 6.2 Les 5 thèmes

| # | Nom | Drone | Résonance Q | Sub | Muffle | Caractère |
|---|-----|-------|-------------|-----|--------|-----------|
| 1 | Résonance 01 | D2/A2 sine | 35 | Bb1 (46Hz) | 350Hz | Original, chaud, immergé |
| 2 | Micro-Friction 02 | D2/A2 sine + **Krill** | 35 | Bb1 | 450Hz | Frictions haute-fréquence (3.2–7.9kHz) |
| 3 | Médium | A2/E3 sine | 40 | A1 (55Hz) | 500Hz | Registre médium élargi, plus "chantant" |
| 4 | Cristallin | E3/B3 sine | 45 | E2 (82Hz) | 700Hz | Aigu, harmoniques qui brillent |
| 5 | Spectral | B3/F#4 **triangle** | 50 | B1 (62Hz) | 1000Hz | Ultra-aigu, quasi supra-audible |

**Progression thématique** : du grave/chaud (thème 1) vers l'aigu/cristallin (thème 5). Le muffle monte (350→1000Hz), le Q de résonance augmente (35→50), les fréquences drone montent d'une octave par thème.

### 6.3 Couches audio détaillées

**Drone** : 2 fréquences fondamentales × 3 oscillateurs désaccordés (-8/0/+8 cents). LFO amplitude (0.015Hz) crée une pulsation lente. LFO fréquence (0.008Hz, ±3Hz) ajoute de l'instabilité organique.

**Résonance** : 4 filtres bandpass haute Q (35-50) excités par du bruit rose loopé. Simule la résonance d'une cavité. Fréquences harmoniques du drone (octaves/quintes).

**Sub-Bass** : Oscillateur sinus grave (46-82Hz) avec LFO panoramique stéréo (0.07Hz) créant un balayage spatial.

**Grain** : Bruit brownien (-6dB/octave) filtré par un bandpass étroit. Bande [180-500Hz] à [600-2400Hz] selon le thème. Simule la texture granulaire.

**Breath** : Bruit brownien loopé × LFO amplitude sinusoïdal lent (0.06-0.12Hz). Simule la respiration ou les courants.

**Scroll/Whoosh** : Bruit → BPF large bande. Volume proportionnel à `scrollVelocity`. Direction du scroll module le pitch (zoom-in = montée, zoom-out = descente). Style sonar.

**Bell/Transition** : 4 oscillateurs sinusoïdaux (harmoniques 1-4, amplitudes 1/0.5/0.3/0.15). Déclenchés pendant les transitions inter-images. Gain proportionnel à `transitionProgress`.

**Krill** (thèmes 2-5) : 5 filtres haute fréquence (3.2-7.9kHz, Q=30) excités par bruit. Émerge progressivement au-delà de 40% du zoom. Simule des micro-organismes/frictions.

### 6.4 Mapping zoom → audio (temps réel, par frame)

| Paramètre visuel | Effet audio | Formule |
|-------------------|-------------|---------|
| `zoomLevel` (0→1) | Fréquence drone monte | `freq × lerp(freqRange[0], freqRange[1], zoomLevel)` |
| `zoomLevel` (0→1) | Muffle s'ouvre | `freq + zoomLevel × 800` (base→base+800Hz) |
| `zoomLevel` > 0.4 | Krill émerge | `gain = (zoom - 0.4) / 0.6 × krillVol` |
| `movement` | Intensité breath | `breathGain × (1 + movement × 3)` |
| `disparity` | Volume sub-bass | `subVol × (1 + disparity × 0.3)` |
| `scrollVelocity` | Volume whoosh | `scrollVol × min(velocity × 8, 1)` |
| `scrollDirection` | Pitch whoosh | `+1 = pitch up, -1 = pitch down` |
| `transitionProgress` | Volume bell | `0.15 × progress² × (3 - 2×progress)` (smoothstep) |

### 6.5 Gestion de la suspension du contexte

Problème : Les navigateurs suspendent l'`AudioContext` après ~30s sans user gesture.

**Mécanismes de récupération** :
- `ensureContextRunning()` : appelé sur click, pointerdown, wheel, keydown, mousemove (throttled 5s)
- `ctx.resume()` suivi de restauration du gain et reconstruction des layers si nécessaires
- Vérification périodique dans la boucle `animate()` (toutes les 5s)
- `visibilitychange` : fondu out 0.8s quand caché, fondu in 1.2s + reconstruction layers au retour

**Note** : `ctx.resume()` depuis `requestAnimationFrame` ne fonctionne PAS (pas un user gesture). Seuls les listeners d'interaction directe peuvent relancer le contexte.

---

## VII. OPTIMISATIONS PERFORMANCE

### 7.1 Render-on-demand

```javascript
let needsRender = false;
// ... (chaque modification flagge needsRender = true)
if (needsRender) {
  renderer.render(scene, camera);  // Seul point de rendu
}
```

Le renderer n'est appelé QUE si l'état visuel a changé. En idle (pas de scroll, pas de mouvement), 0 draw calls.

### 7.2 Batch GPU updates

Les modifications de `position.array` sont accumulées et marquées `needsUpdate = true` une seule fois par frame, en fin de boucle.

### 7.3 Loop unrolling ×4

Le calcul de disparité (boucle la plus chaude, ~500k+ itérations) est déroulé par 4 :

```javascript
for (let i = 0; i < len - 3; i += 4) {
  positions[idx0 + 2] = normalizedDepths[i] * disparity;
  positions[idx1 + 2] = normalizedDepths[i+1] * disparity;
  positions[idx2 + 2] = normalizedDepths[i+2] * disparity;
  positions[idx3 + 2] = normalizedDepths[i+3] * disparity;
}
```

### 7.4 Function dispatch table

Les 5 modes de mouvement utilisent une table de dispatch au lieu de branches if/else :

```javascript
const movementFunc = movementFunctions[mode];
for (let i = 0; i < len; i += 3) {
  movementFunc(positions, initialPositions, i, time, movementDouble);
}
```

Élimine le branch prediction miss sur chaque itération.

### 7.5 Cache multi-niveaux

| Cache | Contenu | Quand |
|-------|---------|-------|
| `imageCache` (Map) | ImageData brut | Au pré-chargement |
| `colorCache` (Map) | Tableaux RGB extraits | À la première utilisation |
| `depthCache` (Map) | Tableaux profondeur | À la première utilisation |
| `textureCache` | Textures canvas circle/square | Au premier appel |

**Pré-chargement** : Toutes les images sont chargées au démarrage (`preloadAllImages`). Détection auto par probing séquentiel (`IMG_001.jpg`, `IMG_002.jpg`, ..., arrêt au premier 404).

### 7.6 Réutilisation canvas

Un seul canvas off-screen (`offscreenCanvas`) est réutilisé pour toutes les extractions de pixels, évitant les allocations/GC.

### 7.7 Seeded random déterministe

```javascript
function seededRandom(x, y, seed) {
  const combined = (x * 73856093) ^ (y * 19349663) ^ seed;
  return (Math.abs(Math.sin(combined)) * 10000 % 1000) / 1000;
}
```

Même résultat pour les mêmes coordonnées → pas besoin de stocker les offsets aléatoires.

---

## VIII. ÉVOLUTION PAR RAPPORT AUX VERSIONS PRÉCÉDENTES

### Phase 1 — Prototype (12-18 déc 2025)
- Clone initial depuis un projet "LABW"
- Système de particules basique avec contrôles clavier
- Fond Jonas (arrière-plan canvas)
- Pas d'audio, pas de landing, pas de states

### Phase 2 — Zoom et navigation (18-19 déc)
- Introduction du zoom par scroll
- Interface minimaliste
- Arrière-plan négatif (touche N) et Jonas (touche J)
- Première passe d'optimisation

### Phase 3 — Système d'états (20 déc)
**Changement majeur** : Introduction du "UX Journey Mode" avec 7 états interpolés.
- Passage du déplacement des particules au déplacement de la caméra (`camera.position.z` au lieu de scale particles)
- Interpolation continue des paramètres en fonction du zoom
- Scroll bidirectionnel infini avec cycle zoomIn/zoomOut
- Première passe de lissage scroll (accumulation virtuelle Lenis-style)

### Phase 4 — Optimisation pro (20-21 déc)
- Pré-chargement de toutes les images + cache multi-niveaux
- Lerp smooth pour la disparité (élimination des saccades)
- Function dispatch tables + loop unrolling ×4 + batch GPU
- Accumulateur scroll adaptatif trackpad/molette
- Scroll bidirectionnel infini + galerie photographique

### Phase 5 — Moteur audio (3 mars 2026)
**Changement majeur** : Ajout complet du moteur audio génératif procédural.
- 5 thèmes "Résonance Immergée" avec 8 couches audio
- Mapping temps réel zoom/scroll/mouvement → paramètres audio
- Chaîne master pro (muffle -24dB, warmth tape, compressor, convolver reverb)
- Bruit brownien (-6dB/oct) et rose (-3dB/oct) synthétisés
- IR de reverb synthétique (pas de sample externe)

### Phase 6 — Landing & identité (3-4 mars)
- Page d'accueil avec titre VOLUME / PHOTOGRAPHIQUE
- Page d'introduction (contexte des photographies)
- Info overlay (Alt/Esc/clic droit)
- Scroll-to-dismiss sur landing et intro
- Animation séquencée fadeUp des éléments
- Lueur typographique (filter blur sur ::after)

### Phase 7 — Curseur et polish (4 mars)
- Curseur custom (image PNG 6px) avec glow bleu
- Synchronisation curseur ↔ info overlay
- Système de screenshot (natif + supersampled hi-res)
- Navigation directe par saisie numérique
- Profondeur par luminance Rec.601 + gradient couleur "La couleur de l'eau"
- Mobile : touch momentum, double-tap, responsive

### Phase 8 — Stabilisation audio & CSS grid (5 mars)
- Fix audio context suspension (user gesture requirement)
- Recovery robuste : reconstruction layers, restauration gain, listeners multiples
- Centrage du point curseur via CSS grid (1fr auto 1fr)
- Typography fine-tuning (letter-spacing PHOTOGRAPHIQUE)

---

## IX. MÉTRIQUES TECHNIQUES

| Métrique | Valeur |
|----------|--------|
| Taille fichier | ~4 500 lignes, ~200 KB HTML |
| Dépendances | THREE.js (CDN), Google Fonts (2) |
| Shaders custom | 0 (tout en PointsMaterial standard) |
| Particules typiques | ~500k+ (dépend résolution image × density) |
| Layers audio | 8 simultanées par thème |
| Thèmes audio | 5 |
| États UX | 7 |
| Modes mouvement | 5 |
| Images supportées | Détection auto (probing séquentiel) |
| Mobile | Oui (touch, responsive, FOV adaptatif) |
| Render strategy | On-demand (0 draw calls en idle) |
| Audio recovery | 5 mécanismes (click, pointer, wheel, key, mousemove + periodic + visibility) |

---

## X. LIMITATIONS CONNUES

1. **Pas de shaders custom** : Tous les calculs de position/couleur sont CPU-side. Un compute shader ou un vertex shader custom permettrait de déplacer la disparité et le mouvement sur le GPU.
2. **Mono-thread** : Le calcul de particules (500k+ itérations) est sur le thread principal. Un Web Worker pourrait décharger l'interpolation.
3. **Pas de LOD** : Toutes les particules sont rendues quelle que soit la distance caméra. Un système de LOD réduirait le nombre de particules en vue éloignée.
4. **Audio context browser** : Malgré 5 mécanismes de recovery, certains navigateurs (Safari en particulier) peuvent être plus agressifs dans la suspension.
5. **Pas de depth-of-field** : L'effet de profondeur est uniquement géométrique (position Z), sans flou de profondeur de champ (nécessiterait un post-process shader).
