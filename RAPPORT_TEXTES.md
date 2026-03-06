# RAPPORT COMPLET — Tous les textes de Photographic Volume

> Ce document liste **TOUS** les éléments de texte visibles et metadata du fichier `index.html`.
> Objectif : permettre la relecture, correction et mise à jour de chaque texte.

---

## 1. META TAGS & SEO

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 6 | `<meta name="description">` | Photographic Volume, espace immersif de photographies en particules 3D |
| 8 | `<meta property="og:title">` | Photographic Volume |
| 9 | `<meta property="og:description">` | Espace immersif de photographies en particules 3D |
| 11 | `<title>` | Volume Photographique |

---

## 2. CLICK-GATE (Écran d'entrée)

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1093 | `.click-gate-text` | CLIQUER |

---

## 3. LANDING PAGE (Page d'accueil)

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1099 | `.landing-title-line` (1ère ligne) | VOLUME |
| 1100 | `.landing-title-line` (2ème ligne) | PHOTOGRAPHIQUE |
| 1104 | `.landing-desc` | Traverser l'espace perceptif<br>de la photographie. |

> Note : le mot "PHOTOGRAPHIQUE" apparaît aussi via CSS `content` aux lignes 87 et 866.

---

## 4. INTRO PAGE (Page de texte intermédiaire)

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1118 | `.intro-text` (principal) | Ces photographies sont issues<br>d'archives personnelles,<br>collectées entre 2018 et 2024. |
| 1122 | `.intro-text-secondary` | Elles n'illustrent rien.<br>Elles ne documentent rien.<br>Elles existent comme des volumes —<br>des densités de lumière<br>suspendues dans le temps. |

---

## 5. INFO OVERLAY (Panneau d'information — touche "i")

### 5.1 Titre
| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1138 | `.info-title-top` | VOLUME |
| 1139 | `.info-title-main` | PHOTOGRAPHIQUE |

### 5.2 Section "Concept"
| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1147 | `.info-section-title` | Concept |
| 1148 | `<p>` | Chaque photographie est décomposée en particules<br>positionnées dans un espace 3D.<br>Le scroll contrôle la profondeur, les couches se séparent<br>et révèlent la structure interne de l'image. |

### 5.3 Section "Interaction"
| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1152 | `.info-section-title` | Interaction |
| 1153 | `<p>` | Scrollez ou glissez pour naviguer.<br>Le parcours est cyclique : zoom avant,<br>transition, zoom arrière, puis reprise. |

### 5.4 Section "Son génératif"
| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1157 | `.info-section-title` | Son génératif |
| 1158 | `<p>` | Le son est synthétisé en temps réel.<br>Chaque niveau de zoom modifie fréquences,<br>résonances et textures.<br>Le paysage audio évolue avec la profondeur visuelle. |

### 5.5 Footer info
| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1172 | `.info-tech` | Three.js · Web Audio API |
| 1173 | `.info-hint` (desktop) | Cliquez ou Alt pour revenir |
| 1173 | `.info-hint` (mobile) | Double-tap pour revenir |

---

## 6. BOUTON SON (Sound toggle)

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1161 | `#info-sound-toggle` | (icône SVG — pas de texte, deux états : son on / son off) |

---

## 7. PANNEAU SETTINGS — Scroll Configuration

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1212 | `scroll-config-header` | Scroll Configuration |
| 1217 | `<h3>` | Trackpad |
| 1220 | `<label>` | Sensitivity |
| 1225 | `<label>` | Detection Threshold (deltaY max) |
| 1230 | `<label>` | Frequency Threshold (ms) |
| 1237 | `<h3>` | Mouse Wheel |
| 1238 | `<p>` note | Accumulateur virtuel · lerp adaptatif |
| 1241 | `<label>` | Wheel Multiplier |
| 1243 | `<p>` note | Sync trackpad |
| 1247 | `<label>` | Wheel Lerp |
| 1249 | `<p>` note | 0.15–0.25 optimal |
| 1255 | `<h3>` | Global |
| 1258 | `<label>` | Zoom Lerp Speed |
| 1263 | `<label>` | Disparity Lerp Speed |
| 1270 | `<h3>` | Info |
| 1272 | info texte | Current Mode: Detecting... |
| 1273 | info texte | Last DeltaY: 0 |
| 1274 | info texte | Last Frequency: 0ms |
| 1275 | info texte | Scroll to see live detection |
| 1281 | `<button>` | Reset to Default |
| 1282 | `<button>` | Copy Config |

---

