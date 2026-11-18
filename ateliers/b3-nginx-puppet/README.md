# Atelier B3 - Configurer Nginx avec Puppet

Réutiliser la VM Ubuntu Server de [A2](../a2-vm-linux-conteneur-web/), installer Puppet Agent et appliquer localement un module Puppet qui gère le paquet, un fichier web et le service Nginx.

## Prérequis

- Ubuntu Server 24.04 dans la VM A2.
- Aucun autre service ne doit occuper le port 80 dans cette VM.
- `puppet-agent` disponible via les dépôts Ubuntu Universe.

Sur la VM :

```sh
sudo apt update
sudo apt install puppet-agent
puppet --version
```

Les fichiers de ce dossier reproduisent l'arborescence du module. Depuis ce dossier, le module est dans `modules/web_nginx` et le point d'entrée est `site.pp`.

## Valider et appliquer

```sh
puppet parser validate site.pp modules/web_nginx/manifests/init.pp
sudo puppet apply --modulepath="$PWD/modules" --noop site.pp
sudo puppet apply --modulepath="$PWD/modules" site.pp
systemctl is-active nginx
curl -fsS http://127.0.0.1/puppet.html
```

Résultat attendu : le service est `active` et la page contient `Configuration geree avec Puppet`.

Relancer immédiatement le manifeste pour contrôler la convergence :

```sh
sudo puppet apply --modulepath="$PWD/modules" site.pp
```

Résultat attendu si rien n'a changé : Puppet indique que les ressources sont déjà conformes et ne modifie pas la cible. Pour observer une correction, modifier la page dans la VM puis rejouer le manifeste.

## Nettoyer

Le manifeste laisse Nginx installé et activé afin de préserver l'état géré. Pour retirer l'installation, procéder explicitement dans la VM : arrêter/désactiver le service et supprimer le paquet; ne pas supprimer des données système sans les avoir vérifiées.

## État de réalisation

Le module et les commandes sont versionnés. Puppet n'est pas installé sur la machine de préparation et la VM A2 n'est pas disponible; validation, application et seconde exécution restent à faire.
