# iPXEOpenVPN

J'ai besoin de pouvoir deployer des postes de travail sur des sites distants qui ne sont pas reliés au site principal ou sont tous les serveurs. Je vais utiliser un RPi comme un routeur connecté avec OpenVPN depuis mes sites distant vers mon site principal. Grace à ça je vais pouvoir matricer mes postes depuis n'importe ou du moment qu'une connexion Wifi est disponible et que le client OpenVPN n'est pas bloqué.

**Prérequis :**

- 1 VM Debian ou un RPi

- 1 Switch

- 1 Serveur TinyPXE distant (Windows)

- 1 Connexion Wifi

#### Préparation

- Télécharger la dernière version de Raspbian Lite

[https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/ "https://www.raspberrypi.org/downloads/raspbian/")

- Télécharger Etcher pour mettre l'image raspbian sur une carte micro SD qui ira dans le raspberry

[https://etcher.io/](https://etcher.io/ "https://etcher.io/")

- Lancer Etcher et flasher la carte SD.

#### Installation

- Insérer la micro SD dans le Raspberry puis connecter un câble réseau ainsi qu'un clavier et un écran

- Mettre le Raspberry sous tension.

- Au lancement Raspbian s'installe automatiquement

#### Configuration

- Login

```bash
pi
```

- Password (attention clavier en qwerty)

```bash
raspberry
```

- Pour mettre le clavier en français et activer le SSH

```bash
raspi-config
```

**Menu > 4 Localisation Options > 13 Change Keyboard Layout
Menu > 5 Interfacing Options > P3 Enable SSH**

### Réseau

- Editer dhcpcd.conf

```bash
sudo nano /etc/dhcpcd.conf
```

- Ajouter cette ligne tout en haut du fichier dhcpcd.conf

```bash
denyinterfaces eth0
```

- Ajouter une IP fixe et configurer les interfaces réseaux

```bash
sudo nano /etc/network/interfaces
```

```bash
auto lo
iface lo inet loopback
#Interface Ethernet
auto eth0
allow-hotplug eth0
iface eth0 inet static
    address 10.53.1.254
    netmask 255.255.255.0
    network 10.53.1.0
    broadcast 10.53.1.255

allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

- Création du profil Wifi

```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

- Editer les lignes avec les bonnes informations (SSID et clé WPA2)

```bash
country="FR"
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="MONSSID4GORANGE"
    psk="MONPASS4GORANGE"
    key_mgmt=WPA-PSK
}
```

- Reboot

```bash
sudo reboot
```

- Obtenir l'IP Wifi

```bash
ip add
```

- Se connecter en SSH (via l'IP WIFI) depuis son PC

```bash
ssh pi@ipwifidurpi
```

### Mise à jour

- Lancer les updates

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### DHCP

```bash
sudo apt install isc-dhcp-server
```

Le message d'erreur à la fin de l'installation est normal

- Editer /etc/dhcp/dhcpd.conf

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

- Ajouter

```bash
# This is a network pxe subnet declaration.

option space ipxe;
option ipxe-encap-opts code 175 = encapsulate ipxe;
option ipxe.priority code 1 = signed integer 8;
option ipxe.keep-san code 8 = unsigned integer 8;
option ipxe.skip-san-boot code 9 = unsigned integer 8;
option ipxe.syslogs code 85 = string;
option ipxe.cert code 91 = string;
option ipxe.privkey code 92 = string;
option ipxe.crosscert code 93 = string;
option ipxe.no-pxedhcp code 176 = unsigned integer 8;
option ipxe.bus-id code 177 = string;
option ipxe.bios-drive code 189 = unsigned integer 8;
option ipxe.username code 190 = string;
option ipxe.password code 191 = string;
option ipxe.reverse-username code 192 = string;
option ipxe.reverse-password code 193 = string;
option ipxe.version code 235 = string;
option iscsi-initiator-iqn code 203 = string;

# Feature indicators
option ipxe.pxeext code 16 = unsigned integer 8;
option ipxe.iscsi code 17 = unsigned integer 8;
option ipxe.aoe code 18 = unsigned integer 8;
option ipxe.http code 19 = unsigned integer 8;
option ipxe.https code 20 = unsigned integer 8;
option ipxe.tftp code 21 = unsigned integer 8;
option ipxe.ftp code 22 = unsigned integer 8;
option ipxe.dns code 23 = unsigned integer 8;
option ipxe.bzimage code 24 = unsigned integer 8;
option ipxe.multiboot code 25 = unsigned integer 8;
option ipxe.slam code 26 = unsigned integer 8;
option ipxe.srp code 27 = unsigned integer 8;
option ipxe.nbi code 32 = unsigned integer 8;
option ipxe.pxe code 33 = unsigned integer 8;
option ipxe.elf code 34 = unsigned integer 8;
option ipxe.comboot code 35 = unsigned integer 8;
option ipxe.efi code 36 = unsigned integer 8;
option ipxe.fcoe code 37 = unsigned integer 8;

# speed-up for no proxydhcp user
option ipxe.no-pxedhcp 1;

# common settings
authoritative;
ddns-update-style interim;
ignore client-updates;

allow booting;
allow bootp;

set vendorclass = option vendor-class-identifier;

subnet 10.53.1.0 netmask 255.255.255.0 {

   range                           10.53.1.10 10.53.1.100;

   option routers                  10.53.1.254;

   option subnet-mask              255.255.255.0;
   option domain-name              "mondomaine.lan";

   option domain-name-servers      DNSDistant, 1.1.1.1;


   default-lease-time 21600;
   max-lease-time 43200;
   next-server 10.53.1.254;

   if exists user-class and option user-class = "iPXE" {
     filename "http://10.0.0.25/menuvpn.ipxe";

   } else {
            filename "ipxe-x86_64.efi";
   }
}
```

- Editer /etc/default/isc-dhcp-server

```bash
sudo nano /etc/default/isc-dhcp-server
```

- Remplacer

```bash
INTERFACESv4=""
```

- par

```bash
INTERFACESv4="eth0"
```

- Redemarrer le service DHCP

```bash
sudo service isc-dhcp-server restart
```

### OpenVPN

```bash
sudo apt install openvpn unzip
```

- Regler correctement la time zone

```bash
sudo dpkg-reconfigure tzdata
```

- Créer /etc/openvpn/credentials

```bash
sudo nano /etc/openvpn/credentials
```

- Ajouter les identifiants openvpn

```bash
user
password
```

- Ouvrir une nouvelle console SSH et copier les fichiers vpn dans /home/pi/

```bash
sudo scp ca.crt client.crt client.key config.ovpn pi@ipwifidurpi:/home/pi/
```

- Deplacer les fichiers ovpn

```bash
sudo mv /home/pi/* /etc/openvpn/
```

- Modifier le .ovpn en .conf

```bash
sudo mv /etc/openvpn/config.ovpn /etc/openvpn/ovpn.conf
```

- Auto-login

```bash
sudo nano /etc/openvpn/ovpn.conf
```

- Remplacer

```bash
auth-user-pass
```

- par

```bash
auth-user-pass credentials
```

- Tester la connexion

```bash
sudo openvpn --config /etc/openvpn/ovpn.conf
```

### Activer le NAT

```bash
sudo nano /etc/sysctl.conf
```

- Decommenter la ligne

```bash
net.ipv4.ip_forward=1
```

- Activer les changements

```bash
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
```

### IPTables

- Router tout le trafic vers l'interface OpenVPN

```bash
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
```

- Sauvegarder la regle

```bash
sudo apt install iptables-persistent
```

- Répondre **oui** à la question 'Faut-il sauvegarder les régles actuelles IPV4?'

### TFTP

- TFTP fournira le bootloader aux machines en PXE

```bash
sudo apt install tftpd-hpa
```

- Ouvrir une nouvelle console SSH et copier le bootloader **ipxe-x86_64.efi** dans /home/pi (Il est disponible sur le serveur TinyPXE)

```bash
sudo scp ipxe-x86_64.efi pi@ipwifidurpi:/home/pi/
```

- Revenir sur la console SSH du RPI et deplacer le bootloader dans /srv/tftp

```bash
sudo mv /home/pi/ipxe-x86_64.efi /srv/tftp/
```

- Redemarrer le service TFTP

```bash
sudo service tftpd-hpa restart
```

### TinyPXE

- Via un editeur de texte créer le fichier **menuvpn.ipxe** sur le serveur TinyPXE (10.0.0.25)

```bash
c:\pxeserv\files\menuvpn.ipxe
```

- **menuvpn.ipxe**
- Attention il faut que la ligne **set boot-url 10.0.0.25** corresponde bien à l'IP du serveur TinyPXE distant qui sera joint par OpenVPN

```bash
#!ipxe

#set boot-url http://${proxydhcp}/next-server
#set boot-url http://${next-server}

#set iscsi-server 192.168.1.100
#set iqn iqn.2008-08.com.starwindsoftware:test
#set nfs-server ${next-server}
#set cifs-server //${next-server}
set boot-url 10.0.0.25


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

Il ne reste plus qu'à connecter le switch au RPi et un PC au switch pour voir si on arrive bien à demarrer en PXE via OpenVPN :)
