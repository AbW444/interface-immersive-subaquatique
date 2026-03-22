#!/bin/bash
# Script pour finaliser la création du repo photographic-volume_DEV sur GitHub
# Prérequis : gh CLI installé et authentifié (gh auth login)

set -e

REPO_NAME="photographic-volume_DEV"
OWNER="Holosene"
LOCAL_DIR="/home/user/photographic-volume_DEV"

echo "=== Étape 1 : Vérification du dossier local ==="
if [ ! -d "$LOCAL_DIR" ]; then
  echo "ERREUR: Le dossier $LOCAL_DIR n'existe pas."
  echo "Exécute d'abord les étapes de préparation locales."
  exit 1
fi

echo "Dossier trouvé : $LOCAL_DIR"
cd "$LOCAL_DIR"
git log --oneline

echo ""
echo "=== Étape 2 : Création du repo GitHub ==="
gh repo create "$OWNER/$REPO_NAME" \
  --public \
  --description "Version vitrine propre de photographique-volume (sans historique de développement)" \
  --source=. \
  --remote=origin \
  --push

echo ""
echo "=== Terminé ! ==="
echo "Le repo est disponible sur : https://github.com/$OWNER/$REPO_NAME"
