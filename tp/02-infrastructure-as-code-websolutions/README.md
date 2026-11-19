# TP 02 - Infrastructure as Code WebSolutions

## Architecture

Le scénario local contient trois services : Nginx reçoit les requêtes HTTP, l'API Node.js fournit `/` et `/health`, et PostgreSQL est interrogé par le contrôle de santé de l'API. Les ports de l'API et de PostgreSQL restent internes au réseau Docker; seul Nginx publie `127.0.0.1:8080`.

OpenTofu crée le réseau Docker `websolutions-test` et le volume PostgreSQL. Ansible rend la configuration de reverse proxy Nginx. GitHub Actions teste l'application avant de construire et déployer une version identifiée par le SHA du commit dans un runner éphémère.

## Prérequis et démarrage local

- Docker Engine avec Compose v2; sur ce poste macOS, Colima fournit le moteur.
- Node.js 24 et npm pour lancer les tests.
- OpenTofu 1.9 et Ansible Core 2.17.14 pour rejouer toutes les étapes.

Avec Colima, exposer au fournisseur Docker le socket utilisé par le contexte :

```sh
export DOCKER_HOST="$(docker context inspect colima --format '{{.Endpoints.docker.Host}}')"
```

Installer les dépendances et lancer les tests :

```sh
npm ci --prefix app
npm test --prefix app
```

Copier les exemples de paramètres locaux. Le mot de passe de `.env.example` est fictif et réservé au laboratoire; ne pas le réutiliser. `.env`, `terraform.tfvars`, l'état et les plans sont ignorés par Git.

```sh
cp .env.example .env
cp terraform.tfvars.example terraform.tfvars
```

## Provisionner les ressources

OpenTofu fournit le réseau externe et le volume utilisés par Compose. Examiner le plan avant de l'appliquer :

```sh
tofu init
tofu fmt -check
tofu validate
tofu plan -out=infra.tfplan
tofu show infra.tfplan
tofu apply infra.tfplan
tofu output
```

Après `tofu init`, conserver `.terraform.lock.hcl` pour figer la version du fournisseur. Ne pas publier `.terraform/`, les fichiers `.tfstate` ni `infra.tfplan`.

## Configurer Nginx avec Ansible

L'inventaire cible `localhost` en connexion locale. Ansible rend `ansible/templates/default.conf.j2` dans `nginx/default.conf`, monté en lecture seule par le conteneur Nginx.

```sh
ansible-playbook -i ansible/inventory.ini ansible/configure.yml --diff
ansible-playbook -i ansible/inventory.ini ansible/configure.yml --diff
```

La première application crée ou met à jour le fichier. La seconde doit afficher `changed=0` si le fichier n'a pas été modifié. Pour tester la convergence, changer temporairement l'upstream `app:3000` dans le template, relancer le playbook, puis restaurer `app:3000` et le relancer pour remettre la configuration attendue.

## Déployer et vérifier

La pile Compose utilise les noms des ressources créées par OpenTofu. `APP_VERSION` identifie l'image; localement, la valeur par défaut est `local`.

```sh
docker compose config --quiet
docker compose up --build -d --wait --wait-timeout 120
docker compose ps
curl -fsS http://127.0.0.1:8080/health
curl -fsS http://127.0.0.1:8080/
```

Résultats attendus : `/health` répond avec `status: ok` et `database: ok`; `/` renvoie le nom du service et sa version. L'image construite par le pipeline est étiquetée avec le SHA Git, et le même SHA est exposé dans la réponse de l'API.

## Pipeline et test bloquant

Le workflow `.github/workflows/websolutions.yml` lance `npm ci` et `npm test` dans le job `test`. Le job `deploy-test` dépend de `test` avec `needs: test`; un échec des tests empêche donc la construction et le déploiement. Sur un push vers `main`, le job de déploiement applique OpenTofu, exécute deux fois Ansible, démarre Compose, puis vérifie `/health` et `/`. Il détruit ensuite les services, le réseau et le volume temporaires du runner.

Pour démontrer le blocage, modifier temporairement une valeur attendue dans `app/test/server.test.js`, exécuter `npm test`, puis pousser cette modification sur une branche de test : le job `test` échoue et `deploy-test` est ignoré. Restaurer l'assertion, rejouer les tests et fusionner seulement la version réussie. Dans le workflow réel, relever l'exécution CI, le SHA de l'image et le retour HTTP avant de les présenter comme preuves.

## Nettoyer l'environnement local

Vérifier le plan de destruction avant de supprimer les ressources. Compose retire les conteneurs; OpenTofu possède le réseau et le volume PostgreSQL.

```sh
docker compose down
tofu plan -destroy -out=destroy.tfplan
tofu show destroy.tfplan
tofu apply destroy.tfplan
```

Le volume contient les données PostgreSQL du laboratoire. En faire une sauvegarde si nécessaire avant la destruction. Pour un redémarrage ultérieur, rejouer `tofu apply`, puis Ansible et Compose.