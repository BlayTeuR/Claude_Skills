# CLAUDE.md

Ce dépôt est une **marketplace de plugins Claude Code** : un noyau (`core/`) et une banque de skills (`bank/`). Voir le README pour l'usage.

## Structure

- `.claude-plugin/marketplace.json` : liste des plugins installables. Tout plugin ajouté doit y figurer.
- `core/` : plugin « noyau » (skills, sous-agent `relecteur`, hook `Stop` `hooks/gates.sh`).
- `bank/<catégorie>/<skill>/` : un plugin par skill (`.claude-plugin/plugin.json` + `skills/<skill>/SKILL.md`). Gabarit : `bank/_template/`.
- `user-config/` : réglages personnels à coller à la main dans `~/.claude/` (un plugin ne peut pas les embarquer).
- `.claude/settings.json` : réglages de ce dépôt seulement (permissions + hook qui pointe vers `core/hooks/gates.sh`).

## Conventions

- Pas de champ `version` dans les `plugin.json` : les mises à jour suivent le dernier commit.
- Le nom d'un skill est en minuscules-avec-tirets et unique dans toute la banque ; sa `description` tient sur une ligne.
- Skills tiers : copiés tels quels (sauf modification signalée dans le fichier), avec leur licence dans le dossier du plugin et une ligne dans la section Crédits du README.
- `core/hooks/gates.sh` (`fingerprint`) et la commande de `core/agents/relecteur.md` calculent la même empreinte : toute modification de l'une impose de modifier l'autre.

## Règles de travail

- Jamais de push sur `main`, jamais de merge de PR : branche, push, pull request ; l'utilisateur relit et merge.
- Avant de terminer une tâche qui modifie du code, invoque le sous-agent `relecteur`. Le hook bloque la fin du tour si les tests échouent ou si la revue manque.
- Les scripts `.sh` doivent rester en LF (`.gitattributes`).
