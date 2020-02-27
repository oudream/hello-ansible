# Proxmox

## Installation

TODO

Le format Qcow2 permet de faire des snapshots mais est relativement lent (surtout sous Windows)

Le format RAW est beaucoup plus rapide (surtout avec Windows) mais ne permet pas les snapshots

## LXC

Attention pour pouvoir monter un share CIFS distant sur un LXC Proxmox il faut décocher **unprivileged container** à la création

### Convertir un subvol en image raw

```shell
mkdir /mnt/raw-img
mount -o loop /data/images/120/vm-120-disk-0.raw /mnt/raw-img
cp -Rfp /data/images/120/subvol-120-disk-0.subvol/* /mnt/raw-img/.
umount /mnt/raw-img/
```

Editer le fichier de config

```
nano /etc/pve/lxc/120.conf
```

Remplacer

~~rootfs: local:120/vm-120-disk-1.subvol,size=0T~~

rootfs: data:120/vm-120-disk-0.raw,size=8G
