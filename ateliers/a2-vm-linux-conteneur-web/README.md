# Atelier A2 - VM Linux et conteneur web

Dans cet atelier, on prépare Ubuntu Server comme système invité, puis on démarre Nginx dans un conteneur. Le but est aussi de distinguer l'adresse de la VM du port publié par Docker.

## Prérequis

- Un hyperviseur compatible avec l'architecture du poste et l'ISO Ubuntu choisie.
- Ubuntu Server 24.04 LTS. Sur le poste Apple Silicon utilisé pour préparer ce dépôt (`aarch64`), choisir une image ARM64 et vérifier sa prise en charge par l'hyperviseur.
- Docker Engine dans l'invité pour observer les deux niveaux, ou le moteur Docker de l'hôte pour la variante locale ci-dessous.

## Configuration de la VM

La VM UbuntuDev utilise les réglages suivants dans VirtualBox :

| Réglage | Valeur |
| --- | --- |
| Système | Linux / Ubuntu Server 24.04 LTS, ISO adaptée à l'architecture |
| Processeurs | 2 processeurs virtuels si possible |
| Mémoire | Au moins 2 Go |
| Disque | VDI dynamique de 20 Go |
| Réseau | Adaptateur 1 en NAT |
| Installation | Activer OpenSSH Server si un accès distant est souhaité |

Après l'installation et le redémarrage d'Ubuntu Server, on relève les interfaces et la route par défaut depuis la console :

```sh
ip -br addr
ip route
```

## Lancement de Nginx dans UbuntuDev

Dans UbuntuDev, Docker Engine s'installe en suivant la documentation officielle Docker pour Ubuntu. On vérifie le moteur :

```sh
docker version
```

On démarre ensuite le conteneur Nginx et on vérifie sa configuration :

```sh
docker run -d --name web-vm -p 8088:80 nginx:1.28-alpine
docker ps
docker exec web-vm nginx -t
```

Depuis la VM, `curl -fsS http://127.0.0.1:8088` doit retourner la page d'accueil Nginx. La commande `nginx -t` confirme que la configuration du serveur est valide.

## Accès depuis l'hôte

Avec le NAT seul, une redirection TCP VirtualBox relie le port hôte `8088` au port invité `8088`; depuis macOS, on ouvre `http://127.0.0.1:8088`. Avec un réseau privé hôte ou un pont autorisé, on relève l'adresse de la VM avec `ip -br addr` et on ouvre `http://ADRESSE_DE_LA_VM:8088` depuis un poste du même réseau.

L'adresse de la VM est celle de son interface réseau. Le port `8088` est publié par Docker vers le port `80` du conteneur; ce ne sont pas la même adresse ni le même niveau réseau.

## Vérification réalisée avec Colima

Sur ce poste macOS, Docker utilise le contexte Colima. Pour valider le conteneur et sa publication de port sur la boucle locale, on exécute :

```sh
docker context show
docker run -d --name web-vm -p 127.0.0.1:8088:80 nginx:1.28-alpine
docker ps
docker exec web-vm nginx -t
curl -fsS http://127.0.0.1:8088
```

Le contexte affiché est `colima`, le test de configuration Nginx réussit et `curl` retourne HTTP 200. La publication `127.0.0.1:8088:80` relie le port local 8088 au port 80 du conteneur.

## Nettoyer

Après vérification, on supprime le conteneur. La commande fonctionne dans la VM ou sur l'hôte où il a été lancé :

```sh
docker rm -f web-vm
```

Quand la session UbuntuDev est terminée, on arrête la VM depuis le système invité :

```sh
sudo poweroff
```
