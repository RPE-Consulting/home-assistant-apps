# Changelog

## 0.11.3

- le journal écrit une ligne par visite de l'écran : la cause du réveil, le
  signal, les échecs précédents, la durée du cycle précédent, puis le code de
  la réponse et le temps mis à répondre. Une réponse que l'écran n'a pas
  attendue est signalée par un avertissement ;
- nouveau capteur « Durée de fonctionnement », en heures : le temps écoulé
  depuis le dernier démarrage de l'écran qui n'est pas un réveil de son
  sommeil (mise sous tension, flash, plantage, mise à jour). Il figure aussi
  dans la ligne de journal de chaque visite. Il faut le firmware 0.5.3.

Firmware de l'écran livré : 0.5.3.

## 0.11.2

- livre le firmware 0.5.2, qui écrit dans son journal combien de temps l'écran
  s'est déclaré occupé à chaque étape d'un affichage : c'est le seul retour de
  l'écran, et ce qui permet de savoir s'il a réellement rafraîchi.

Firmware de l'écran livré : 0.5.2.

## 0.11.1

- livre le firmware 0.5.1 de l'écran, le premier compilé par GitHub et installé
  par cette voie. Il est identique au 0.5.0 dans son comportement.

Firmware de l'écran livré : 0.5.1.

## 0.11.0

- firmware livré avec l'App : la chaîne de publication compile le firmware de
  l'écran et le range dans l'image. Au démarrage, l'App le propose à l'écran
  s'il est plus récent que celui qu'elle a déjà ; mettre l'App à jour suffit
  donc à livrer un firmware, sans envoi depuis un poste ni jeton
  supplémentaire. Un firmware envoyé à la main depuis reste prioritaire s'il
  est plus récent, et `PUT /firmware.bin` fonctionne toujours.

Firmware de l'écran livré : 0.5.0.

## 0.10.1

- l'en-tête de l'image affiche « Données de 14h46 » au lieu de « MàJ 14h46 » :
  c'est l'heure du dernier changement visible, pas celle de la dernière
  visite du C6, qui ne redessine rien quand l'image est inchangée.

## 0.10.0

- alertes sur l'écran lui-même : l'App prévient dans Home Assistant quand le
  C6 n'est pas revenu à l'heure qu'elle lui avait donnée (une marge d'un
  intervalle, entre 30 minutes et 2 heures, tolère un réveil manqué) et quand
  sa batterie passe sous `battery_alert_percent` (20 % par défaut, 0 pour
  désactiver). L'alerte est une notification persistante, retirée au retour
  de l'écran ou une fois la batterie rechargée ; `alert_notify_service`
  (par exemple `notify.mobile_app_mon_telephone`) l'envoie aussi sur un
  téléphone. `silence_alert: false` coupe l'alerte de silence. L'état est
  conservé dans `/data` : un redémarrage de l'App ne répète pas une alerte et
  n'oublie pas un écran en retard.

## 0.9.0

- capteurs publiés par MQTT : l'App déclare l'appareil `E-Paper Dashboard` et
  ses neuf capteurs par la découverte MQTT de Home Assistant, avec les mêmes
  identifiants qu'avant, et publie leurs valeurs en messages retenus. Le
  broker est celui que le Supervisor propose aux Apps (`mqtt:want`), sans
  identifiants à saisir. L'intégration `custom_components/epaper_dashboard`
  n'est plus utilisée et disparaît du dépôt : avant le premier démarrage de
  cette version, la supprimer de Home Assistant pour que les capteurs MQTT
  reprennent ses identifiants. Sans broker, rien n'est publié ;
- la durée du dernier réveil est publiée en secondes ;
- l'image affiche la batterie que le C6 vient de mesurer, et non plus la
  valeur relue dans Home Assistant, en retard d'une visite.

## 0.8.0

- rendu partiel : une panne d'un calendrier, des prévisions horaires, des
  prévisions quotidiennes ou de l'historique CO2 n'empêche plus l'image d'être
  servie. Le bloc concerné l'indique (« Calendrier indisponible », mention
  « incomplet » si seuls certains calendriers manquent, « Indisponible » sous
  les prévisions, pas de flèche de tendance CO2). Seule une panne de
  `/api/states` répond encore `503`. Les pannes sont journalisées une fois à
  leur apparition et une fois à leur résolution ;
- pré-rendu en arrière-plan toutes les `refresh_seconds` : `/frame.bin` répond
  depuis le cache sans attendre Home Assistant, ce qui raccourcit le temps
  radio du C6. La présence est mise en cache par la même boucle. Image et
  présence sont servies tant qu'elles ont moins de deux `refresh_seconds` ;
  au-delà, la requête interroge Home Assistant directement et répond `503`
  s'il est indisponible. Les bornes de journée, le bandeau batterie faible et
  `?refresh=1` déclenchent toujours un rendu immédiat ;
