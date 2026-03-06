# TEXTES MIS À JOUR — Volume Photographique
# Prompt Claude Code : remplacer tous les textes listés ci-dessous

> Contexte : Le projet croise deux séries de Nicolas Floc'h —
> les photographies N&B sous-marines d'**Invisible** (Calanques, 2018-2020)
> et les couleurs de la colonne d'eau de **La couleur de l'eau** (2016-2021).
> La profondeur de chaque pixel (Depth Anything V2 + luminance) détermine
> à la fois sa position Z et sa couleur, créant une traduction volumétrique
> et chromatique des paysages sous-marins méditerranéens.

---

## 1. META TAGS & SEO

| Élément | Texte actuel | → Nouveau texte |
|---------|-------------|-----------------|
| `<meta name="description">` | Photographic Volume, espace immersif de photographies en particules 3D | Volume Photographique — Traduction volumétrique des paysages sous-marins de Nicolas Floc'h |
| `<meta property="og:title">` | Photographic Volume | Volume Photographique |
| `<meta property="og:description">` | Espace immersif de photographies en particules 3D | Paysages sous-marins des Calanques traduits en sculptures de particules navigables |
| `<title>` | Volume Photographique | Volume Photographique |

---

## 2. CLICK-GATE

| Élément | Actuel | → Nouveau |
|---------|--------|-----------|
| `.click-gate-text` | CLIQUER | ENTRER |

---

## 3. LANDING PAGE

| Élément | Actuel | → Nouveau |
|---------|--------|-----------|
| `.landing-title-line` (1ère) | VOLUME | VOLUME |
| `.landing-title-line` (2ème) | PHOTOGRAPHIQUE | PHOTOGRAPHIQUE |
| `.landing-desc` | Traverser l'espace perceptif<br>de la photographie. | Traverser le volume<br>des paysages immergés. |

Note : si le CSS utilise `content` pour afficher "PHOTOGRAPHIQUE" ailleurs (lignes 87, 866), mettre à jour aussi.

---

## 4. INTRO PAGE

| Élément | Actuel | → Nouveau |
|---------|--------|-----------|
| `.intro-text` | Ces photographies sont issues<br>d'archives personnelles,<br>collectées entre 2018 et 2024. | Ces photographies sont issues<br>de la série Invisible<br>de Nicolas Floc'h — Calanques, 2018-2020. |
| `.intro-text-secondary` | Elles n'illustrent rien.<br>Elles ne documentent rien.<br>Elles existent comme des volumes —<br>des densités de lumière<br>suspendues dans le temps. | Paysages sous-marins en noir et blanc,<br>recolorisés par la colonne d'eau —<br>la profondeur donne la teinte,<br>la lumière sculpte le volume. |

---

## 5. INFO OVERLAY

### 5.1 Titre
Inchangé : VOLUME / PHOTOGRAPHIQUE

### 5.2 Concept
| Actuel | → Nouveau |
|--------|-----------|
| Chaque photographie est décomposée en particules<br>positionnées dans un espace 3D.<br>Le scroll contrôle la profondeur, les couches se séparent<br>et révèlent la structure interne de l'image. | Ce projet croise deux séries de Nicolas Floc'h.<br>Les paysages sous-marins d'Invisible sont décomposés<br>en particules 3D. Leur couleur provient de<br>La couleur de l'eau — chaque profondeur<br>reçoit la teinte réelle de la colonne d'eau<br>au même endroit des Calanques. |

### 5.3 Interaction
| Actuel | → Nouveau |
|--------|-----------|
| Scrollez ou glissez pour naviguer.<br>Le parcours est cyclique : zoom avant,<br>transition, zoom arrière, puis reprise. | Scrollez pour pénétrer dans l'image.<br>Les couches se séparent, le volume se révèle.<br>À la profondeur maximale, une transition<br>vous fait remonter vers la photographie suivante —<br>de la côte vers le large. |

### 5.4 Son génératif
| Actuel | → Nouveau |
|--------|-----------|
| Le son est synthétisé en temps réel.<br>Chaque niveau de zoom modifie fréquences,<br>résonances et textures.<br>Le paysage audio évolue avec la profondeur visuelle. | Le son est généré en temps réel.<br>Les fréquences montent avec le zoom,<br>du grave profond au cristallin de surface.<br>Le paysage sonore traduit la pression<br>et la densité du milieu immergé. |

