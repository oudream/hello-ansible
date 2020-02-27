## OpenMPTCProuter

OpenMPTCProuter utilise MultiPath TCP (MPTCP) pour agréger des multiples connections (4G,ADSL,VDSL,fibre,…) et OpenWrt. Je m'en sers pour agréger mon Galet 4G Bouygues avec la connexion 4G Orange partagée par mon Smartphone. J'utilise 1 Switch 1 RPi et un VPS chez Scaleway.

**Prérequis :**

- 1 RPi

- 1 Switch

- 2 Connexions 4G/Fibre/ADSL ou VDSL

- 1 VPS

*Sources*

[https://www.openmptcprouter.com/](https://www.openmptcprouter.com/ "https://www.openmptcprouter.com/")

[https://github.com/Ysurac/openmptcprouter/wiki/Router-install](https://github.com/Ysurac/openmptcprouter/wiki/Router-install "https://github.com/Ysurac/openmptcprouter/wiki/Router-install")

[https://github.com/Ysurac/openmptcprouter/wiki/Install-or-update-the-VPS](https://github.com/Ysurac/openmptcprouter/wiki/Install-or-update-the-VPS "https://github.com/Ysurac/openmptcprouter/wiki/Install-or-update-the-VPS")

[https://github.com/Ysurac/openmptcprouter/wiki/OpenMPTCProuter-configuration](https://github.com/Ysurac/openmptcprouter/wiki/OpenMPTCProuter-configuration "https://github.com/Ysurac/openmptcprouter/wiki/OpenMPTCProuter-configuration")

[https://github.com/Ysurac/openmptcprouter/wiki/Port-forwarding](https://github.com/Ysurac/openmptcprouter/wiki/Port-forwarding "https://github.com/Ysurac/openmptcprouter/wiki/Port-forwarding")

### mptcprouter server

- Aller sur Scaleway et prendre un serveur privé [https://www.scaleway.com/pricing/](https://www.scaleway.com/pricing/ "https://www.scaleway.com/pricing/")

- Choisir la distrib Debian Stretch.

- Se connecter en SSH.

```bash
ssh root@ipduserverscaleway
```

- Installer OpenMPTCProuter Server.

```bash
wget -O - http://www.openmptcprouter.com/server/debian9-x86_64.sh | sh
```

- A la fin de l'installation on doit redémarrer mais avant on va copier la OpenMPTCProuter VPS Admin key et on la met de coté pour la suite. Pour la trouver il faut faire

```bash
cat /root/openmptcprouter_config.txt
```

- Reboot

```
reboot
```

- Apres le reboot du mptcprouter server le port SSH par défaut devient 65222

### mptcprouter

- Télécharger l'image OpenMPTCProuter pour Raspberry [https://www.openmptcprouter.com/download](https://www.openmptcprouter.com/download "https://www.openmptcprouter.com/download")

- Lancer Etcher et flasher la carte micro SD.

- Insérer la micro SD dans le Raspberry et le connecter en Ethernet au switch.

- Connecter le Galet 4G en USB au RPi (Il faut avant avoir désactivé le DHCP et bien noter dans quel réseau il est dans le cas actuel l'IP est 192.168.1.1)

- Modifier l'IP de son ordinateur en 192.168.100.10/24

- Entrer l'IP 192.168.100.1 dans le navigateur (c'est l'IP du routeur MPTCP)

- Entrer sans mot de passe avec uniquement l’utilisateur root renseigné

- Ajouter un mot de passe personnalisé

- Se rendre ensuite dans le menu en haut **Système > OpenMPTCProuter**

- Assistant

#### Paramètres du serveur

**IP du serveur :** Entrer l'IP du serveur OpenMPTCProuter Server hébergé sur Scaleway.

**Clef d'OpenMPTCProuter VPS :** Coller la clé précédemment copiée.

#### Paramètres des interfaces

##### Editer l'interface WAN1

- Menu > Réseau > Interfaces > WAN1 > Editer > Configuration générale

**Protocole** Adresse statique

**Adresse IPv4** 192.168.1.2

**Masque de sous-réseau IPv4** 255.255.255.0

**Passerelle IPv4** 192.168.1.1

- Menu > Réseau > Interfaces > WAN1 > Editer > Paramètres Physiques

**Interface** USB0

- Sauvegarde et Appliquer

##### Créer l'interface WWAN

- Menu > Réseau > Sans fil

**Scan**

**Se Connecter au réseau WIFI 4G Partagé par mon Smarpthone**

**Rejoindre un réseau**

**Entrer le mot de passe WPA**

**Créer / Assigner une zone du parefeu** non precisé

- Soumettre

- Menu > Réseau > Interfaces > Editer > WWAN > Configuration générale

**Protocole** Client DHCP

- Menu > Réseau > Interfaces > Editer > WWAN > Paramètres avancés

**Multipath TCP** Activé

- Sauvegarder et Appliquer

#### Utilisation

- Menu > Système > OpenMPTCProuter > Etat
