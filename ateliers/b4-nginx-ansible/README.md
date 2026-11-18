# Atelier B4 - Déployer Nginx avec Ansible

Configurer Nginx à distance sur UbuntuDev (A2) depuis un poste de contrôle. Ansible utilise SSH et des modules idempotents pour gérer le paquet, la page et le service.

## Prérequis

- Une cible Ubuntu Server joignable en SSH avec Python 3 et un compte autorisé à utiliser `sudo`.
- Ansible sur le poste de contrôle Linux ou macOS; sous Windows, utiliser une distribution WSL pouvant joindre la cible.
- Une clé SSH configurée et une empreinte de clé d'hôte vérifiée depuis la console de la VM. Garder la vérification des clés activée.

Copier `inventory.ini.example` vers `inventory.ini`, puis remplacer l'adresse et le compte par ceux réellement utilisés :

```sh
cp inventory.ini.example inventory.ini
ssh utilisateur@192.168.56.20
ansible --version
ansible -i inventory.ini targets -m ansible.builtin.ping
```

`inventory.ini` est local; ne pas y mettre de secrets ni publier les paramètres personnels de connexion.

## Appliquer et vérifier

```sh
ansible-playbook -i inventory.ini web.yml --syntax-check
ansible-playbook -i inventory.ini web.yml -K
ansible-playbook -i inventory.ini web.yml -K
ansible-playbook -i inventory.ini web.yml -K --check --diff
```

`-K` demande le mot de passe sudo si nécessaire. Résultat attendu : Nginx est installé et actif, et la page `http://192.168.56.20/ansible.html` contient `Configuration geree avec Ansible`. Remplacer l'adresse par celle de la VM. Après la première application, la seconde doit normalement indiquer `changed=0` si aucun état n'a dérivé et que le cache apt est valide. Le mode check/diff simule les changements qu'Ansible peut prédire; il ne remplace pas l'application réelle.

## Nettoyer

Le playbook laisse le service activé. Pour retirer les ressources, désinstaller explicitement Nginx sur la VM après avoir confirmé qu'aucun autre exercice n'en dépend.

## État de réalisation

L'inventaire d'exemple et le playbook sont versionnés. Ansible n'est pas installé sur le poste de préparation et la VM A2 n'est pas joignable; syntax-check, connexion SSH et applications restent à effectuer.
