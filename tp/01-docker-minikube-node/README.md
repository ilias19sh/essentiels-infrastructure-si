# TP 01 - Docker et Minikube avec Node.js

## Objectif et prérequis

On exécute une application Node.js avec Docker, puis on déploie la même image dans Kubernetes avec Minikube. Node.js est fourni par l'image `node:24-alpine`; il n'a pas besoin d'être installé sur le poste.

Les commandes de cet atelier utilisent le profil Minikube `intro-docker` et le moteur Docker de Colima sur macOS.

```sh
docker version
minikube version
```

## Construire et exécuter l'application

`server.js` utilise le module HTTP intégré à Node.js et écoute sur `0.0.0.0:3000`, donc le processus est accessible depuis le réseau du conteneur. Le Dockerfile copie ce serveur dans l'image et le démarre avec l'utilisateur `node`. Le `.dockerignore` limite le contexte aux deux fichiers nécessaires à la construction.

Depuis ce dossier, construire l'image et lancer le conteneur :

```sh
docker build -t hello-node:1.0 .
docker run -d --name hello-node -p 127.0.0.1:8080:3000 hello-node:1.0
docker ps --filter name=hello-node
curl -fsS http://127.0.0.1:8080
```

La sortie HTTP attendue est :

```text
Hello, Docker and Minikube from Node.js!
```

La publication relie le port `8080` de l'hôte au port `3000` du conteneur. Si le port hôte `8080` est occupé, utiliser `8081` à la fois dans `docker run` et dans l'URL de `curl`.

Après la vérification, supprimer le conteneur; l'image reste disponible localement :

```sh
docker rm -f hello-node
```

## Déployer avec Minikube

Démarrer le cluster, charger l'image construite dans le profil et vérifier qu'elle est présente :

```sh
minikube start -p intro-docker --driver=docker
minikube -p intro-docker image load hello-node:1.0
minikube -p intro-docker image ls
```

Appliquer [deployment.yaml](deployment.yaml), qui contient le Deployment et le Service :

```sh
minikube -p intro-docker kubectl -- apply -f deployment.yaml
minikube -p intro-docker kubectl -- rollout status deployment/hello-node
minikube -p intro-docker kubectl -- get pods,services
```

Le Deployment demande une réplique et utilise `imagePullPolicy: IfNotPresent` afin d'utiliser l'image chargée localement. Le Service sélectionne les Pods étiquetés `app: hello-node`, reçoit sur le port `8080` et transmet au port `3000` du Pod. Son NodePort est `30007`.

Pour accéder au service, essayer d'abord l'URL fournie par Minikube :

```sh
minikube -p intro-docker service hello-node --url
```

Si cette URL n'est pas accessible depuis l'hôte, arrêter le tunnel et utiliser le transfert de port suivant; le laisser actif pendant le test :

```sh
minikube -p intro-docker kubectl -- port-forward service/hello-node 8080:8080
```

Dans un autre terminal :

```sh
curl -fsS http://127.0.0.1:8080
```

Le message attendu est le même que sous Docker : `Hello, Docker and Minikube from Node.js!`.

## Analyse

1. Node.js n'est pas installé sur le poste parce que l'image Docker contient le runtime Node.js et que le conteneur exécute `server.js` avec ce runtime.
2. Docker rend le service accessible en publiant le port hôte `8080` vers le port `3000` du conteneur. Dans Kubernetes, le Service fournit un point d'accès stable vers les Pods et expose le port `8080`; Minikube fournit l'accès depuis l'hôte.
3. Le conteneur lancé avec `docker run` a un cycle de vie individuel. Le Deployment maintient l'état désiré et recrée un Pod si celui-ci disparaît.
4. Après le déploiement, relever `READY` avec `kubectl get pods`, le port `8080` et le NodePort `30007` avec `kubectl get services`, puis noter le message retourné par `curl`.

## Nettoyer

Arrêter `port-forward` ou le tunnel Minikube avec Ctrl+C, supprimer les ressources puis le profil :

```sh
minikube -p intro-docker kubectl -- delete -f deployment.yaml
minikube delete -p intro-docker
```

## Résultats observés

La construction Docker a réussi avec le tag `hello-node:1.0`. Le conteneur a répondu `Hello, Docker and Minikube from Node.js!` sur `http://127.0.0.1:8080`, puis a été supprimé. Minikube n'est pas installé sur le poste; l'état `READY` du Pod et la réponse HTTP Kubernetes restent à relever lors de l'exécution du cluster.
