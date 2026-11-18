# Atelier B1 - Déployer Nginx avec OpenTofu

Décrire une image et un conteneur Nginx avec OpenTofu, examiner le plan, vérifier le service et détruire les ressources gérées.

## Prérequis

- OpenTofu et Docker CLI installés.
- Colima démarré (`colima start`) et contexte Docker `colima`.
- Fichiers `versions.tf` et `main.tf` de ce dossier.

Le fournisseur Docker doit joindre le socket de Colima. Dans le shell utilisé pour OpenTofu :

```sh
export DOCKER_HOST="$(docker context inspect colima --format '{{.Endpoints.docker.Host}}')"
tofu version
docker version
```

## Initialiser et appliquer

```sh
tofu init
tofu fmt -check
tofu validate
tofu plan -out=nginx.tfplan
tofu show nginx.tfplan
tofu apply nginx.tfplan
tofu output nginx_url
docker ps --filter name=infra-si-nginx
```

`tofu init` génère `.terraform.lock.hcl`; versionner ce fichier après l'initialisation pour figer la sélection du fournisseur. Les fichiers de plan et l'état local ne doivent pas être publiés.

Résultats attendus après application : le conteneur `infra-si-nginx` est présent, `tofu output nginx_url` affiche `http://127.0.0.1:8080`, et un nouvel `tofu plan` ne propose aucun changement si rien n'a été modifié.

```sh
curl -fsS -o /dev/null -w 'HTTP %{http_code}\n' http://127.0.0.1:8080
tofu plan
```

## Nettoyer

Examiner la destruction avant de l'appliquer :

```sh
tofu plan -destroy -out=nginx-destroy.tfplan
tofu show nginx-destroy.tfplan
tofu apply nginx-destroy.tfplan
docker ps -a --filter name=infra-si-nginx
```

Le résultat attendu est l'absence du conteneur. L'image reste en cache grâce à `keep_locally = true`.

## État de réalisation

Les sources et les commandes sont préparées; OpenTofu et le fournisseur Docker ne sont pas installés sur le poste de préparation. Plan, application, accès HTTP et destruction restent à exécuter. Ne pas présenter les résultats attendus comme des résultats observés.