- diagnostics du C6 : les en-têtes `X-Wifi-Rssi`, `X-Reset-Reason`,
  `X-Wake-Cause`, `X-Consecutive-Failures` et `X-Last-Awake-Milliseconds` sont
  lus (une valeur absente ou invalide est ignorée), exposés dans
  `manifest.json` et publiés par le nouveau service
  `epaper_dashboard.update_telemetry` (intégration 0.2.0). Avec une
  intégration plus ancienne, seule la batterie est publiée ; la présence du
  service est revérifiée toutes les heures ;
- réveil par bouton (`X-Wake-Cause: button`) : l'image est servie et
  redessinée même pendant les heures calmes ou en l'absence de tous, avec le
  délai de réveil habituel de la situation ;
- la batterie et les diagnostics sont publiés après l'envoi de la réponse ;
- publication par le catalogue `home-assistant-apps` : l'image est construite,
  testée et publiée sur `ghcr.io` par l'intégration continue, pour `aarch64`
  et `amd64` (`armv7` n'est plus proposé). L'App du catalogue est une nouvelle
  App pour Home Assistant : ses options sont à saisir à l'installation ;
- options neutres, car `config.yaml` est copié dans un dépôt public :
  `presence_entities` est vide par défaut, les pièces s'appellent
  « Chambre 1 » et « Chambre 2 » (`room_1_label`, `room_2_label`) et leurs
  entités se règlent par `room_1_temperature`, `room_1_humidity`,
  `room_2_temperature` et `room_2_humidity`. Les anciens noms `bedroom_*`
  sont encore lus. Nouvelle option `current_weather` pour l'entité météo ;
- version de l'App écrite uniquement dans `config.yaml` et
  `epaper_renderer/__init__.py`, vérifiée par les tests ;
- intégration continue GitHub Actions des tests du renderer (Python 3.9 et
  3.13).

## 0.7.0

- batterie faible : sous `battery_low_millivolts` (3500 mV par defaut, au lieu
  de 3300), l'App sert desormais une image avec un bandeau « Batterie faible »
  au lieu de repondre `204`, puis espace les reveils de
  `battery_low_refresh_seconds`. L'ancien seuil etait egal a la coupure radio
  du firmware et n'etait donc jamais atteint : l'ecran se figeait sans
  prevenir. Une installation existante garde sa valeur enregistree : la passer
  a 3500 dans les options ;
- mise a jour sans fil du firmware : `PUT /firmware.bin` (jeton dedie
  `firmware_upload_token`) enregistre une image, annoncee au C6 par l'en-tete
  `X-Firmware-Version` et servie par `GET /firmware.bin` ;
- `manifest.json` indique la version proposee et celle annoncee par le C6 ;
- `?battery_low=1` sur `/preview.png` pour controler le bandeau ;
- delai de 30 s sur les connexions inactives.

## 0.6.3

- nouvelles icônes météo monochromes avec une silhouette de nuage pleine ;
- variantes distinctes et lisibles pour la pluie, la forte pluie et la grêle ;
- géométrie compacte évitant le chevauchement avec les températures.

## 0.6.2

- rattachement au jour courant des événements toute la journée ou sur plusieurs
  jours tant qu'ils sont en cours.

## 0.6.1

- politique de reveil dynamique transmise au firmware par
  `X-Next-Wake-Seconds` et `X-Update-Reason` ;
- suspension des mises a jour de 23h a 7h et lorsque tous les occupants sont
  absents, avec comportement fail-open si une presence est inconnue ;
- rafraichissement force aux horaires configures de debut et de fin de journee,
  meme lorsque tout le monde est absent ;
- conservation d'une borne en attente apres un `503` et acquittement apres la
  premiere frame servie pour eviter les rafraichissements multiples ;
- report des mises a jour lorsque la batterie est critique et repli borne si
  Home Assistant est indisponible ;
- heure de derniere mise a jour reelle affichee dans l'en-tete ;
- cache semantique et hysterese batterie evitant les refreshs e-paper sans
  changement visible ;
- publication batterie decouplee du rendu et traitee en best effort.

## 0.5.0

- publication de la batterie par le service `epaper_dashboard.update_battery` ;
- prise en charge de deux véritables entités enregistrées par l'intégration
  E-Paper Dashboard, avec identifiants uniques et restauration après
  redémarrage de Home Assistant ;
- journalisation explicite de la tension et du pourcentage transmis ;
- repli temporaire vers les anciens états REST tant que l'intégration n'est pas
  configurée.

## 0.4.1

- partage 50/50 entre le calendrier et les informations ;
- nouvelle mise en page de la qualite de l'air avec tendance CO2 et conseil
  d'aeration ;
- temperature et humidite du salon et de deux chambres ;
- telemetrie de batterie publiee dans Home Assistant et affichee sur l'ecran ;
- lecture native des calendriers et des previsions meteo Home Assistant ;
- marges et alignements adaptes a l'ecran e-paper 800x480.
