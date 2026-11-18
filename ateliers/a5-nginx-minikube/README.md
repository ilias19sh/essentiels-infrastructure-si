# Atelier A5 - Nginx avec Minikube

Déployer Nginx dans un cluster local Minikube, observer le Deployment et le Service, puis vérifier qu'un Pod supprimé est recréé.

## Prérequis

- Docker Engine actif et accessible par le client Docker.
- Minikube installé.
- Le manifeste [nginx.yaml](k8s/nginx.yaml).

Sur le poste de préparation, le moteur Docker est fourni par Colima. Les commandes Minikube ci-dessous n'ont pas encore été exécutées ici.

## Démarrer et vérifier

```sh
minikube start -p infra-si --driver=docker
minikube -p infra-si kubectl -- get nodes
minikube -p infra-si kubectl -- apply -f k8s/nginx.yaml
minikube -p infra-si kubectl -- rollout status deployment/nginx --timeout=120s
minikube -p infra-si kubectl -- get pods,services
```

Le résultat attendu est un nœud prêt, un Pod Nginx `Running` et le Service `nginx` de type `ClusterIP`.

Pour accéder au service, laisser la commande suivante active dans un terminal :

```sh
minikube -p infra-si kubectl -- port-forward service/nginx 8090:80
```

Dans un autre terminal, vérifier la réponse :

```sh
curl -fsS -o /dev/null -w 'HTTP %{http_code}\n' http://127.0.0.1:8090
```

Résultat attendu : `HTTP 200`.

## Observer le remplacement d'un Pod

Dans un autre terminal, relever le nom du Pod, le supprimer, puis attendre qu'un nouveau Pod atteigne l'état prêt :

```sh
minikube -p infra-si kubectl -- get pods
minikube -p infra-si kubectl -- delete pod NOM_DU_POD
minikube -p infra-si kubectl -- get pods
```

Le Deployment maintient une réplique désirée; le nom du Pod recréé sera différent.

## Nettoyer

Arrêter `port-forward` avec Ctrl+C, supprimer le profil dédié et son cluster local :

```sh
minikube delete -p infra-si
```

## État de réalisation

Le manifeste et les commandes sont versionnés. Le cluster, l'état des Pods et la réponse HTTP restent à vérifier sur un poste où Minikube est installé.
