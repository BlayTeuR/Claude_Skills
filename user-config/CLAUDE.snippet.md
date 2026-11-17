## Règles de travail (toutes sessions)

- **Jamais de push sur `main`/`master`, jamais de merge de PR.** Travaille sur une branche, pousse-la, ouvre une pull request (`gh pr create`, sinon donne le lien de comparaison GitHub). L'utilisateur relit la PR et le code, puis merge lui-même.
- Avant de terminer une tâche qui modifie du code, invoque le sous-agent `relecteur`. Un hook bloque la fin du tour si les tests échouent ou si la revue manque.
- Ne télécharge ni n'installe jamais un skill tiers (par exemple via `npx skills add`) sans demander d'abord à l'utilisateur, en donnant la source et la licence.
