# Atelier A3 - Connecter une VM

Réutiliser UbuntuDev préparée dans [A2](../a2-vm-linux-conteneur-web/), conserver son interface NAT pour l'accès sortant et ajouter une interface privée hôte pour les tests depuis macOS.

## Préparer le réseau

Éteindre UbuntuDev. Dans VirtualBox, garder l'adaptateur 1 en NAT et ajouter l'adaptateur 2 en réseau privé hôte. Créer un réseau privé hôte si nécessaire. Vérifier son sous-réseau et la plage DHCP côté hôte; choisir pour l'invité une adresse libre hors de cette plage. Ne pas utiliser l'exemple ci-dessous sans vérifier qu'il correspond au réseau local.

Démarrer la VM et identifier le nom réel de l'interface ajoutée :

```sh
ip -br link
ip -br addr
ip route
```

Le modèle [60-lab.yaml.example](60-lab.yaml.example) utilise `enp0s8` et `192.168.56.20/24` à titre d'exemple. Adapter ces deux valeurs, puis copier son contenu dans `/etc/netplan/60-lab.yaml` depuis la console de la VM. Ne pas définir deux fois la même interface dans plusieurs fichiers Netplan. Laisser l'interface NAT fournir la route par défaut et le DNS.

```sh
sudo chmod 600 /etc/netplan/60-lab.yaml
sudo netplan generate
sudo netplan try
ip -br addr
ip route
getent hosts ubuntu.com
```

Accepter `netplan try` depuis la console après avoir vérifié l'adresse et la route. Si l'accès est perdu, la configuration revient à l'état antérieur à l'expiration du délai.

## Vérifier depuis l'hôte

Depuis macOS, remplacer l'adresse par celle réellement configurée :

```sh
ping 192.168.56.20
ssh utilisateur@192.168.56.20
curl -fsS http://192.168.56.20:8088
```

Le test HTTP suppose que le conteneur web d'A2 tourne dans la VM. Si ICMP est filtré, cela ne prouve pas à lui seul un défaut de routage; vérifier également SSH ou le port HTTP réellement utilisé.

## Nettoyer

Arrêter UbuntuDev avant de supprimer l'adaptateur privé hôte dans VirtualBox. Pour retirer la configuration statique dans la VM, supprimer `/etc/netplan/60-lab.yaml`, puis exécuter `sudo netplan generate` et `sudo netplan apply` depuis la console.

## État de réalisation

Les commandes et le modèle sont fournis, mais les tests dépendent de la VM et du réseau privé hôte A2, qui ne sont pas disponibles sur la machine de préparation. Consigner les adresses réellement observées et les résultats des tests après exécution; ne pas présenter les exemples comme des mesures faites.
