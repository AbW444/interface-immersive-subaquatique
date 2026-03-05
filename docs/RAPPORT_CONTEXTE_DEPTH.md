# RAPPORT TECHNIQUE — Système de profondeur volumétrique
## Contexte complet pour implémentation du moteur hybride Depth Map + Luminance

---

## 1. PRÉSENTATION DU PROJET

**Photographic Volume** est une expérience web immersive 3D qui transforme des photographies (noir et blanc, série sous-marine de Floc'h "La couleur de l'eau") en nuages de particules volumétriques navigables via scroll. Chaque pixel de la photo devient une particule positionnée dans un espace 3D, avec une profondeur Z calculée qui crée un effet de volume sculptural.

**Stack technique** : HTML/CSS/JS pur, Three.js pour le rendu 3D (PointsMaterial), AudioContext pour le son génératif, le tout dans un seul fichier `index.html`.

---

## 2. HISTORIQUE CHRONOLOGIQUE COMPLET

### Phase 0 — Fondation (12 déc. 2025 → 4 mars 2026)
- `0a1e968` : Clone initial du projet LABW (moteur de base avec particules)
- Uploads successifs d'images test, configuration favicon/curseur
- Le système original utilisait probablement un **seededRandom** pour la profondeur Z (pas de logique de luminance ni de depth map)

### Phase 1 — Luminance comme moteur de profondeur (5 mars 2026)
- `c3b6bcc` **"Profondeur par luminance + gradient couleur Floc'h"** — COMMIT CLÉ
  - **normalizedDepth** passe de `seededRandom` à `luminance Rec.601`
  - Formule : `luminance = 0.299*R + 0.587*G + 0.114*B`
  - `normalizedDepth = (luminance - 0.5) + noise(±0.06)`
  - Pixels clairs = devant (Z positif), sombres = derrière (Z négatif)
  - Micro-bruit seedé pour casser les plans plats iso-luminance
  - Ajout `depthCache` pour stocker les profondeurs par image
  - Premier système de couleur gradient Floc'h (Méditerranée / Atlantique)

### Phase 2 — Intégration des Depth Maps (5 mars 2026)
- `b546c65` **"Intégrer les depth maps Depth Anything V2"** — COMMIT CLÉ
  - Ajout `depthMapCache` (Map : imageIndex → ImageData)
  - Fonction `preloadDepthMap()` : charge `IMG_XXX_depth.png` silencieusement
  - **Les depth maps remplacent la luminance** pour le calcul de Z
  - Si depth map dispo → Z = depthMapLuminance, sinon fallback → luminance photo
  - Réduction du micro-bruit de ±0.12 à ±0.05 (la depth map a déjà des variations fines)
  - Fichiers : `IMG_001_depth.png`, `IMG_002_depth.png`, `IMG_003_depth.png` (les 3 premières images seulement)

- `e01539c` **"Fix depth maps 404, invert depth, smooth transitions"**
  - Correction des 404 sur les depth maps manquantes
  - Inversion de la profondeur (les depth maps Depth Anything donnent blanc=proche, noir=loin)
  - Transitions fluides entre images avec depth maps

- `8e66998` **"Floc'h gradients per image, fix depth inversion, align depth maps"**
  - 7 gradients Floc'h distincts (un par image : vert côtier → bleu profond)
  - Fix alignement depth map / photo (crops différents causaient un décalage)
  - Close objects = Z positif, far = Z négatif
  - Suppression anciens gradients Méditerranée/Atlantique

### Phase 3 — RETOUR à la luminance pure (5 mars 2026)
- `5042e23` **"Remove depth maps, return to luminance volumetry"** — COMMIT CLÉ

  **Message de l'utilisateur qui a motivé ce retour :**
  > L'utilisateur a demandé de revenir à la volumétrie par luminance car les depth maps Depth Anything V2 ne couvraient que 3 images sur 7, créaient des incohérences visuelles, et la luminance produisait un résultat plus cohérent avec l'esthétique des photos N&B de Floc'h.

  **Changements :**
  - Suppression de TOUS les fichiers `*_depth.png` du repository
  - Suppression de `preloadDepthMap()`, `depthMapCache`, tout le code depth map
  - Retour à `normalizedDepth = (luminance - 0.5) + noise(±0.025)`
  - Colorisation Floc'h : les nuances de gris sont préservées et teintées par le gradient
  - `colorFromLuminance()` : interpole dans le gradient Floc'h puis module par luminance pour garder le détail/contraste des photos N&B originales

### Phase 4 — Perfectionnements post-retour (5 mars 2026)
- `9986393` **"Fix aligned depth/color transition with pixel-level coherence"**
  - Cohérence pixel-par-pixel entre couleurs et profondeurs pendant les transitions
  - `computeTransitionData()` utilise les mêmes pixels source que `buildGeometry()`

- `0faa7a7` **"Perf: optimize page load time (~85% faster)"**
  - Préchargement parallèle des images avec extraction couleurs/depths inline
  - Cache immédiat des `colorCache` et `depthCache` pendant le preload

- `e8cdb4a` → `580d458` : Améliorations UX (son, curseur, click-gate pour AudioContext)

---

## 3. SYSTÈME ACTUEL (Version courante)

### Pipeline de profondeur actuel
```
Photo JPG (N&B)
  → Extraction pixel par pixel
  → luminance = 0.299*R + 0.587*G + 0.114*B  (Rec.601)
  → normalizedDepth = (luminance - 0.5) + seededNoise(±0.025)
  → Stocké dans normalizedDepth buffer attribute (1 float par particule)
  → Z final = normalizedDepth × disparity (appliqué dynamiquement dans animate())
```

### Pipeline de couleur actuel
```
luminance du pixel
  → colorFromLuminance(luminance, imageIndex)
  → Lookup dans FLOCH_GRADIENTS[imageIndex] (7 gradients, 5 stops chacun)
  → Interpolation linéaire entre stops
  → Modulation par luminance (baseColor × luminance × 2.0) pour préserver les nuances
```

### Paramètres clés
```javascript
particleParams = {
  density: 0.4,        // Échantillonnage des pixels
  disparity: 0.0,      // Multiplicateur de profondeur Z (contrôlé par scroll)
  size: 0.02,          // Taille particules
  hideBlack: 0.0,      // Seuil pour masquer pixels noirs
  randomness: 0.0,     // Randomness positions XY
  saturation: 1.0,     // Saturation chromatique
  shape: 'circle'      // Forme particule
};
```

### Fichiers de données disponibles
```
Ressources/photographies/
  IMG_001.jpg → IMG_007.jpg    (7 photos officielles)
  IMG_Test001.jpg, IMG_test002.jpg, IMG_test003.jpg  (tests)
```
**Aucun fichier depth map n'existe actuellement dans le repo.**

### Fonctions clés du code actuel
- `buildGeometry()` (ligne ~1997) : Construit le nuage de particules initial
- `extractColorsAndDepths()` (ligne ~2148) : Extrait couleurs + profondeurs d'une image
- `computeTransitionData()` (ligne ~2191) : Calcule les données de transition entre images
- `colorFromLuminance()` (ligne ~1796) : Mappe luminance → couleur gradient Floc'h
- Boucle `animate()` (ligne ~3703) : Applique `position.z = normalizedDepth × disparity` dynamiquement
- `FLOCH_GRADIENTS` (ligne ~1727) : 7 gradients couleur (un par image)

---

## 4. CE QUE L'UTILISATEUR VEUT FAIRE : Moteur hybride Depth Map + Luminance

### Vision
> "Rajouter un moteur de profondeur avec l'utilisation de depth maps mais cette fois complémentaire à ce qu'on utilise actuellement. Ce serait un premier niveau de hiérarchisation de profondeur et par-dessus (en plus/après) il y aurait le système actuel. On aurait des 'plans' hiérarchisés par les fichiers depth, et ensuite on vient faire de la volumétrie par luminance par-dessus. En gros les gros plans sont hiérarchisés par les fichiers depth et sont un moteur volumétrique, et après c'est aussi calculé par la luminance de la photo elle-même par le moteur actuel."

### Architecture proposée (2 couches de profondeur)

```
COUCHE 1 — Depth Map (macro-profondeur, séparation des plans)
  Fichier : IMG_XXX_depth.png (Depth Anything V2 ou similaire)
  → Définit les GRANDS PLANS de la scène (premier plan, arrière-plan, etc.)
  → Plage : -0.5 à +0.5 (normalisée depuis la depth map)
  → C'est la structure spatiale "architecturale" de l'image

COUCHE 2 — Luminance (micro-volumétrie, relief dans chaque plan)
  Source : la photo elle-même (luminance Rec.601)
  → Ajoute du RELIEF VOLUMÉTRIQUE à l'intérieur de chaque plan
  → Les zones claires ressortent légèrement, les zones sombres reculent
  → C'est le "modelé" sculptural qui donne la vie aux surfaces

PROFONDEUR FINALE = depthMap × poidsMacro + luminance × poidsMicro
```

### Pourquoi ce système hybride ?
1. **Les depth maps seules** donnaient des plans bien séparés mais des surfaces "plates" à l'intérieur de chaque plan
2. **La luminance seule** (système actuel) donne un beau relief sculptural mais ne distingue pas les vrais plans de profondeur — un sujet sombre au premier plan peut se retrouver "derrière" un fond clair
3. **Les deux ensemble** : les depth maps organisent la macro-structure (sujet devant, fond derrière), et la luminance sculpte le micro-relief à l'intérieur de chaque plan → volumétrie réaliste et expressive

### Ce qu'il faudra faire
1. **Générer les depth maps** pour les 7 images (Depth Anything V2) — fichiers `IMG_XXX_depth.png`
2. **Réintroduire le chargement des depth maps** (avec fallback gracieux si fichier manquant)
3. **Modifier le calcul de normalizedDepth** pour combiner les deux sources :
   ```javascript
   // Pseudo-code de la formule hybride
   const depthFromMap = depthMapLuminance;        // 0→1 depuis la depth map
   const depthFromLuminance = photoLuminance;      // 0→1 depuis la photo

   // Macro = depth map, Micro = luminance
   const macroDepth = (depthFromMap - 0.5);        // Séparation des plans
   const microDepth = (depthFromLuminance - 0.5);  // Relief dans le plan

   normalizedDepth = macroDepth * macroWeight + microDepth * microWeight + noise;
   ```
4. **Exposer les poids** (macroWeight, microWeight) en paramètres ajustables
5. **Le pipeline de couleur reste inchangé** (Floc'h gradients basés sur la luminance photo)

---

## 5. RÉSUMÉ DE L'ÉVOLUTION

| Version | Système de profondeur | Résultat |
|---------|----------------------|----------|
| v0 (initial) | `seededRandom()` | Profondeur aléatoire, pas de logique visuelle |
| v1 | `luminance photo` | Relief sculptural cohérent, mais pas de vrais plans |
| v2 | `depth map only` | Bons plans de profondeur, mais surfaces plates |
| v3 (actuel) | `luminance photo` (retour) | Relief sculptural, cohérence esthétique N&B |
| **v4 (à faire)** | **`depth map + luminance`** | **Plans réalistes + relief sculptural = le meilleur des deux mondes** |

---

## 6. NOTES TECHNIQUES IMPORTANTES

- Les depth maps Depth Anything V2 sont en niveaux de gris PNG (blanc=proche, noir=loin)
- Le système de transition entre images interpole les depths → il faudra gérer la transition hybride
- Le `depthCache` existe déjà dans le code (Map), prêt à être réutilisé
- Le `disparity` param contrôle l'amplitude globale de la profondeur Z via scroll
- Les 7 gradients Floc'h sont indépendants du système de profondeur (basés sur luminance photo, pas depth map)
- Le loop-unrolling dans animate() (4 particules à la fois) devra gérer la formule hybride
- Performance critique : ~400k particules à density 0.4, le calcul doit rester rapide
