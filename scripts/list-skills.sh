#!/usr/bin/env bash
# Liste les skills installés (.claude/skills) et ceux de la banque (bank/).
#
# Usage :
#   bash scripts/list-skills.sh          # affichage dans le terminal
#   bash scripts/list-skills.sh --index  # régénère bank/README.md depuis les SKILL.md

set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Lit la ligne "description:" du frontmatter d'un SKILL.md (description sur une seule ligne).
desc() {
  tr -d '\r' < "$1" | awk '
    /^---[[:space:]]*$/ { n++; next }
    n == 1 && /^description:/ {
      sub(/^description:[[:space:]]*/, ""); gsub(/^["\047]|["\047]$/, ""); print; exit
    }'
}

bank_skills() { find bank -mindepth 3 -maxdepth 3 -name SKILL.md 2>/dev/null | sort; }

if [ "${1:-}" = "--index" ]; then
  OUT=bank/README.md
  {
    cat <<'EOF'
# Banque de skills

Ces skills ne sont **pas** chargés par Claude Code. Pour en activer un dans le projet :

```bash
bash scripts/add-skill.sh <catégorie>/<skill>
```

Cet index est généré : `bash scripts/list-skills.sh --index` (ne pas éditer à la main).
Pour créer un skill, copie `_template/` dans la bonne catégorie.

| Skill | Catégorie | Description |
|---|---|---|
EOF
    bank_skills | while read -r f; do
      d=$(dirname "$f"); echo "| \`$(basename "$d")\` | $(basename "$(dirname "$d")") | $(desc "$f" | sed 's/|/\\|/g') |"
    done
  } > "$OUT"
  echo "Index régénéré : $OUT"
  exit 0
fi

echo "== Installés (.claude/skills/) =="
found=0
for f in .claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  found=1; printf '  %-22s %s\n' "$(basename "$(dirname "$f")")" "$(desc "$f" | cut -c1-90)"
done
[ "$found" -eq 1 ] || echo "  (aucun)"

echo
echo "== Banque (bank/) =="
found=0; last=""
while read -r f; do
  [ -n "$f" ] || continue
  d=$(dirname "$f"); cat=$(basename "$(dirname "$d")"); name=$(basename "$d")
  [ "$cat" = "$last" ] || { echo "  [$cat]"; last="$cat"; }
  mark=" "; [ -d ".claude/skills/$name" ] && mark="*"
  printf '   %s %-22s %s\n' "$mark" "$name" "$(desc "$f" | cut -c1-90)"
  found=1
done < <(bank_skills)
[ "$found" -eq 1 ] && echo "  (* = déjà installé)" || echo "  (vide : crée un skill depuis bank/_template/)"
