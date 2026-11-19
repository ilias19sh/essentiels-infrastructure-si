# Atelier - Supervision locale avec OpenTofu

Déployer une application Node.js et collecter ses métriques HTTP avec Prometheus et ses journaux JSON avec Alloy vers Loki. Grafana interroge les deux sources.

## Prérequis

- Docker en mode conteneurs Linux et OpenTofu.
- Ports locaux 3000, 3100, 8080 et 9090 libres.
- Les fichiers `app.js`, `prometheus.yml`, `loki.yaml` et `config.alloy` de ce répertoire.

Avec Colima, démarrer le moteur et exporter son socket dans le shell utilisé pour OpenTofu:

```sh
colima start
export DOCKER_HOST="$(docker context inspect colima --format '{{.Endpoints.docker.Host}}')"
docker version
tofu version
```

## Déployer

Depuis ce répertoire:

```sh
tofu init
tofu fmt -check
tofu validate
tofu plan -out=monitoring.tfplan
tofu show monitoring.tfplan
tofu apply monitoring.tfplan
docker ps -a --filter name=monitoring-
```

Les ports des interfaces sont liés à la boucle locale: application `http://localhost:8080`, Prometheus `http://localhost:9090`, Grafana `http://localhost:3000` et Loki `http://localhost:3100`. Alloy n'expose aucun port. Les fichiers de configuration sont montés en lecture seule; Node et Alloy partagent le volume des journaux, et Alloy conserve son curseur dans un volume séparé.

## Vérifier les signaux

Envoyer plusieurs requêtes métier et une requête qui produit une erreur HTTP:

```sh
curl -i http://localhost:8080/
curl -i http://localhost:8080/introuvable
curl -fsS http://localhost:8080/metrics
```

`/metrics` n'incrémente pas le compteur métier. Vérifier la cible `node` à l'état `UP` dans `http://localhost:9090/targets`, puis vérifier `http://localhost:3100/ready`.

Dans Grafana, se connecter avec `admin` / `admin` sur une installation neuve et remplacer le mot de passe de laboratoire. Ajouter les sources de données suivantes depuis le conteneur Grafana:

- Prometheus: `http://prometheus:9090`
- Loki: `http://loki:3100`

Dans Explore, lancer `up{job="node"}` et `http_requests_total` pour Prometheus, puis `{job="node"}` pour Loki. Choisir une période récente et générer du trafic si nécessaire. Comparer les échantillons du compteur avec les événements du journal sur la même période.

Si les journaux n'arrivent pas, inspecter d'abord le fichier et les collecteurs:

```sh
docker exec monitoring-node tail -n 5 /logs/http.log
docker logs --tail 60 monitoring-alloy
docker logs --tail 60 monitoring-loki
```

Si Loki refuse d'écrire, vérifier que le volume de laboratoire est neuf ou qu'il appartient à l'UID/GID 10001 utilisé par Loki. Ne pas supprimer un volume contenant des données à conserver.

## Nettoyer

Sauvegarder les données utiles avant de supprimer les ressources et volumes:

```sh
tofu plan -destroy -out=monitoring-destroy.tfplan
tofu show monitoring-destroy.tfplan
tofu apply monitoring-destroy.tfplan
docker ps -a --filter name=monitoring-
```

## État de réalisation

Les sources et procédures sont préparées. Les images, le déploiement, les contrôles Prometheus/Loki et les captures de Grafana restent à exécuter sur un moteur Docker; aucune preuve d'exécution n'est revendiquée.