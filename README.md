# Essentiels de l'infrastructure du SI

Dépôt des ateliers d'infrastructure et des travaux pratiques. Chaque dossier contient (ou accueillera) les sources, les commandes de vérification, les résultats attendus et les étapes de nettoyage.

## Parcours

| Travail | Dossier | État |
| --- | --- | --- |
| A1 - MongoDB avec Docker | [`ateliers/a1-mongodb-docker/`](ateliers/a1-mongodb-docker/) | Réalisé |
| A2 - VM Linux et conteneur web | [`ateliers/a2-vm-linux-conteneur-web/`](ateliers/a2-vm-linux-conteneur-web/) | Conteneur vérifié avec Colima; VM à créer |
| A3 - Connecter une VM | [`ateliers/a3-reseau-vm/`](ateliers/a3-reseau-vm/) | À réaliser |
| A4 - Stockage virtuel | [`ateliers/a4-stockage-virtuel/`](ateliers/a4-stockage-virtuel/) | À réaliser |
| A5 - Nginx avec Minikube | [`ateliers/a5-nginx-minikube/`](ateliers/a5-nginx-minikube/) | À réaliser |
| B1 - Nginx avec OpenTofu | [`ateliers/b1-nginx-opentofu/`](ateliers/b1-nginx-opentofu/) | À réaliser |
| B2 - Catalogue Node.js, PostgreSQL et Redis | [`ateliers/b2-catalogue-node-postgres-redis/`](ateliers/b2-catalogue-node-postgres-redis/) | À réaliser |
| B3 - Nginx avec Puppet | [`ateliers/b3-nginx-puppet/`](ateliers/b3-nginx-puppet/) | À réaliser |
| B4 - Nginx avec Ansible | [`ateliers/b4-nginx-ansible/`](ateliers/b4-nginx-ansible/) | À réaliser |
| TP 01 - Docker et Minikube avec Node.js | [`tp/01-docker-minikube-node/`](tp/01-docker-minikube-node/) | À réaliser |
| TP 02 - Infrastructure as Code WebSolutions | [`tp/02-infrastructure-as-code-websolutions/`](tp/02-infrastructure-as-code-websolutions/) | À réaliser |
| TP 03 - OpenTofu avancé, DevSecOps | [`tp/03-opentofu-avance/devsecops/`](tp/03-opentofu-avance/devsecops/) | À réaliser |
| TP 03 - OpenTofu avancé, supervision | [`tp/03-opentofu-avance/supervision/`](tp/03-opentofu-avance/supervision/) | À réaliser |

## Environnement A1

L'atelier A1 utilise Docker Compose et MongoDB. Le moteur Docker local est fourni par Colima; les commandes `docker` et `docker compose` utilisent le contexte `colima`. Consultez le [README d'A1](ateliers/a1-mongodb-docker/README.md) pour lancer, vérifier la persistance et nettoyer le service.

Les identifiants MongoDB d'A1 sont fictifs et réservés au laboratoire. Ne réutilisez pas ces valeurs ailleurs.
