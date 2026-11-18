# TP 01 - Docker et Minikube avec Node.js

## Objectif

Construire une image Node.js et exposer le même service HTTP avec Docker puis Kubernetes. L'application répond avec le même texte à la route `/` et expose `/health` pour les contrôles de santé.

## Préparation de l'image

Depuis ce dossier, le Dockerfile part de `node:24-alpine`, copie uniquement `server.js` et lance Node avec l'utilisateur non privilégié `node`. L'application écoute sur `0.0.0.0:3000`, ce qui permet au moteur de conteneur de joindre le processus.

```sh
docker context show
docker build -t infra-si-tp01-node:1.0 .
```

Sur ce poste, le moteur Docker est fourni par Colima et le contexte attendu est `colima`.

## Vérification avec Docker

```sh
docker run -d --name tp01-node -p 127.0.0.1:8081:3000 infra-si-tp01-node:1.0
curl -fsS http://127.0.0.1:8081/
curl -fsS http://127.0.0.1:8081/health
docker rm -f tp01-node
```

La route `/` doit retourner exactement `TP 01 - Service Node.js operationnel`; `/health` retourne `ok`. La commande de suppression nettoie le conteneur après le test.

## Vérification avec Minikube

Démarrer un profil distinct et construire la même image directement dans le cluster afin que Kubernetes la trouve sans registre distant :

```sh
minikube start -p infra-si-node --driver=docker
minikube -p infra-si-node image build -t infra-si-tp01-node:1.0 .
minikube -p infra-si-node kubectl -- apply -f k8s/app.yaml
minikube -p infra-si-node kubectl -- rollout status deployment/tp01-node --timeout=120s
minikube -p infra-si-node kubectl -- get pods,services
```

Dans un terminal, ouvrir un tunnel local :

```sh
minikube -p infra-si-node kubectl -- port-forward service/tp01-node 8082:3000
```

Dans un autre terminal, comparer la réponse HTTP avec celle de Docker :

```sh
curl -fsS http://127.0.0.1:8082/
curl -fsS http://127.0.0.1:8082/health
```

La réponse `/` attendue est identique à celle du conteneur Docker : `TP 01 - Service Node.js operationnel`. Le Deployment utilise le même tag d'image, le même port et la même application; le Service fournit un accès stable au Pod.

## Nettoyage

Arrêter `port-forward` avec Ctrl+C, supprimer les ressources et arrêter le profil :

```sh
minikube -p infra-si-node kubectl -- delete -f k8s/app.yaml
minikube delete -p infra-si-node
```

## Résultats

La construction Docker a réussi. Le conteneur a retourné `TP 01 - Service Node.js operationnel` sur `/` et `ok` sur `/health`; il a ensuite été supprimé.

Le manifeste Kubernetes reprend le même serveur, l'image, le port et les routes de santé. La procédure Minikube ci-dessus est fournie pour reproduire le test dans Kubernetes; Minikube n'étant pas installé sur le poste, le Pod et la réponse HTTP Kubernetes n'ont pas été vérifiés ici.
