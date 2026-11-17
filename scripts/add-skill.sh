#!/usr/bin/env bash
# Installe un skill de la banque dans le projet : copie bank/<catégorie>/<skill>/ -> .claude/skills/<skill>/
#
# Usage :
#   bash scripts/add-skill.sh frontend/mon-skill
#   bash scripts/add-skill.sh mon-skill            # cherche dans toutes les catégories
#   bash scripts/add-skill.sh mon-skill --force    # écrase une version déjà installée

set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FORCE=0
ARG=""
for a in "$@"; do
  case "$a" in
    --force|-f) FORCE=1 ;;
    -*) echo "Option inconnue : $a" >&2; exit 1 ;;
    *)  ARG="$a" ;;
  esac
done
[ -n "$ARG" ] || { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

# Valider l'argument : "skill" ou "categorie/skill", minuscules/chiffres/./_/- uniquement.
# Refuse "..", les chemins absolus, les jokers et "_template".
if ! printf '%s' "$ARG" | grep -Eq '^[a-z0-9][a-z0-9._-]*(/[a-z0-9][a-z0-9._-]*)?$'; then
  echo "Nom invalide : $ARG (attendu : skill ou categorie/skill, en minuscules)" >&2; exit 1
fi

# Trouver le dossier source dans la banque.
if [ -f "bank/$ARG/SKILL.md" ]; then
  SRC="bank/$ARG"
else
  MATCHES=$(find bank -mindepth 3 -maxdepth 3 -path "bank/*/$ARG/SKILL.md" 2>/dev/null | sed 's#/SKILL.md$##' || true)
  COUNT=$(printf '%s' "$MATCHES" | grep -c . || true)
  if [ "$COUNT" -eq 0 ]; then
    echo "Skill introuvable dans bank/ : $ARG  (voir : bash scripts/list-skills.sh)" >&2; exit 1
  elif [ "$COUNT" -gt 1 ]; then
    echo "Nom ambigu, précise la catégorie :" >&2; printf '%s\n' "$MATCHES" | sed 's#^bank/#  #' >&2; exit 1
  fi
  SRC="$MATCHES"
fi

NAME="$(basename "$SRC")"
DEST=".claude/skills/$NAME"

if [ -e "$DEST" ] && [ "$FORCE" -ne 1 ]; then
  echo "Déjà installé : $DEST (utilise --force pour écraser)" >&2; exit 1
fi

mkdir -p .claude/skills
# Copie dans un dossier temporaire puis remplacement : l'ancienne version survit si la copie échoue.
TMP="$DEST.tmp.$$"
rm -rf "$TMP"
cp -R "$SRC" "$TMP"
rm -rf "$DEST"
mv "$TMP" "$DEST"
echo "Installé : $SRC -> $DEST"
echo "Redémarre la session Claude Code (ou ouvre-en une nouvelle) pour qu'il soit pris en compte."
