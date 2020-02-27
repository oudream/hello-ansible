# Pi-Hole

Pi-Hole est une solution pour se débarrasser de la publicité sur tous nos appareils connectés. Créé autour d’une carte Raspberry Pi, le système permet de passer au crible les affichages publicitaires de nos sessions de surf. Il agit comme un adblocker mais en amont. J'utilise un RPi 3 B+ comme un routeur Ethernet qui est connecté en USB à un Galet 4G. Le RPi sert de passerelle pour sortir vers internet et filtre en même temps les pubs avec Pi-Hole.

## Préparation

- Télécharger la dernière version de Raspbian Lite

[https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/ "https://www.raspberrypi.org/downloads/raspbian/")

- Télécharger Etcher pour mettre l'image raspbian sur une carte micro SD qui ira dans le raspberry

[https://etcher.io/](https://etcher.io/ "https://etcher.io/")

- Lancer Etcher et flasher la carte SD.

## Installation

- Insérer la micro SD dans le Raspberry puis connecter un câble réseau ainsi qu'un clavier.

- Mettre le Raspberry sous tension.

- Au lancement Raspbian s'installe automatiquement

## Configuration

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

### Réseau

- Editer dhcpdcd.conf

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
    address 192.168.2.254
    netmask 255.255.255.0
    network 192.168.2.0
    broadcast 192.168.2.255

#Galet 4G
allow-hotplug usb0
iface wlan0 inet dhcp
```

- Reboot

```bash
sudo reboot
```

- Se connecter en SSH

```bash
ssh pi@192.168.2.254
```

### Mise à jour

- Lancer les updates

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install iptables-persistent -y
```

### Partage Internet

- Editer sysctl.conf

```bash
sudo nano /etc/sysctl.conf
```

- Décommenter la ligne

```bash
net.ipv4.ip_forward=1
```

- Activer les changements

```bash
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
```

### IP Tables

- Reset IP Tables avec un script

```bash
sudo nano iptablereset.sh
```

- Ajouter ces lignes

```bash
#!/bin/sh
echo "Resetting the IP Tables"
ipt="/sbin/iptables"

## Failsafe - die if /sbin/iptables not found [ ! -x "$ipt" ] && { echo "$0: \"${ipt}\" command not found."; exit 1; }

$ipt -P INPUT ACCEPT
$ipt -P FORWARD ACCEPT
$ipt -P OUTPUT ACCEPT
$ipt -F
$ipt -X
$ipt -t nat -F
$ipt -t nat -X
$ipt -t mangle -F
$ipt -t mangle -X
$ipt -t raw -F
$ipt -t raw -X
```

- Ajouter les permissions sur le script

```bash
sudo chmod +x iptablereset.sh
```

- Executer

```bash
sudo ./iptablereset.sh
```

- Régles Firewall

```bash
sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
sudo iptables -A FORWARD -i usb0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
```

- Sauvegarde des régles

```bash
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
```

- Editer rc.local

```bash
sudo nano /etc/rc.local
```

- Ajotuer cette ligne avant le exit 0

```bash
iptables-restore < /etc/iptables.ipv4.nat
```

### Pi-Hole

- Installer Pi-Hole avec cette commande

```bash
curl -sSL https://install.pi-hole.net | bash
```

- Se rendre dans l'interface pi-hole

http://pi.hole/admin

ou

http://IP.du.Rpi.Ou.Est.Installé.pi-hole

- Activer le DHCP dans les settings

Settings > DHCP

- Désactiver le password

```bash
pihole -a -p
```

C'est terminé

### Optionnel

**Connexion en WIFI**

```bash
auto lo
iface lo inet loopback
auto eth0
allow-hotplug eth0
iface eth0 inet static
    address 192.168.11.254
    netmask 255.255.255.0
    network 192.168.11.0
    broadcast 192.168.11.255

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

- Création du profil Wifi

```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

- Editer les lignes avec les informations en fonction (SSID et clé WPA2)

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

- Régles Firewall

```bash
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
```

- Sauvegarde des régles

```
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
```
