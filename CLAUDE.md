# CLAUDE.md

Ce dépôt est une **marketplace de plugins Claude Code** : un noyau (`core/`) et une banque de skills (`bank/`). Voir le README pour l'usage.

## Structure

- `.claude-plugin/marketplace.json` : liste des plugins installables. Tout plugin ajouté doit y figurer.
- `core/` : plugin « noyau » (workflow de Matt Pocock : grill-with-docs, to-spec, to-tickets, implement, code-review, retro, tdd et leurs dépendances ; sous-agent `relecteur` ; hook `Stop` `hooks/gates.sh`).
- `bank/<catégorie>/<skill>/` : un plugin par skill (`.claude-plugin/plugin.json` + `skills/<skill>/SKILL.md`). Gabarit : `bank/_template/`.
- `user-config/` : réglages personnels à coller à la main dans `~/.claude/` (un plugin ne peut pas les embarquer).
- `.claude/settings.json` : réglages de ce dépôt seulement (permissions + hook qui pointe vers `core/hooks/gates.sh`).

## Conventions

- Pas de champ `version` dans les `plugin.json` : les mises à jour suivent le dernier commit.
- Le nom d'un skill est en minuscules-avec-tirets et unique dans toute la banque ; sa `description` tient sur une ligne.
- Skills tiers : copiés tels quels, avec leur licence dans le dossier du plugin et une ligne dans la section Crédits du README. Toute modification (par ex. le préfixe `core:`) est signalée dans la section Crédits du README, et dans le fichier lui-même quand elle est faite à la main (commentaire HTML).
- Dans `core/skills/`, tout appel d'un skill à un autre (« Skill tool with "x" ») et toute indication `/commande` vers un skill de `core` doit porter le préfixe `core:` (les skills de plugin sont préfixés). Après chaque mise à jour depuis l'amont, vérifier par `grep -rn "Skill tool" core/skills` qu'aucun appel n'est resté sans préfixe. Les skills amont non inclus (`triage`, `implement-spec`, `wayfinder`…) ne sont pas dans le plugin : leurs mentions restent telles quelles.
- `core/hooks/gates.sh` (`fingerprint`) et la commande de `core/agents/relecteur.md` calculent la même empreinte : toute modification de l'une impose de modifier l'autre.

## Règles de travail

- Jamais de push sur `main`, jamais de merge de PR : branche, push, pull request ; l'utilisateur relit et merge.
- Avant de terminer une tâche qui modifie du code, invoque le sous-agent `relecteur`. Le hook bloque la fin du tour si les tests échouent ou si la revue manque.
- Les scripts `.sh` doivent rester en LF (`.gitattributes`).
