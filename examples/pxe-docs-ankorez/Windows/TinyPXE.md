# Tiny PXE Server – Boot ISO BIOS UEFI

Tiny PXE Server s'installe sur Windows 10 et permet d'avoir un serveur PXE opérationnel en quelques minutes. Je m'en sers pour déployer des ordinateurs sous Linux ou Windows en BIOS et UEFI.

## Installation

1.Télécharger la dernière version de Tiny PXE Server. [http://reboot.pro/files/download/303-tiny-pxe-server/](http://reboot.pro/files/download/303-tiny-pxe-server/ "http://reboot.pro/files/download/303-tiny-pxe-server/")

2.Extraire le contenu du fichier zip pxeserv.zip dans un répertoire.

## Configuration

3.Editer le fichier config.ini et de-commenter les lignes suivantes

```
;00006=bootia32.efi
;00007=bootx64.efi
```

et les remplacer par ça

```
00000=ipxe.pxe
00007=ipxe-x86_64.efi
```

4.Créer un fichier menucustom.ipxe dans \pxeserv\files\ et y copier coller ce contenu

```
#!ipxe
#set boot-url http://${proxydhcp}/next-server
set boot-url http://${next-server}
#set iscsi-server 192.168.1.100
#set iqn iqn.2008-08.com.starwindsoftware:test
#set nfs-server ${next-server}
#set cifs-server //${next-server}
#set boot-url http://192.168.1.100

# Setup some basic convenience variables

set menu-timeout 5000
set submenu-timeout ${menu-timeout}

# Ensure we have menu-default set to something

isset ${menu-default} || set menu-default exit
######## MAIN MENU ###################
:start
menu Welcome to Boot Menu
item
item --gap -- -------------------------------- MENU --------------------------------------
item ubuntu Ubuntu 17.04 (BIOS - UEFI)
item debian Debian 9.1 (BIOS - UEFI)
item --gap -- ------------------------------ Advanced ----------------------------------
item config Configure settings
item shell Enter iPXE shell
item reboot Reboot
item exit Exit (boot local disk)
choose --default exit --timeout 30000 target && goto ${target}
########## UTILITY ITEMS ####################
:shell
echo Type exit to get the back to the menu
shell
set menu-timeout 0
goto start
:failed
echo Booting failed, dropping to shell
goto shell
:reboot
reboot
:exit
exit
:cancel
echo You cancelled the menu, dropping you to a shell
:config
config
goto start
:back
set submenu-timeout 0
clear submenu-default
goto start
#######################################################
:debian
sanboot http://ftp.fr.debian.org/debian/dists/Debian9.1/main/installer-amd64/current/images/netboot/mini.iso
boot || goto failed
:ubuntu
sanboot http://archive.ubuntu.com/ubuntu/dists/zesty/main/installer-amd64/current/images/netboot/mini.iso
boot || goto failed
#######################################################
#Memdisk via iPXE vs. ISO Boot HTTP via iPXE:

# 

#Memdisk via iPXE does the following things:
#1) Emulates a CD-ROM allowing a Network-Based Install.
#2) Masks actual system RAM because the environment memdisk creates "hides" a certain amount of RAM to allow for the ISO - This amount is generally 2x ISO Size (Maximum 2GB - I think).
#3) Preloads the ISO into memory before executing the ISO. This slows boot time a bit.

# 

#ISO Boot over HTTP via iPXE:
#1) Does not emulate a CD-ROM. It is a Block Device.
#2) Does not mask system RAM.
#3) Executes as it reads: Faster than memdisk and no "preloading" of the ISO is required.
#4) Does not hold the ISO as a readable device once the ISO is loaded unless loaded into the iBFT.
```

### Preseed Linux

- Boot sur Debian ou Ubuntu en UEFI avec un fichier preseed

```
:debian-auto-client
set base-url http://ftp.fr.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/debian-installer/amd64
kernel ${base-url}/linux
initrd ${base-url}/initrd.gz
imgargs linux initrd=initrd.gz auto=true url=http://pxe-mdt.mondomaine.xy/preseed/DebianAutoClientTest.cfg
boot || goto failed
goto start
```

En BIOS/LEGACY ça marche sans mais en UEFI il faut ce initrd=initrd.gz

## Utilisation

5. Exécuter le fichier pxeserv.exe

6. Cocher ProxyDHCP et HTTPd

7. Section boot file il faut indiquer le nom (user-class) menucustom.ipxe créé précédemment

8. On clic droit puis save pour sauver la config et enfin clic gauche sur Online

And Voilà on peut booter avec un PC sur le réseau en pxe sur de l’uefi ou du bios et installer Ubuntu ou Debian 🙂

On peut également faire la même opération avec des iso en local sur notre PC en prenant soin d’indiquer le chemin des iso dans mencustom.ipxe (tous les iso ne sont pas compatibles avec cette méthode). Mais bonne nouvelle l’iso Lite Touch Installation générée par l’outil de déploiement MDT fonctionne parfaitement).

Enjoy

Grand merci à **Erwan Labalec**
