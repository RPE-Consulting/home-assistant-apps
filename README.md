# RPE Consulting Home Assistant Apps

Catalogue des apps Home Assistant personnelles de RPE Consulting. Home Assistant lit ce dépôt pour
proposer les apps et détecter leurs mises à jour.

Le dépôt est public, mais il ne contient que de la configuration : les images des apps sont privées
et hébergées sur `ghcr.io`. Il faut donc faire deux choses dans Home Assistant : ajouter le
catalogue, puis déclarer le registre privé.

Le catalogue est vide pour l'instant : chaque app y arrive avec sa première image publiée.

## Ajouter le catalogue dans Home Assistant

1. Ouvrir **Paramètres > Apps > App store**.
2. Ouvrir le menu **⋮** en haut à droite, puis **Dépôts**.
3. Ajouter l'URL `https://github.com/RPE-Consulting/home-assistant-apps`.
4. Fermer la fenêtre, puis recharger l'App store (menu **⋮ > Rechercher des mises à jour**) : les
   apps du catalogue apparaissent dans une section à son nom.

## Déclarer le registre privé `ghcr.io`

Sans cette étape, l'installation d'une app échoue : Home Assistant n'a pas le droit de télécharger
son image.

1. Sur GitHub, créer un jeton d'accès personnel **classique** (Settings > Developer settings >
   Personal access tokens > Tokens (classic)) avec la seule permission `read:packages`. Les jetons
   à granularité fine ne donnent pas accès aux paquets. Le compte doit pouvoir lire les paquets de
   l'organisation `RPE-Consulting`.
2. Dans Home Assistant, ouvrir **Paramètres > Apps > App store**, menu **⋮**, puis **Registres**.
3. Ajouter un registre :
   - Registre : `ghcr.io`
   - Nom d'utilisateur : le nom du compte GitHub qui a créé le jeton
   - Mot de passe : le jeton

Le jeton ne sert qu'à lire les images. Il reste dans Home Assistant et ne doit jamais apparaître
dans ce dépôt.

## Règle du dépôt

**Un dossier par app, écrit par la CI de l'app, jamais à la main.**

- Chaque app a un dossier à la racine, dont le nom est le `slug` de l'app.
- Ce dossier est écrit par le pipeline du dépôt de l'app, quand celui-ci publie une nouvelle image.
  La source de vérité est le dépôt de l'app : une modification faite ici à la main serait écrasée à
  la publication suivante.
- Le dossier contient la configuration de l'app (`config.yaml` et ses fichiers d'accompagnement),
  jamais son code ni de quoi construire son image.

À chaque push et à chaque pull request, un workflow vérifie que chaque `<dossier>/config.yaml` :

- est un YAML valide ;
- contient `name`, `version`, `slug`, `arch` et `image` ;
- a un `slug` identique au nom de son dossier.

Pour lancer la même vérification en local :

```sh
ruby .github/scripts/validate_catalog.rb .
```

## Ce qui ne doit jamais figurer ici

Le dépôt est public. Rien de ce qui suit ne doit y entrer, y compris dans l'historique Git :

- des secrets ou des jetons, quels qu'ils soient ;
- des prénoms ;
- des noms de pièces ou d'entités personnelles (`sensor.chambre_de_…`, par exemple) dans les
  valeurs par défaut des `options`.

Les valeurs par défaut des `options` doivent rester génériques ou vides : les valeurs réelles se
saisissent dans Home Assistant, dans la configuration de l'app.