## 8. PANNEAU SETTINGS — Interface de Paramétrage

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1295 | `param-label` | Point Size |
| 1312 | `param-label` | Particle Shape |
| 1315-1316 | boutons forme | ● / ■ |
| 1323 | `param-label` | Color Mode |
| 1326-1327 | boutons couleur | Image / Floc'h |
| 1334 | `param-label` | Particle Density |
| 1351 | `param-label` | Depth Spread |
| 1368 | `param-label` | Breath Speed |
| 1385 | `param-label` | Movement Mode |
| 1388-1392 | boutons mouvement | Z / XY / XYZ / WAVE / SPIRAL |
| 1398 | `param-label` | Brightness |
| 1416 | `param-label` | Hide Black |
| 1433 | `param-label` | Grid Randomness |
| 1452 | `param-label` | Macro (plans) |
| 1468 | `param-label` | Micro (relief) |
| 1486 | `<button>` | Apply |
| 1487 | `<button>` | Reset to Defaults |
| 1488 | `<button>` | Reset Camera |

---

## 9. PANNEAU UX — États de Lecture

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1498 | `.ux-states-title` | États de Lecture |
| 1507 | `.ux-add-state-btn` | + |
| 1510 | `.ux-apply-btn` | Apply |
| 1514 | `.ux-curve-label` | Type de Courbe |
| 1516 | `<option>` | Linéaire |
| 1517 | `<option>` | Ease In (Accélération) |
| 1518 | `<option>` | Ease Out (Décélération) |
| 1519 | `<option>` | Ease In-Out (S-Curve) |
| 1524 | `.ux-toggle-btn` | Actif |

### États par défaut (JS)
| Ligne | Nom | Description |
|-------|-----|-------------|
| 1671 | État 1 | (paramètres initiaux) |
| 1680 | État 2 | (paramètres modifiés) |
| 1689 | État 3 | (paramètres modifiés) |
| 1698 | État 4 | (paramètres modifiés) |
| ~1705 | État 5 | (paramètres modifiés) |
| ~1708 | État 6 | (paramètres modifiés) |
| ~1712 | État 7 | (paramètres modifiés) |

---

## 10. PANNEAU DEBUG

| Ligne | Élément | Texte actuel |
|-------|---------|--------------|
| 1531 | `debug-header` | Debug Zoom & Camera |
| 1534 | `debug-label` | zoomLevel: |
| 1540 | `debug-label` | targetZoomLevel: |
| 1546 | `debug-label` | camera.position.z: |
| 1552 | `debug-label` | scrollPhase: |
| 1558 | `debug-label` | isTransitioning: |
| 1536,1542,1548,1554,1560 | `<button>` | Copy |

---

## 11. THÈMES AUDIO (noms affichés dans la console/debug)

| Ligne | Index | Nom du thème |
|-------|-------|--------------|
| 2647 | 1 | Résonance 01 |
| 2672 | 2 | Micro-Friction 02 |
| 2701 | 3 | Résonance 03 — Médium |
| 2725 | 4 | Résonance 04 — Cristallin |
| 2749 | 5 | Résonance 05 — Spectral |

---

## 12. MESSAGES DYNAMIQUES (JS)

| Ligne | Contexte | Texte actuel |
|-------|----------|--------------|
| ~4237 | Bouton Copy Config (après clic) | Copied! |
| ~5126 | Bouton UX toggle (actif) | Désactiver |
| ~5132 | Bouton UX toggle (inactif) | Actif |

---

## 13. MESSAGES CONSOLE (logs développeur)

| Ligne | Texte |
|-------|-------|
| 1821 | `[Depth Map] IMG_XXX chargée (WxH → TARGETWxH)` |
| 2036 | `[Depth Map] X/7 depth maps chargées` |
| 2040 | `Aucune image chargée. Vérifiez le dossier ./Ressources/photographies/` |

---

## 14. ATTRIBUTS ALT (images)

| Ligne | Élément | Alt actuel |
|-------|---------|------------|
| 1076 | `#custom-cursor img` | (vide) |
| 1102 | `.landing-rule img` | (vide) |
| 1120 | `.intro-rule img` | (vide) |

---

## 15. RÉFÉRENCES ARTISTIQUES (commentaires code)

| Ligne | Texte |
|-------|-------|
| 1833-1895 | Nicolas Floc'h — "La couleur de l'eau" × "Invisible" — 7 gradients = 7 colonnes d'eau des Calanques |

---

## RÉSUMÉ

| Catégorie | Nombre d'éléments |
|-----------|--------------------|
| Meta/SEO | 4 |
| Click-gate | 1 |
| Landing page | 3 |
| Intro page | 2 |
| Info overlay | 10 |
| Settings (scroll) | 15 |
| Settings (params) | 18 |
| UX states | 8 |
| Debug | 6 |
| Thèmes audio | 5 |
| Messages dynamiques | 3 |
| Logs console | 3 |
| Alt text vides | 3 |
| **TOTAL** | **~81 éléments de texte** |

---

*Rapport généré le 2026-03-06 — fichier source : `index.html`*
