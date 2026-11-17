#!/usr/bin/env bash
# À lancer dans un PROJET créé depuis le template (jamais dans le template lui-même).
#
# Rôle : garder l'environnement Claude (.claude/, bank/, scripts/, CLAUDE.md...) sur ta machine
# sans le commiter dans le projet. Le script :
#   1. ajoute ces fichiers au .gitignore du projet (bloc balisé, ajouté une seule fois) ;
#   2. les retire de l'index git (git rm --cached) s'ils étaient déjà suivis : les fichiers
#      restent sur ton disque, seule leur suppression est mise en attente de commit.
#
# Usage :
#   bash scripts/ignore-template.sh                    # demande confirmation
#   bash scripts/ignore-template.sh --yes              # sans confirmation
#   bash scripts/ignore-template.sh --keep-claude-md   # garde CLAUDE.md versionné dans le projet
#
# Le bloc du .gitignore n'est écrit qu'une fois : pour changer d'option après coup,
# supprime le bloc balisé du .gitignore puis relance le script.

set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

YES=0
KEEP_CLAUDE_MD=0
for a in "$@"; do
  case "$a" in
    --yes|-y) YES=1 ;;
    --keep-claude-md) KEEP_CLAUDE_MD=1 ;;
    *) echo "Option inconnue : $a (voir l'en-tête du script)" >&2; exit 1 ;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Pas un dépôt git : $ROOT" >&2; exit 1; }

ENTRIES=(".claude/" "bank/" "scripts/" "THIRD_PARTY_LICENSE_mattpocock.txt")
[ "$KEEP_CLAUDE_MD" -eq 1 ] || ENTRIES+=("CLAUDE.md")

START="# >>> environnement Claude local (scripts/ignore-template.sh)"
END="# <<< environnement Claude local"

echo "Dépôt : $ROOT"
echo "Remote : $(git remote get-url origin 2>/dev/null || echo '(aucun)')"
echo "Seront ignorés par git (les fichiers restent sur ton disque) :"
printf '  %s\n' "${ENTRIES[@]}"
echo "ATTENTION : ne lance pas ceci dans le template lui-même, il s'ignorerait."

if [ "$YES" -ne 1 ]; then
  if [ ! -t 0 ]; then echo "Pas de terminal : relance avec --yes pour confirmer." >&2; exit 1; fi
  read -r -p "Continuer ? [o/N] " ans || ans=""
  case "$ans" in o|O|y|Y) ;; *) echo "Annulé."; exit 1 ;; esac
fi

# 1. .gitignore (une seule fois)
touch .gitignore
if grep -qF "$START" .gitignore; then
  echo ".gitignore : bloc déjà présent, inchangé."
else
  [ -s .gitignore ] && [ -n "$(tail -c1 .gitignore)" ] && echo >> .gitignore   # fin de ligne manquante
  # Motifs ancrés à la racine ("/bank/") : sinon ils ignoreraient aussi src/bank/, app/scripts/, etc.
  { echo "$START"; printf '/%s\n' "${ENTRIES[@]}"; echo "$END"; } >> .gitignore
  echo ".gitignore : bloc ajouté."
fi

# 2. Retirer de l'index ce qui était déjà suivi (les fichiers restent sur le disque)
if [ -n "$(git ls-files -- "${ENTRIES[@]}")" ]; then
  git rm -r --cached -q --ignore-unmatch -- "${ENTRIES[@]}"
  echo "Index : fichiers du template retirés du suivi git (suppression en attente de commit)."
else
  echo "Index : rien à retirer."
fi

echo "Termine par : git add .gitignore && git commit -m \"Ignorer l'environnement Claude local\""
