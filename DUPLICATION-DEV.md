# Duplication vers photographic-volume_DEV

## Ce qui a été fait (automatiquement)

1. **Copie propre créée** dans `/home/user/photographic-volume_DEV`
   - Fichiers copiés sans le dossier `.git`
   - Contenu : `index.html` + `Ressources/` (10 images + 2 fonds)

2. **Nouveau repo git initialisé** dans ce dossier
   - Branche : `main`
   - Premier commit : `init: clean version from photographic-volume`
   - Aucun historique de développement conservé

## Ce qu'il reste à faire (manuellement)

Le repo GitHub distant ne peut pas être créé automatiquement depuis cet environnement
(gh CLI non disponible, pas de token GitHub configuré).

### Option A — Avec gh CLI (recommandé)

```bash
cd /home/user/photographic-volume_DEV
gh repo create Holosene/photographic-volume_DEV \
  --public \
  --description "Version vitrine propre de photographique-volume" \
  --source=. \
  --remote=origin \
  --push
```

Ou utiliser le script fourni :
```bash
bash /home/user/photographique-volume/create-dev-repo.sh
```

### Option B — Manuellement sur GitHub

1. Aller sur https://github.com/new
2. Nommer le repo : `photographic-volume_DEV`
3. Laisser vide (ne pas initialiser avec README)
4. Puis dans le terminal :

```bash
cd /home/user/photographic-volume_DEV
git remote add origin https://github.com/Holosene/photographic-volume_DEV.git
git push -u origin main
```

## Résultat attendu

- URL du nouveau repo : https://github.com/Holosene/photographic-volume_DEV
- 1 seul commit propre, sans historique de développement
- Branche principale : `main`
