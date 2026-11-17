#!/usr/bin/env bash
# À lancer une fois par projet, juste après avoir créé le répo depuis le template.
#
# Rôle : écrire dans .claude/test-command la commande qui lance les tests du projet.
# Le hook .claude/hooks/gates.sh est le même pour tous les projets ; c'est ce fichier
# qui lui dit comment tester CE projet (npm test, pytest, cargo test...).
#
# Usage :
#   bash scripts/init.sh                 # détecte la commande, sinon la demande
#   bash scripts/init.sh "pytest -q"     # impose la commande
#   bash scripts/init.sh --none          # aucun test pour l'instant (gate des tests désactivée)

set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FILE=.claude/test-command

detect() {
  if [ -f package.json ]; then
    if grep -q '"test"[[:space:]]*:' package.json && ! grep -q 'no test specified' package.json; then
      if   [ -f pnpm-lock.yaml ]; then echo "pnpm test"
      elif [ -f yarn.lock ];      then echo "yarn test"
      else echo "npm test"; fi
      return
    fi
  fi
  if [ -f pytest.ini ] || grep -qs 'pytest' pyproject.toml setup.cfg tox.ini \
     || ls tests/test_*.py >/dev/null 2>&1; then
    echo "pytest"; return
  fi
  [ -f Cargo.toml ]   && { echo "cargo test"; return; }
  [ -f go.mod ]       && { echo "go test ./..."; return; }
  [ -f pom.xml ]      && { echo "mvn test"; return; }
  [ -f gradlew ]      && { echo "./gradlew test"; return; }
  [ -f composer.json ] && grep -q '"test"' composer.json && { echo "composer test"; return; }
  if [ -f Makefile ] && grep -q '^test:' Makefile; then echo "make test"; return; fi
  return 0
}

if [ "${1:-}" = "--none" ]; then
  CMD=""
elif [ $# -ge 1 ]; then
  case "$1" in -*) echo "Option inconnue : $1 (voir l'en-tête du script)" >&2; exit 1 ;; esac
  CMD="$1"
else
  CMD="$(detect || true)"
  if [ -n "$CMD" ]; then
    echo "Commande de test détectée : $CMD"
  elif [ -t 0 ]; then
    read -r -p "Commande de test du projet (vide = aucune pour l'instant) : " CMD || CMD=""
  else
    echo "Aucune commande de test détectée." >&2
  fi
fi

{
  echo "# Une seule commande de test, sur la première ligne non commentée. Générée par scripts/init.sh"
  [ -n "$CMD" ] && echo "$CMD"
} > "$FILE"

chmod +x .claude/hooks/*.sh scripts/*.sh 2>/dev/null || true

if [ -n "$CMD" ]; then
  echo "OK : $FILE -> $CMD"
else
  echo "OK : aucune commande de test (gate des tests désactivée). Relance init.sh quand tu en auras une."
fi
echo "Pense à remplir CLAUDE.md."
