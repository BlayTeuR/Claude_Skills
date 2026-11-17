#!/usr/bin/env bash
# Hook "Stop" du plugin core : empêche Claude de terminer son tour tant que
#   1. les tests du projet ne passent pas, et
#   2. le sous-agent "relecteur" n'a pas relu les changements actuels.
# Ne fait rien s'il n'y a aucun changement non commité ni dans un dépôt git.
#
# Commande de test : première ligne non commentée de .claude/test-command si ce fichier existe,
# sinon détection automatique (npm, pytest, cargo, go, mvn, make). Aucune commande = pas de gate tests.
#
# Le marqueur de revue est dans .git/ (jamais suivi ni visible dans git status). Il est écrit par le
# relecteur avec la même empreinte que fingerprint() ci-dessous : si tu modifies l'une, modifie l'autre
# (voir agents/relecteur.md).
#
# Sortie 2 = bloque l'arrêt, le message sur stderr est renvoyé à Claude.

PROJ="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$PROJ" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
TOP=$(git rev-parse --show-toplevel)
MARKER="$(git rev-parse --absolute-git-dir)/claude-reviewed"

# Empreinte de l'état actuel : statut + diff + contenu des fichiers non suivis (calculée depuis la racine du dépôt).
fingerprint() {
  (
    cd "$TOP" || exit 1
    {
      git status --porcelain
      git diff HEAD 2>/dev/null
      git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do cksum "$f"; done
    }
  ) | cksum
}

# Commande de test du projet.
detect_test_command() {
  if [ -f .claude/test-command ]; then
    tr -d '\r' < .claude/test-command | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' | head -n 1
    return
  fi
  if [ -f package.json ] && grep -q '"test"[[:space:]]*:' package.json && ! grep -q 'no test specified' package.json; then
    if   [ -f pnpm-lock.yaml ]; then echo "pnpm test"
    elif [ -f yarn.lock ];      then echo "yarn test"
    else echo "npm test"; fi
    return
  fi
  if [ -f pytest.ini ] || grep -qs 'pytest' pyproject.toml setup.cfg tox.ini || ls tests/test_*.py >/dev/null 2>&1; then
    echo "pytest"; return
  fi
  [ -f Cargo.toml ] && { echo "cargo test"; return; }
  [ -f go.mod ]     && { echo "go test ./..."; return; }
  [ -f pom.xml ]    && { echo "mvn test"; return; }
  if [ -f Makefile ] && grep -q '^test:' Makefile; then echo "make test"; return; fi
  return 0
}

INPUT=$(cat)

# Rien à vérifier s'il n'y a aucun changement.
[ -z "$(cd "$TOP" && git status --porcelain)" ] && exit 0

# Anti-boucle : si Claude a déjà été relancé par ce hook, on le laisse terminer.
if printf '%s' "$INPUT" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

problems=""

# Empreinte calculée AVANT les tests : un test qui écrit des fichiers ne doit pas invalider la revue.
FP=$(fingerprint)

# --- Gate 1 : tests verts ---
TEST_CMD=$(detect_test_command)
if [ -n "$TEST_CMD" ]; then
  if ! OUT=$(bash -c "$TEST_CMD" 2>&1); then
    problems="${problems}- Les tests échouent (\`$TEST_CMD\`). Dernières lignes :
$(printf '%s\n' "$OUT" | tail -n 30)
"
  fi
fi

# --- Gate 2 : revue obligatoire ---
if [ "$(cat "$MARKER" 2>/dev/null)" != "$FP" ]; then
  problems="${problems}- Les changements actuels n'ont pas été relus. Invoque le sous-agent \"relecteur\" (il valide la revue s'il ne trouve rien de bloquant).
"
fi

if [ -n "$problems" ]; then
  printf 'Tu ne peux pas terminer tant que ces points ne sont pas réglés :\n%s' "$problems" >&2
  exit 2
fi
exit 0
