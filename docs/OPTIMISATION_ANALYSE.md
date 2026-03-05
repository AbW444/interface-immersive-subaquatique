# Analyse d'optimisation - Interface Immersive Subaquatique

## Date: 2025-12-19

## Problèmes de performance identifiés

### 🔴 CRITIQUE - Impact élevé sur les performances

#### 1. Mise à jour DOM à chaque frame (ligne ~942)
**Problème**: `updateUIValues()` appelé à chaque frame pendant le zoom
- Met à jour 12 éléments DOM (6 affichages + 6 sliders)
- Opération coûteuse : textContent et value assignments
- Exécuté potentiellement 60 fois/seconde

**Impact**:
- Force reflow/repaint du navigateur
- Bloque le thread principal
- Cause potentielle des saccades

**Solution proposée**:
- Throttle à max 10 updates/seconde
- Utiliser requestIdleCallback pour updates non-critiques
- Batch les updates DOM

#### 2. Boucle d'oscillation des particules (lignes 963-977)
**Problème**: Parcourt TOUS les vertices à chaque frame quand movement > 0
- Pour une image 1720x880 à density 1.6 = ~2.4 millions de particules
- Calcul Math.sin() pour chaque particule
- 3 opérations par particule (offset, oscillation, assignment)

**Impact**:
- CPU intensif
- Exécuté 60 fois/seconde
- Peut causer des frame drops

**Solution proposée**:
- Utiliser GPU via vertex shader pour l'oscillation
- Ou limiter le nombre de particules animées
- Ou utiliser un WebWorker pour les calculs

#### 3. Rechargements d'images fréquents (lignes 950-959)
**Problème**: Seuils trop bas (0.2 density, 1.5 disparity)
- De 0 à 1.6 density = 7 rechargements potentiels
- De 0 à 9 disparity = 6 rechargements potentiels
- Chaque rechargement = destruction/création géométrie complète

**Impact**:
- Freeze temporaire pendant le chargement
- Garbage collection intensive
- Cause principale des saccades actuelles

**Solution proposée**:
- Augmenter les seuils (0.4 density, 3.0 disparity)
- Implémenter un délai (debounce) de 200ms
- Limiter à 1 rechargement toutes les 500ms max

### 🟡 MOYEN - Impact modéré

#### 4. Création/Destruction de Canvas (ligne 737-748)
**Problème**: Nouveau canvas créé à chaque loadImage()
- Allocation mémoire répétée
- Pas de réutilisation du canvas existant

**Solution proposée**:
- Créer un canvas global réutilisable
- Éviter les allocations répétées

#### 5. Math.random() dans loadImage (ligne 788)
**Problème**: Random non déterministe = positions Z différentes à chaque reload
- Peut causer des "jumps" visuels pendant les rechargements
- Math.random() relativement lent

**Solution proposée**:
- Utiliser un seed basé sur l'index du pixel
- Positions cohérentes entre rechargements

#### 6. Pas de RAF throttling
**Problème**: animate() tourne toujours même sans changements
- Ligne 928 : requestAnimationFrame appelé inconditionnellement

**Solution proposée**:
- Early exit si aucun changement détecté
- Pause RAF quand inactif

### 🟢 FAIBLE - Optimisations mineures

#### 7. Calculs redondants dans la boucle (ligne 969-976)
**Problème**:
- `particles.userData.time + offset` calculé pour chaque particule
- `particleParams.movement * 2` calculé à chaque itération

**Solution proposée**:
- Pré-calculer `movement * 2` une fois
- Optimiser la boucle

#### 8. Array slicing (ligne 800)
**Problème**: `particleVertices.slice()` copie tout l'array
- Pour 2.4M particules × 3 coords = 7.2M éléments copiés

**Solution proposée**:
- Nécessaire pour initialPosition, mais coûteux
- Considérer TypedArray.from() si plus rapide

## Optimisations recommandées par ordre de priorité

### Phase 1 - Quick Wins (Impact immédiat, faible risque)

1. **Throttle updateUIValues()** à 100ms
2. **Augmenter les seuils de rechargement** (0.4 density, 3.0 disparity)
3. **Debounce les rechargements** (300ms delay)
4. **Canvas réutilisable**
5. **Early exit dans animate()** si aucun changement

