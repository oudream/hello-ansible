## PHPServerMonitor

**Toutes les opérations décrites ont été faites depuis un terminal SSH sur un container debian 9.5.1 sous proxmox**

## Préparation

- Se connecter en SSH

```shell
ssh root@ipphpservermon
```

- Installer sudo

```shell
apt install sudo
```

- Installer les dépôts pour PHP7.2

```shell
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
apt update && apt upgrade

Si on obtient le message d'erreur çi dessous

Reading package lists... Done
E: The method driver /usr/lib/apt/methods/https could not be found.
N: Is the package apt-transport-https installed?
E: Failed to fetch https://packages.sury.org/php/dists/stretch/InRelease
E: Some index files failed to download. They have been ignored, or old ones used instead.
```

il faut installer

```shell
apt install ca-certificates apt-transport-https
```

- Relancer

```shell
apt update && apt upgrade
```

- Installation des paquets

```shell
apt install apache2 mariadb-server php7.2 php7.2-cli php7.2-common php7.2-opcache php7.2-curl php7.2-mbstring php7.2-mysql php7.2-zip php7.2-xml
```

### Database

- Entrer sur MariaDB

```shell
mysql -u root -p
```

- Création de la base de données pour PHP Server Monitor

```sql
create database phpmonitordb;
```

- Donner les droits sur la BD

```sql
grant all on phpmonitordb.* to 'phpmonitoruser'@'localhost' identified by 'phpmonitorpassword';
```

- Sortie de MariaDB

```sql
flush privileges;
exit
```

## Installation

- Se rendre dans

```shell
cd /var/www/html
```

- Télécharger la dernière version de phpservermon

```shell
wget https://github.com/phpservermon/phpservermon/releases/download/v3.3.2/phpservermon-3.3.2.tar.gz
```

- Décompresser l'archive

```shell
tar -zxvf phpservermon-3.3.2.tar.gz
```

- Renommer

```shell
mv phpservermon-3.3.2 phpservermon
```

- Editer la timzone dans php.ini

```shell
nano /etc/php/7.2/apache2/php.ini
```

chercher la ligne

```shell
;date.timezone = 
```

et la remplacer par

```shell
date.timezone = Europe/Paris
```

- Créer un fichier config.php

```shell
nano /var/www/html/phpservermon/config.php
```

Et ajouter

```shell
<?php
define('PSM_DB_PREFIX', 'monitor_');
define('PSM_DB_USER', 'phpmonitoruser');
define('PSM_DB_PASS', 'phpmonitorpassword');
define('PSM_DB_NAME', 'phpmonitordb');
define('PSM_DB_HOST', 'localhost');
define('PSM_DB_PORT', '3306');
define('PSM_DEBUG', true);
```

- Modifier les droits sur le répertoire phpservermon

```shell
chown -R www-data:www-data /var/www/html/phpservermon
```

- Redemarrage du service apache

```shell

```

## Utilisation

- Finaliser l'installation en se rendant sur

[http://ipduserveur/phpservermon](http://ipduserveur/phpservermon "http://ipduserveur/phpservermon")

### Crontab

- Editer crontab

```shell
nano /etc/crontab
```

- Ajouter un crontab pour automatiser le check toutes les 5 mns

```shell
*/5 * * * * root /usr/bin/php /var/www/html/phpservermon/cron/status.cron.php
```
