# Claude_Skills

Une **marketplace de plugins** pour [Claude Code](https://claude.com/claude-code) : un noyau à avoir dans toutes tes sessions, et une banque de skills à installer seulement dans les projets où ils servent. Aucun script, rien à copier ni à ignorer dans tes projets.

| Dossier | Rôle |
|---|---|
| `core/` | Plugin « noyau » : `grill-with-docs` (+ `grilling`, `domain-modeling`), sous-agent `relecteur`, hook de contrôle |
| `bank/<catégorie>/<skill>/` | La banque : un plugin par skill, rangé par catégorie (`generic`, `frontend`, `crm`, `dataviz`, `backend`) |
| `.claude-plugin/marketplace.json` | Le catalogue lu par Claude Code |
| `user-config/` | Réglages personnels à coller une fois dans `~/.claude/` |

## Installation

Dans Claude Code (ou avec `claude plugin ...` dans un terminal) :

```text
/plugin marketplace add BlayTeuR/Claude_Skills
/plugin install core@claude-skills
```

Choisis la portée **user** pour `core` : il sera actif dans tous tes projets, sans rien ajouter à leurs dépôts.

Puis colle une fois dans ta config personnelle :

- `user-config/settings.snippet.json` : à fusionner dans `~/.claude/settings.json` (`git push` demande confirmation, push sur `main`/`master` et `gh pr merge` refusés).
- `user-config/CLAUDE.snippet.md` : à ajouter à `~/.claude/CLAUDE.md` (workflow branche + PR, revue avant de finir).

Sous Windows, Claude Code utilise Git Bash : rien d'autre à installer.

## Piocher un skill de la banque

Chaque skill est un plugin installable à la carte. Dans un projet :

```text
/plugin install find-skills@claude-skills
```

Choisis la portée **local** : elle s'écrit dans `.claude/settings.local.json`, qui n'est pas commité. Les catégories se parcourent avec `/plugin` (champ `category` du catalogue). Les skills d'un plugin s'appellent `/<plugin>:<skill>` (ex. `/core:grill-with-docs`) ; le déclenchement automatique par description n'est pas affecté.

Mettre à jour : `/plugin marketplace update claude-skills`. Les plugins n'ont pas de numéro de version : ils suivent le dernier commit de `main`.

## Ce que contient `core`

- **Skills** : `grill-with-docs` (à lancer à la main : entretien pour affiner un plan, qui crée glossaire et ADR au fil de l'eau), avec ses dépendances `grilling` et `domain-modeling`.
- **Hook `Stop`** (`core/hooks/gates.sh`) : s'il y a des changements non commités, Claude est bloqué dans sa fin de tour tant que les tests échouent ou que le `relecteur` n'a pas relu le code actuel. La commande de test est détectée seule (npm, pytest, cargo, go, mvn, make) ou lue dans `.claude/test-command` du projet. Limite assumée : le hook ne bloque qu'**une fois** par tour (anti-boucle infinie) ; c'est un garde-fou, pas une garantie.
- **Sous-agent `relecteur`** : relit le diff et valide la revue s'il ne trouve rien de bloquant. La validation est liée à l'état exact du code (empreinte stockée dans `.git/`) : modifier le code après la revue l'invalide.

## Workflow PR

Claude travaille sur une branche et ouvre une pull request ; il lui est interdit de pousser sur `main`/`master` ou de merger une PR (règles du `user-config`). C'est toi qui relis et merges. Pour une vraie garantie, active aussi la protection de branche sur `main` dans GitHub (PR obligatoire).

## Ajouter un skill à la banque

Voir `bank/_template/README.md` : copier le gabarit dans `bank/<catégorie>/<skill>/`, puis déclarer le plugin dans `.claude-plugin/marketplace.json`.

## Crédits

Skills tiers, copiés tels quels sauf mention contraire. Chaque licence MIT est conservée à côté des fichiers concernés.

| Skills | Source | Licence |
|---|---|---|
| `grill-with-docs`, `grilling`, `domain-modeling` (`core/`) | [mattpocock/skills](https://github.com/mattpocock/skills), commit `5863806` | MIT, `core/LICENSE-mattpocock-skills.txt` |
| `find-skills` (`bank/generic/`) | [vercel-labs/skills](https://github.com/vercel-labs/skills), commit `50894c1` | MIT, `bank/generic/find-skills/LICENSE-vercel-labs-skills.txt` |

Modification : dans `grill-with-docs`, les noms des skills appelés sont préfixés par `core:` (nécessaire dans un plugin).

`find-skills` propose d'installer des skills avec `npx skills add ... -y` (sans confirmation) : relis la source et la licence de tout skill tiers avant de l'installer.
