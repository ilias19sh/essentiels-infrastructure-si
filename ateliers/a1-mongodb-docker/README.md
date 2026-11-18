# Atelier A1 - MongoDB avec Docker

Démarrer MongoDB, écrire puis relire un document, et vérifier que les données survivent à la recréation du conteneur.

## Prérequis

- Colima démarré (`colima start`).
- Le contexte Docker sélectionné est `colima` (`docker context show`).
- Docker Compose v2 (`docker compose version`).

Depuis ce dossier, le fichier `compose.yaml` publie MongoDB uniquement sur la boucle locale de l'hôte (`127.0.0.1:27017`) et conserve les données dans le volume nommé `mongo-data`. Les identifiants `root` / `example` sont fictifs et réservés à cet exercice.

## Démarrer et vérifier

```sh
docker compose config --quiet
docker compose up -d
docker compose ps
```

Attendez que MongoDB ait terminé son initialisation, puis exécutez le shell MongoDB :

```sh
docker compose exec mongo mongosh -u root -p example --authenticationDatabase admin
```

Dans `mongosh`, créez ou mettez à jour un document et relisez-le :

```javascript
use support
db.tickets.updateOne(
  { code: "T-101" },
  { $set: { sujet: "Acces au portail" } },
  { upsert: true }
)
db.tickets.findOne({ code: "T-101" })
exit
```

Résultat attendu : le document `T-101` apparaît avec le sujet `Acces au portail`. Depuis l'hôte, l'URI de connexion est `mongodb://root:example@127.0.0.1:27017/support?authSource=admin`. Dans un autre service du même projet Compose, utilisez `mongo` comme nom d'hôte.

## Vérifier la persistance

```sh
docker compose down
docker compose up -d
docker compose exec mongo mongosh -u root -p example --authenticationDatabase admin --quiet --eval 'db.getSiblingDB("support").tickets.findOne({code: "T-101"})'
```

Résultat attendu : MongoDB retourne le document `T-101` après le remplacement du conteneur. `docker compose down` conserve le volume nommé; les variables d'initialisation ne recréent pas le compte sur un volume déjà initialisé.

## Nettoyer

Arrêtez et supprimez le conteneur sans effacer les données :

```sh
docker compose down
```

Pour une remise à zéro volontaire, la commande suivante supprime également le volume et toutes les données MongoDB de ce projet :

```sh
docker compose down -v
```
