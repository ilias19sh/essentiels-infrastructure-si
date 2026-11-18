# Atelier A2 - VM Linux et conteneur web

Créer une VM Ubuntu Server, lui attribuer des ressources, puis démarrer Nginx dans un conteneur. L'atelier distingue l'adresse du système invité et le port publié par Docker.

## Prérequis

- Un hyperviseur compatible avec l'architecture du poste et l'ISO Ubuntu choisie.
- Ubuntu Server 24.04 LTS. Sur le poste Apple Silicon utilisé pour préparer ce dépôt (`aarch64`), choisir une image ARM64 et vérifier sa prise en charge par l'hyperviseur.
- Docker Engine dans l'invité pour observer les deux niveaux, ou le moteur Docker de l'hôte pour la variante locale ci-dessous.

## Créer la VM

Dans VirtualBox, créer `UbuntuDev` avec les réglages suivants :

| Réglage | Valeur |
| --- | --- |
| Système | Linux / Ubuntu Server 24.04 LTS, ISO adaptée à l'architecture |
| Processeurs | 2 processeurs virtuels si possible |
| Mémoire | Au moins 2 Go |
| Disque | VDI dynamique de 20 Go |
| Réseau | Adaptateur 1 en NAT |
| Installation | Activer OpenSSH Server si un accès distant est souhaité |

Après l'installation et le redémarrage, relever les interfaces et la route par défaut depuis la console de la VM :

```sh
ip -br addr
ip route
```

## Démarrer Nginx dans la VM

Dans UbuntuDev, installer Docker Engine en suivant la documentation officielle Docker pour Ubuntu, puis vérifier le moteur :

```sh
docker version
```

Démarrer le conteneur et vérifier sa configuration Nginx :

```sh
docker run -d --name web-vm -p 8088:80 nginx:1.28-alpine
docker ps
docker exec web-vm nginx -t
```

Dans la VM, ouvrir `http://127.0.0.1:8088` ou exécuter `curl -fsS http://127.0.0.1:8088`. Le résultat attendu est la page d'accueil Nginx et un test de configuration réussi.

## Accès depuis l'hôte

Avec le NAT seul, créer dans VirtualBox une redirection TCP du port hôte `8088` vers le port invité `8088`, puis ouvrir `http://127.0.0.1:8088` depuis l'hôte. Avec un réseau privé hôte ou un pont autorisé, relever l'adresse de la VM avec `ip -br addr` et ouvrir `http://ADRESSE_DE_LA_VM:8088` depuis un poste du même réseau.

L'adresse de la VM est celle de son interface réseau. Le port `8088` est publié par Docker vers le port `80` du conteneur; ce ne sont pas la même adresse ni le même niveau réseau.

## Variante avec Colima sur l'hôte

Si Docker Engine n'est pas installé dans la VM, le scénario Nginx peut être testé sur le moteur de l'hôte. Cette variante valide le conteneur et la publication de port, mais ne remplace pas la création de la VM.

```sh
docker context show
docker run -d --name web-vm -p 127.0.0.1:8088:80 nginx:1.28-alpine
docker ps
docker exec web-vm nginx -t
curl -fsS http://127.0.0.1:8088
```

Le contexte attendu pour ce poste est `colima`. La page Nginx doit être renvoyée par `curl`.

## Nettoyer

Supprimer le conteneur après les vérifications, que Docker tourne dans la VM ou sur l'hôte :

```sh
docker rm -f web-vm
```

Éteindre UbuntuDev depuis le système invité quand le travail est terminé.

## État de réalisation

La variante du conteneur sur Colima est vérifiée. La VM n'a pas été créée sur le poste de préparation : les outils `VBoxManage` et `multipass` n'y sont pas disponibles. Il reste à installer/configurer un hyperviseur compatible avec l'hôte Apple Silicon, créer UbuntuDev avec les réglages ci-dessus, puis consigner son adresse et la vérification d'accès depuis l'hôte.