### Phase 2 - Optimisations moyennes (Impact moyen, risque modéré)

6. **Optimiser la boucle d'oscillation**
   - Pré-calculer les valeurs constantes
   - Utiliser TypedArray directement
7. **Random déterministe** dans loadImage
8. **RequestIdleCallback** pour updates UI non-critiques

### Phase 3 - Optimisations avancées (Impact élevé, risque élevé)

9. **Vertex shader pour oscillation**
   - Déplace calculs sur GPU
   - Nécessite custom ShaderMaterial
10. **LOD (Level of Detail)**
    - Moins de particules quand zoom out
11. **Instancing** pour particules identiques
12. **WebWorker** pour traitement d'images

## Benchmarks suggérés

### Métriques à mesurer avant/après:
- FPS moyen pendant zoom
- Temps de rechargement d'image (ms)
- Memory usage (MB)
- Frame drops count
- Time to interactive (ms)

### Outils:
- Chrome DevTools Performance
- Stats.js pour FPS monitoring
- Memory profiler

## Code d'exemple pour optimisations Phase 1

### 1. Throttle updateUIValues
```javascript
let lastUIUpdate = 0;
const UI_UPDATE_INTERVAL = 100; // ms

function animate() {
  requestAnimationFrame(animate);
  const now = performance.now();

  if (Math.abs(targetZoomLevel - zoomLevel) > 0.001) {
    // ... existing code ...

    // Throttled UI update
    if (now - lastUIUpdate > UI_UPDATE_INTERVAL) {
      updateUIValues();
      lastUIUpdate = now;
    }
  }
}
```

### 2. Debounce rechargements
```javascript
let reloadTimeout = null;
const RELOAD_DEBOUNCE = 300; // ms

// Dans animate()
if (densityChange > 0.4 || disparityChange > 3.0) {
  clearTimeout(reloadTimeout);
  reloadTimeout = setTimeout(() => {
    lastDensity = particleParams.density;
    lastDisparity = particleParams.disparity;
    loadImage(currentImageIndex);
  }, RELOAD_DEBOUNCE);
}
```

### 3. Canvas réutilisable
```javascript
// Global
const offscreenCanvas = document.createElement('canvas');
const offscreenContext = offscreenCanvas.getContext('2d');

function loadImage(imageIndex) {
  textureLoader.load(imagePath, function (texture) {
    // Réutiliser le canvas existant
    offscreenCanvas.width = targetWidth;
    offscreenCanvas.height = targetHeight;
    offscreenContext.drawImage(texture.image, 0, 0, targetWidth, targetHeight);
    const imgData = offscreenContext.getImageData(0, 0, targetWidth, targetHeight);
    // ...
  });
}
```

### 4. Early exit RAF
```javascript
function animate() {
  requestAnimationFrame(animate);

  let needsRender = false;

  if (Math.abs(targetZoomLevel - zoomLevel) > 0.001) {
    // ... zoom logic ...
    needsRender = true;
  }

  if (particles && particleParams.movement > 0) {
    // ... oscillation logic ...
    needsRender = true;
  }

  if (needsRender) {
    renderer.render(scene, camera);
  }
}
```

### 5. Optimiser boucle oscillation
```javascript
if (particles && particleParams.movement > 0) {
  particles.userData.time += 0.01;

  const positions = particles.geometry.attributes.position.array;
  const initialPositions = particles.geometry.attributes.initialPosition.array;
  const time = particles.userData.time;
  const movementDouble = particleParams.movement * 2; // Pré-calculé

  for (let i = 0; i < positions.length; i += 3) {
    const offset = i * 0.1;
    const oscillation = Math.sin(time + offset) * movementDouble;
    positions[i + 2] = initialPositions[i + 2] + oscillation;
  }
  particles.geometry.attributes.position.needsUpdate = true;
}
```

## Résultats attendus

### Après Phase 1:
- Réduction saccades: ~70%
- FPS pendant zoom: +15-20 fps
- Rechargements: -50%

### Après Phase 2:
- FPS global: +10 fps
- Memory usage: -20%
- Fluidité perçue: +30%

### Après Phase 3:
- FPS constant 60fps
- Zoom ultra-fluide
- Support plus de particules
