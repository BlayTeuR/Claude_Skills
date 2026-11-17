# Gabarit d'un skill de la banque

Chaque skill de la banque est un **plugin** : un dossier `bank/<catégorie>/<skill>/` qui contient

```
.claude-plugin/plugin.json      # name + description
skills/<skill>/SKILL.md         # le skill lui-même (+ fichiers annexes éventuels)
```

## Ajouter un skill

1. Copie ce dossier `_template/` vers `bank/<catégorie>/<nom-du-skill>/`.
2. Renomme `skills/nom-du-skill/` et remplace `nom-du-skill` dans `plugin.json` et dans le frontmatter du `SKILL.md` (nom en minuscules-avec-tirets, unique dans toute la banque).
3. Ajoute une entrée dans `.claude-plugin/marketplace.json` (à la racine du dépôt) :
   ```json
   {
     "name": "nom-du-skill",
     "source": "./bank/<catégorie>/<nom-du-skill>",
     "description": "Une ligne.",
     "category": "<catégorie>"
   }
   ```
4. Skill repris d'un autre auteur : ajoute son fichier de licence dans le dossier du plugin et cite-le dans la section Crédits du README.

La `description` du `SKILL.md` doit tenir sur une seule ligne : c'est elle qui déclenche le skill.
