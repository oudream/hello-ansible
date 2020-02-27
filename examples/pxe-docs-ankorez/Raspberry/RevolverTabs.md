# Revolver - Tabs

Revolver - Tabs est une extension pour Chrome qui permet de switcher entre plusieurs pages web. On s'en sert pour monitorer des pages web ou diffuser un ou plusieurs dashboard grâce à un Raspberry PI sous raspbian

## Préparation

- Télécharger la dernière version de Raspbian

[https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/ "https://www.raspberrypi.org/downloads/raspbian/")

- Télécharger Etcher pour mettre l'image raspbian sur une carte micro SD qui ira dans le raspberry

[https://etcher.io/](https://etcher.io/ "https://etcher.io/")

- Lancer Etcher et flasher la carte SD.

## Installation

- Insérer la micro SD dans le Raspberry puis connecter un câble réseau ainsi qu'un clavier et une souris.

- Mettre le Raspberry sous tension.

- Au lancement Raspbian s'installe automatiquement

## Configuration

- Menu Framboise > Préférences > Raspberry Pi Configuration

**Onglet Localisation**

- Set Locale: FR

- Set Timezone: Europe / Paris

- Set Keyboard : FR

- Set Wifi Country: FR France

**Onglet Interfaces**

- Activer VNC

- Activer SSH

**Onglet System**

- Modifier le password

- Modifier le nom

- Désactiver Underscan (pour retirer les bandes noires)

- Valider les changements en cliquant sur OK mais ne pas redémarrer tout de suite

**Réseau**

## VNC Viewer

Maintenant on peut utiliser un autre PC muni de Windows pour réaliser la suite des opérations

- Télécharger VNC Viewer

[https://www.realvnc.com/fr/connect/download/viewer/](https://www.realvnc.com/fr/connect/download/viewer/ "https://www.realvnc.com/fr/connect/download/viewer/")

- Installer VNC Viewer

- Nouvelle connexion

- Entrer l'IP du Raspberry

- Enter le nom d'utilisateur **pi** si on ne l'a pas changé

- Entrer le mot de passe du Raspberry

- Se connecter

## Chromium

- Ouvrir le navigateur **Chromium**

- Ouvrir toutes les url que l'on veut afficher

- Aller dans les paramètres de Chromium et sélectionner utiliser les pages actuelles au démarrage

- Télécharger l'extension **Revolver - Tabs**

- Clic droit sur l'extension Revolver - Tabs

- Cocher Auto Start

- Fermer Chromium

### Xtrlock

permet de verrouiller le clavier et la souris. Il faut saisir le mot de passe de la session pour deverrouiller

```bash
sudo apt install xtrlock
```

- Entrer le mot de passe user pour déverrouiller le cadenas xtrlock apres la connexion sur VNC

## Raspbian

- On se connecte en SSH au Raspberry et édite le fichier

```bash
sudo nano /home/pi/.config/lxsession/LXDE-pi/autostart
```

- On ajoute

```bash
@xset s off
@xset -dpms
@xset s noblank
@chromium-browser --start-fullscreen
@xtrlock
```

## Options

### Bash update

Permet de mettre à jour les URL diffusées sur tous les RPI à la fois

```bash
#!/bin/bash

# Vin's © update_rpi_rh v1.0

#IP=( 10.0.5.6 10.0.5.11 10.0.5.12 10.0.5.14 10.0.5.15 10.0.5.16 )
IP=( 10.0.5.1 ) # Ip de test
echo "url ?"
read URL
for u in ${IP[@]}; do
  if ! ping -c 1 $u >/dev/null 2>&1;then
      echo "ERROR : Host $u did not respond"
      continue
  fi
  ssh -oStrictHostKeyChecking=no pi@${u} << EOF >logerr.txt 2>&1
  sed -i 's#"exited_cleanly":false#"exited_cleanly":true#' ~/.config/chromium/Local\ State;
  sed -i 's#"exit_type":"Crashed"#"exit_type":"Normal"#' ~/.config/chromium/Default/Preferences;
  sed -i 's|\(^@chromium.*-crashed-bubble\)\(.*\)|\1 ${URL}|' /home/pi/.config/lxsession/LXDE-pi/autostart;
  sudo reboot;
EOF
  if [ $?==0 ];then
    echo "les fichiers sur $u ont été mis à jour"
  fi
done
```

### Chrome popin

Pour retirer les messages d'erreurs ans Chrome si le rpi crash. Il faut ajouter ce script dans l'autostart

startup.sh

```bash
#!/bin/bash
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Local\ State
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
echo
```

### Auto login avec xdotool

si on ne peut pas sauvegarder le mot de passe dans chromium on peut simuler le login avec ce script

autologin.sh

```bash
#!/bin/bash
sleep 30
xdotool mousemove 897 550
xdotool click 1
xdotool search --onlyvisible --class "Chromium" windowfocus key type monlogin
xdotool search --onlyvisible --class "Chromium" windowfocus key 'Tab'
xdotool search --onlyvisible --class "Chromium" windowfocus key type monmotdepasse
xdotool search --onlyvisible --class "Chromium" windowfocus key 'Return'
xdotool search --onlyvisible --class "Chromium" windowfocus key 'F11'
xtrlock
```

### Autostart avec les modifs

```
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@point-rpi
@xset -dpms
@xset s off
@/home/pi/Documents/startup.sh
@chromium-browser --noerrors --disable-infobars --disable-session-crashed-bubble http://sce.party 
@/home/pi/Documents/autologin.sh
```
