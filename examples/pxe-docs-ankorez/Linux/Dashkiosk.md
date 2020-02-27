# Dashkiosk

**Toutes les opérations décrites ont été faites depuis un terminal SSH sur un container debian 9.3.1 sous proxmox**

## Installation

- Télécharger la dernière version de Dahskiosk [https://github.com/vincentbernat/dashkiosk/releases](https://github.com/vincentbernat/dashkiosk/releases "https://github.com/vincentbernat/dashkiosk/releases")

```bash
wget https://github.com/vincentbernat/dashkiosk/archive/v2.7.3.tar.gz
```

- Installer les paquets suivants

```bash
apt-get install -y curl sudo git build-essential
```

- Installer NodeJS

```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
```

```bash
sudo apt-get install -y nodejs
```

- Installer avahi

```
sudo apt install libavahi-compat-libdnssd-dev
```

Si le message d'erreur suivant s'affiche

**Failed to start Avahi mDNS/DNS-SD Stack.**

il faut éditer le fichier

```bash
nano /etc/avahi/avahi-daemon.conf
```

et commenter la ligne

```bash
rlimit-nproc = 3

#rlimit-nproc = 3
```

puis relancer

```bash
sudo apt install libavahi-compat-libdnssd-dev
```

- Installer bower et grunt

```
npm install -g bower grunt-cli
```

- Décompresser dashkiosk précédemment téléchargé

```bash
tar -xvzf v2.7.3.tar.gz
```

- Se rendre dans le répertoire dashkiosk

```bash
cd dashkiosk-2.7.3
```

- Installer les dépendances avec npm

```bash
npm install
```

- Build

```bash
grunt
```

- Installation

```bash
cd dist && npm install --production
```

## Configuration

### Chromecast

- Installer les paquets suivants

```bash
apt install avahi-utils libnss-mdns
```

- Editer le fichier

```bash
nano /etc/nsswitch.conf
```

et remplacer la ligne qui commence par

```bash
hosts
```

par ce contenu

```bash
hosts:          files mdns4_minimal [NOTFOUND=return] dns mdns4
```

- Lancer la détection du Chromecast

```bash
avahi-browse -r _googlecast._tcp
```

et identifier la ligne suivante qui correspond au chromecast

```bash
hostname = 52c2e30d-976a-dd35-fa83-bfd0f50f9b11.local
```

- Checker l'ip du Chromecast

```bash
getent hosts 52c2e30d-976a-dd35-fa83-bfd0f50f9b11.local
```

- Editer le fichier config.js

```bash
nano dashkiosk-2.7.3/dist/lib/config.js
```

```
// Chromecast
chromecast: {
  enabled: true,
  receiver: 'http://<IP du container debian>:9400/receiver',
  app: '5E7A2C2C'
},
```

## Utilisation

- Pour lancer Dashkiosk il faut être dans le répertoire

```bash
cd dashkiosk-2.7.3/dist/
```

```bash
node server.js --environment production
```

## Astuce

- Pour laisser tourner dashkiosk après s’être connecté en SSH on va utiliser screen

sur le container debian

```bash
apt install screen
```

- pour lancer screen

```bash
screen
```

- ainsi on peut lancer la commande qui permet d’exécuter dashkiosk et fermer la fenêtre pour la récupérer plus tard

```
screen -r
```

**Source:** [https://dashkiosk.readthedocs.io/en/latest/](https://dashkiosk.readthedocs.io/en/latest/ "https://dashkiosk.readthedocs.io/en/latest/")