### 5.5 Ajouter une section "Crédits" AVANT le footer
```html
<div class="info-section">
    <div class="info-section-title">Crédits</div>
    <p>
        Photographies : Nicolas Floc'h, série Invisible,
        commande publique Parc national des Calanques, 2018-2020.
        Palette chromatique : La couleur de l'eau, Nicolas Floc'h,
        FRAC Provence-Alpes-Côte d'Azur, 2020.
        Conception et développement : Holosene, 2025-2026.
    </p>
</div>
```

### 5.6 Footer
| Élément | Actuel | → Nouveau |
|---------|--------|-----------|
| `.info-tech` | Three.js · Web Audio API | Three.js · Web Audio API · Depth Anything V2 |
| `.info-hint` (desktop) | Cliquez ou Alt pour revenir | Appuyez sur i ou cliquez pour fermer |
| `.info-hint` (mobile) | Double-tap pour revenir | Double-tap pour fermer |

---

## 6. PANNEAU SETTINGS — Labels paramètres

| Actuel | → Nouveau |
|--------|-----------|
| Point Size | Taille |
| Particle Shape | Forme |
| Color Mode | Couleur |
| boutons Image / Floc'h | Photographie / Colonne d'eau |
| Particle Density | Densité |
| Depth Spread | Profondeur |
| Breath Speed | Respiration |
| Movement Mode | Mouvement |
| Brightness | Luminosité |
| Hide Black | Masquer sombres |
| Grid Randomness | Dispersion |
| Macro (plans) | Macro (plans) |
| Micro (relief) | Micro (relief) |

Note : les boutons Apply / Reset to Defaults / Reset Camera deviennent :
| Actuel | → Nouveau |
|--------|-----------|
| Apply | Appliquer |
| Reset to Defaults | Réinitialiser |
| Reset Camera | Réinitialiser caméra |

---

## 7. PANNEAU SCROLL CONFIG

Garder en anglais technique (c'est du debug, pas du public).
Seul changement :
| Actuel | → Nouveau |
|--------|-----------|
| Reset to Default | Réinitialiser |
| Copy Config | Copier |

---

## 8. PANNEAU UX ÉTATS

| Actuel | → Nouveau |
|--------|-----------|
| États de Lecture | États |
| Type de Courbe | Courbe |
| Linéaire | Linéaire |
| Ease In (Accélération) | Ease In |
| Ease Out (Décélération) | Ease Out |
| Ease In-Out (S-Curve) | Ease In-Out |
| Actif | Actif |
| Désactiver | Inactif |

---

## 9. PANNEAU DEBUG

Garder en anglais technique (debug uniquement).
Inchangé.

---

## 10. THÈMES AUDIO — Renommer pour correspondre au contexte sous-marin

| Actuel | → Nouveau |
|--------|-----------|
| Résonance 01 | Benthique |
| Micro-Friction 02 | Krill |
| Résonance 03 — Médium | Pélagique |
| Résonance 04 — Cristallin | Phytoplancton |
| Résonance 05 — Spectral | Bioluminescence |

---

## 11. MESSAGES CONSOLE — Mettre en anglais cohérent

| Actuel | → Nouveau |
|--------|-----------|
| `[Depth Map] IMG_XXX chargée` | `[Depth] IMG_XXX loaded` |
| `[Depth Map] X/7 depth maps chargées` | `[Depth] ${n}/7 depth maps loaded` |
| `Aucune image chargée. Vérifiez le dossier` | `No images found. Check path.` |

---

## 12. ALT TEXT — Ajouter pour l'accessibilité

| Élément | Alt actuel | → Nouveau |
|---------|-----------|-----------|
| `#custom-cursor img` | (vide) | Curseur |
| `.landing-rule img` | (vide) | Séparateur |
| `.intro-rule img` | (vide) | Séparateur |

---

## RÉSUMÉ DES CHANGEMENTS

Les modifications principales :
1. **Intro page** : suppression du texte "archives personnelles" (faux) → crédit Floc'h + description du geste
2. **Info overlay** : explication précise du croisement Invisible × La couleur de l'eau
3. **Crédits** : nouvelle section avec attribution complète (Floc'h, Parc des Calanques, FRAC PACA)
4. **Labels settings** : passage en français cohérent
5. **Thèmes audio** : renommage contextuel (vocabulaire marin)
6. **Landing** : "paysages immergés" au lieu de "la photographie" (ancrage thématique)

Ce qui ne change PAS :
- Le titre "VOLUME PHOTOGRAPHIQUE" (validé)
- Les panneaux debug et scroll config (technique, pas public)
- La structure HTML (juste le contenu textuel)
