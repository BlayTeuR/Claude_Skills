# CLAUDE.md

> À remplir pour chaque projet. Supprime les lignes d'aide (`>`) une fois fait.

## Projet

> Une ou deux phrases : ce que fait le projet, pour qui.

## Commandes

> Les commandes dont Claude a besoin. La commande de test doit aussi être dans `.claude/test-command` (via `bash scripts/init.sh`).

- Installer : `...`
- Lancer : `...`
- Tester : `...`
- Lint / format : `...`

## Conventions

> Ce qui n'est pas évident en lisant le code : style, nommage, structure, pièges connus.

- ...

## Règles de travail (fournies par le template)

- Avant de terminer une tâche qui modifie du code, invoque le sous-agent `relecteur`. Un hook bloque la fin du tour si les tests échouent ou si la revue manque.
- **Jamais de push sur `main`/`master`, jamais de merge de PR.** Travaille sur une branche, pousse-la, ouvre une pull request (`gh pr create`, sinon donne le lien de comparaison GitHub). L'utilisateur relit la PR et le code, puis merge lui-même.
- `git push` demande toujours confirmation.
- Les skills génériques sont dans `.claude/skills/`. Les autres sont dans `bank/` : ne les charge pas, propose-les à l'utilisateur (`bash scripts/list-skills.sh`, puis `bash scripts/add-skill.sh <skill>`).
