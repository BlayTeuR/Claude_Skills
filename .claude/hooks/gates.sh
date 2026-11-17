#!/usr/bin/env bash
# Hook "Stop" : empêche Claude de terminer son tour tant que
#   1. les tests (.claude/test-command) ne passent pas, et
#   2. le sous-agent "relecteur" n'a pas relu les changements actuels.
# Ne fait rien s'il n'y a aucun changement non commité.
#
# Usage manuel : bash .claude/hooks/gates.sh --mark   (enregistre "revue faite", appelé par le relecteur)
#
# Sortie 2 = bloque l'arrêt, le message sur stderr est renvoyé à Claude.

# Racine du projet : $CLAUDE_PROJECT_DIR, sinon deux niveaux au-dessus de ce script.
cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

MARKER=.claude/.reviewed   # ignoré par git

# Empreinte de l'état actuel : statut + diff + contenu des fichiers non suivis.
fingerprint() {
  {
    git status --porcelain
    git diff HEAD 2>/dev/null
    git ls-files --others --exclude-standard -z | xargs -0 -r cksum
  } | cksum
}

if [ "${1:-}" = "--mark" ]; then
  if fingerprint > "$MARKER"; then
    echo "Revue enregistrée pour l'état actuel du code."
    exit 0
  fi
  echo "Échec : impossible d'écrire $MARKER" >&2
  exit 1
fi

INPUT=$(cat)

# Rien à vérifier s'il n'y a aucun changement.
[ -z "$(git status --porcelain)" ] && exit 0

# Anti-boucle : si Claude a déjà été relancé par ce hook, on le laisse terminer.
if printf '%s' "$INPUT" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

problems=""

# Empreinte calculée AVANT les tests : un test qui écrit des fichiers ne doit pas invalider la revue.
FP=$(fingerprint)

# --- Gate 1 : tests verts ---
TEST_CMD=""
[ -f .claude/test-command ] && TEST_CMD=$(tr -d '\r' < .claude/test-command | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' | head -n 1)

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
