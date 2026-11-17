# Claude_Skills

Template de projet pour [Claude Code](https://claude.com/claude-code) : un noyau de skills et de garde-fous chargés à chaque session, plus une **banque** de skills à piocher selon le projet.

## Principe

| Dossier | Rôle | Chargé par Claude Code ? |
|---|---|---|
| `.claude/` | Le noyau : skills génériques, hook de contrôle, sous-agent de revue | **Oui** |
| `bank/` | La banque de skills, rangés par catégorie | Non |
| `scripts/` | Les scripts pour gérer tout ça | Non |

Garder la banque hors de `.claude/` évite de charger des dizaines de skills inutiles à chaque session.

## Utilisation

1. Clique sur **Use this template** pour créer le répo d'un nouveau projet.
2. Dans le nouveau répo :
   ```bash
   bash scripts/init.sh              # écrit la commande de test dans .claude/test-command
   ```
3. Remplis `CLAUDE.md` (projet, commandes, conventions).
   Si l'environnement Claude ne doit rester que sur ta machine (cas d'un projet qui n'est pas « le tien ») :
   ```bash
   bash scripts/ignore-template.sh   # ajoute .claude/, bank/, scripts/... au .gitignore et les retire du suivi git
   ```
4. Ajoute au besoin des skills de la banque :
   ```bash
   bash scripts/list-skills.sh              # voir ce qui est installé / disponible
   bash scripts/add-skill.sh frontend/xxx   # copie bank/frontend/xxx -> .claude/skills/xxx
   ```
   Puis ouvre une nouvelle session Claude Code.

Sous Windows, utilise Git Bash (les scripts sont en bash).

## Ce que contient le noyau

- **Skills** (`.claude/skills/`) : `grill-with-docs` (à lancer avec `/grill-with-docs` : entretien pour affiner un plan, qui crée glossaire et ADR au fil de l'eau) et ses deux dépendances `grilling` et `domain-modeling`.
- **Hook `gates.sh`** : s'il y a des changements non commités, Claude est bloqué dans sa fin de tour tant que les tests (`.claude/test-command`) échouent ou que le sous-agent `relecteur` n'a pas relu le code actuel. Limite assumée : le hook ne bloque qu'**une fois** par tour (anti-boucle infinie). Si Claude s'arrête une deuxième fois sans avoir réglé le problème, le tour se termine quand même : c'est un garde-fou, pas une garantie absolue.
- **Sous-agent `relecteur`** : relit le diff et valide la revue s'il ne trouve rien de bloquant. La validation est liée à l'état exact du code : modifier le code après la revue l'invalide.
- **Workflow PR** : Claude travaille sur une branche et ouvre une pull request ; il lui est interdit de pousser sur `main`/`master` ou de merger une PR (`.claude/settings.json`). C'est toi qui relis et merges. Pour une garantie côté GitHub, active aussi la protection de branche sur `main` (PR obligatoire).
- **`git push`** (hors `main`) : demande toujours confirmation.

## Ajouter un skill à la banque

Copie `bank/_template/` dans `bank/<catégorie>/<nom-du-skill>/`, édite le `SKILL.md`, puis `bash scripts/list-skills.sh --index` pour mettre à jour `bank/README.md`. Le nom d'un skill doit être unique dans toute la banque.

## Crédits

Les skills `grill-with-docs`, `grilling` et `domain-modeling` viennent de [mattpocock/skills](https://github.com/mattpocock/skills) (commit `5863806`), sous licence MIT, copyright Matt Pocock. Texte de la licence : [THIRD_PARTY_LICENSE_mattpocock.txt](THIRD_PARTY_LICENSE_mattpocock.txt). Tout skill tiers ajouté ensuite doit être listé ici avec sa source et sa licence.
