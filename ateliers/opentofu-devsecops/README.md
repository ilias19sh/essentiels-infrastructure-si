# Atelier - Plateforme DevSecOps avec OpenTofu

Déployer localement Gitea, Jenkins et SonarQube Community Build avec PostgreSQL. OpenTofu gère les images, le réseau, les volumes et les conteneurs.

## Prérequis

- Docker en mode conteneurs Linux et OpenTofu.
- Environ 8 Go de mémoire disponibles pour le moteur Docker.
- Ports locaux 3000, 5432, 8080 et 9000 libres.
- Pour SonarQube, sur le moteur Linux: `vm.max_map_count >= 524288` et `fs.file-max >= 131072`.

Avec Colima, démarrer le moteur et exporter son socket dans le shell utilisé pour OpenTofu:

```sh
colima start --memory 8
export DOCKER_HOST="$(docker context inspect colima --format '{{.Endpoints.docker.Host}}')"
docker version
tofu version
```

Contrôler les limites du noyau qui exécute Docker:

```sh
docker run --rm alpine:3.22 cat /proc/sys/vm/max_map_count /proc/sys/fs/file-max
```

Ne modifier ces paramètres que sur une VM Linux de laboratoire et uniquement s'ils sont insuffisants. Docker Desktop peut ne pas permettre de les régler; le support recommande alors une VM Ubuntu dédiée suffisamment dimensionnée.

## Déployer

Depuis ce répertoire:

```sh
tofu init
tofu fmt -check
tofu validate
tofu plan -out=devops.tfplan
tofu show devops.tfplan
tofu apply devops.tfplan
docker ps -a --filter name=devops-
```

Les interfaces sont liées à la boucle locale:

- Gitea: `http://localhost:3000`; sélectionner SQLite et créer un dépôt de test.
- Jenkins: `http://localhost:8080`; le mot de passe initial est lisible dans le conteneur, sans le publier:

```sh
docker exec devops-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

- SonarQube: `http://localhost:9000`; attendre l'état `UP`, puis définir un nouveau mot de passe administrateur.

La configuration réserve le compte et le mot de passe PostgreSQL `sonar` / `sonar-lab-only` à ce laboratoire. Ils ne conviennent pas à un usage réel. L'état OpenTofu contient les paramètres sensibles; ne jamais publier état ni plans.

## Vérifier

```sh
curl -fsS http://localhost:9000/api/system/status
docker exec devops-postgres pg_isready -h 127.0.0.1 -U sonar -d sonar
docker logs --tail 60 devops-sonar
tofu plan
```

Résultats attendus: SonarQube indique `UP`, PostgreSQL accepte les connexions, les trois interfaces répondent et `tofu plan` ne propose aucun changement. Redémarrer Gitea et confirmer que le dépôt créé existe toujours pour vérifier la persistance.

## Nettoyer

Les volumes sont gérés par OpenTofu; sauvegarder les données utiles avant leur suppression.

```sh
tofu plan -destroy -out=devops-destroy.tfplan
tofu show devops-destroy.tfplan
tofu apply devops-destroy.tfplan
docker ps -a --filter name=devops-
```

## État de réalisation

Les ressources et procédures sont déclarées. Le plan, le déploiement, l'accès aux interfaces et le nettoyage restent à exécuter sur un moteur Docker satisfaisant les prérequis; ils ne sont pas présentés comme des résultats observés.