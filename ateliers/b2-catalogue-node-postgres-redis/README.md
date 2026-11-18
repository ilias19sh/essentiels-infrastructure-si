# Atelier B2 - Catalogue Node.js, PostgreSQL et Redis

Construire une petite API Node.js puis décrire avec OpenTofu un réseau Docker, PostgreSQL, Redis et l'API. Vérifier la santé des dépendances ainsi que la lecture initiale depuis PostgreSQL et la lecture suivante depuis Redis.

## Prérequis

- Docker CLI, OpenTofu et Node.js non requis sur l'hôte si la construction se fait via Docker.
- Colima démarré avec le contexte Docker `colima`.
- Fichiers versionnés de ce dossier. Le mot de passe de `terraform.tfvars.example` est un exemple local uniquement; ne jamais y mettre un vrai secret.

Pour le fournisseur Docker, transmettre explicitement le socket de Colima :

```sh
export DOCKER_HOST="$(docker context inspect colima --format '{{.Endpoints.docker.Host}}')"
```

## Construire et initialiser

Depuis ce dossier :

```sh
docker build -t infra-si-catalogue-api:lab ./api
docker image inspect --format '{{.Id}}' infra-si-catalogue-api:lab
```

Copier `terraform.tfvars.example` vers `terraform.tfvars`, puis remplacer `api_image_id` par l'identifiant complet renvoyé par Docker. Changer aussi le mot de passe d'exemple pour un secret réservé à ce laboratoire. Le fichier `terraform.tfvars` et l'état OpenTofu peuvent contenir des secrets et ne doivent pas être publiés.

```sh
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu fmt -check
tofu validate
tofu plan -out=catalogue.tfplan
tofu show catalogue.tfplan
tofu apply catalogue.tfplan
tofu output api_url
```

Après `tofu init`, versionner `.terraform.lock.hcl`. Ne pas versionner `.terraform/`, les fichiers d'état ou les plans enregistrés.

## Vérifier l'API et le cache

```sh
curl -fsS http://127.0.0.1:3000/health
curl -fsS http://127.0.0.1:3000/products
curl -fsS http://127.0.0.1:3000/products
```

Sur une pile neuve, `/health` doit répondre avec PostgreSQL et Redis à `ok`; le premier appel `/products` indique `source: postgresql`, et le second, dans les 30 secondes, indique `source: redis` avec les mêmes produits. Le port hôte par défaut est `3000`; s'il est occupé, fixer `api_port` dans le fichier local `terraform.tfvars` et utiliser l'URL retournée par `tofu output api_url`.

Les données PostgreSQL résident dans un volume nommé; le cache Redis a également un volume. Pour tester la persistance, insérer un produit, redémarrer PostgreSQL et relire le catalogue après expiration du cache :

```sh
docker exec infra-si-catalogue-db psql -U catalogue -d catalogue -c "INSERT INTO products VALUES (3, 'Ecran') ON CONFLICT DO NOTHING;"
docker restart infra-si-catalogue-db
```

## Nettoyer

Les volumes sont gérés par OpenTofu et seront supprimés lors de la destruction; sauvegarder auparavant les données à conserver.

```sh
tofu plan -destroy -out=catalogue-destroy.tfplan
tofu show catalogue-destroy.tfplan
tofu apply catalogue-destroy.tfplan
```

Supprimer ensuite le fichier local `terraform.tfvars` après usage.

## État de réalisation

Le build Docker a réussi. Une pile temporaire lancée avec Docker CLI (sans OpenTofu) a répondu `200` à `/health`; deux appels `/products` ont renvoyé respectivement `source: postgresql` et `source: redis`. Le port `3000` était déjà utilisé sur l'hôte, donc la publication a été vérifiée sur `13000`. Les conteneurs, volumes et réseau temporaires ont été supprimés. Le plan et l'application OpenTofu restent à exécuter; ils ne sont pas présentés comme vérifiés.
