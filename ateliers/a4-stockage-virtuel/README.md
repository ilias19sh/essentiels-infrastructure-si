# Atelier A4 - Stockage virtuel

Réutiliser UbuntuDev de [A2](../a2-vm-linux-conteneur-web/) et lui attacher un second disque virtuel. Le but est de partitionner et monter ce disque, puis de retrouver un fichier témoin après démontage/remontage.

## Ajouter et identifier le disque

Éteindre la VM. Dans VirtualBox, ajouter au contrôleur un second disque VDI dynamique de 2 Go, puis démarrer UbuntuDev.

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

Identifier le nouveau périphérique non partitionné en vérifiant soigneusement sa taille et l'absence de montage. Les commandes ci-dessous supposent qu'il s'agit de `/dev/sdb`; ce nom peut être différent. Ne jamais les exécuter sur le disque système.

## Partitionner, formater et vérifier

Le partitionnement et le formatage détruisent les données du périphérique choisi. Continuer uniquement après avoir confirmé le bon disque avec `lsblk`.

```sh
sudo fdisk /dev/sdb
```

Dans `fdisk`, saisir `g` pour créer la table GPT, `n` pour créer une partition, accepter les valeurs par défaut, puis `w` pour écrire. Vérifier le résultat avant de formater :

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
sudo mkfs.ext4 /dev/sdb1
sudo mkdir -p /mnt/lab-data
sudo mount /dev/sdb1 /mnt/lab-data
echo "Disque de test" | sudo tee /mnt/lab-data/temoin.txt
findmnt /mnt/lab-data
sudo umount /mnt/lab-data
sudo mount /dev/sdb1 /mnt/lab-data
cat /mnt/lab-data/temoin.txt
```

Résultat attendu après remontage : le fichier affiche `Disque de test`. Cette vérification démontre que les données restent sur le disque virtuel, et non dans le répertoire temporairement monté.

## Montage permanent facultatif

Relever l'UUID de la partition et l'ajouter à `/etc/fstab` plutôt que d'utiliser un nom `/dev/sdX` susceptible de changer :

```sh
sudo blkid /dev/sdb1
```

Ajouter une ligne de la forme ci-dessous dans `/etc/fstab`, en remplaçant l'UUID par la valeur réellement obtenue :

```fstab
UUID=REMPLACER_PAR_UUID /mnt/lab-data ext4 defaults,nofail 0 2
```

Vérifier avant redémarrage :

```sh
sudo umount /mnt/lab-data
sudo mount -a
findmnt /mnt/lab-data
cat /mnt/lab-data/temoin.txt
```

## Nettoyer

Démonter le volume avec `sudo umount /mnt/lab-data` si nécessaire, retirer la ligne ajoutée à `/etc/fstab`, puis éteindre la VM avant de détacher le disque dans VirtualBox. Ne supprimer le disque virtuel qu'après avoir confirmé que ses données ne sont plus nécessaires.

## État de réalisation

La procédure est documentée, mais aucun disque n'a été formaté ni monté sur la machine de préparation. Le nom `/dev/sdb` et le contenu du fichier témoin sont des exemples à valider dans la VM.
