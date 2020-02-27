# Smashing

**Toute les opérations décrites ont été faites en SSH sur un container Debian 9.3.1 tournant sur Proxmox**

## Installation

- Se connecter en SSH

```shell
ssh root@ipduserveur
```

- Mise à jour

```shell
apt update && apt upgrade
```

- Installation des paquets

```shell
apt install ruby ruby-dev build-essential nodejs sudo patch ruby-dev zlib1g-dev liblzma-dev git
```

- Gems

```shell
gem install smashing bundler
```

- Créer un user

```shell
adduser ankorez
adduser ankorez sudo
su ankorez
```

## Widget Transilien

```shell
mkdir ~/smashing-dashboards && cd ~/smashing-dashboards
smashing new mondashboard
cd mondashboard
```

- Editer gemfile

```shell
nano Gemfile
```

ajouter

```shell
gem 'nokogiri'
```

- Bundle

```shell
sudo bundle install
```

- Téléchargement

```shell
mkdir transilientemp && cd transilientemp
git clone https://framagit.org/tg/transilien_next_trains.git
cp -r /transilien_next_trains/* ~/smashing-dashboards/mondashboard
cd smashing-dashboards/mondashboard/
rm -rf transilientemp
```

- Editer transilien_next_trains.rb

```shell
sudo nano ~/smashing-dashboards/mondashboard/jobs/transilien_next_trains.rb
```

Modifier avec les API fournis par la SNCF

# API Credentials

```shell
API_USERNAME="APISNCF"
API_PASSWORD="APISNCF"
```

# Mandatory. Example : "VLB"

```bash
Departure_Station="87276220"
```

les identifiants API et le UICode de la station sont fournis par la SNCF. Plus d'infos ici:

[https://ressources.data.sncf.com/explore/dataset/api-temps-reel-transilien/](https://ressources.data.sncf.com/explore/dataset/api-temps-reel-transilien/ "https://ressources.data.sncf.com/explore/dataset/api-temps-reel-transilien/")

- Editer transilien_next_trains.html

```bash
sudo nano ~/smashing-dashboards/mondashboard/widgets/transilien_next_trains/transilien_next_trains.html
```

Modifier

<img class="logo-line" src="/assets/transilien_next_trains/Logo_RER_D.svg" height="32" width="32">

- Editer transilien_next_trains.erb

```bash
sudo nano ~/smashing-dashboards/mondashboard/dashboards/transilien_next_trains.erb
```

Modifier

<script type='text/javascript'>
$(function() {
  // For 1920x1080
  Dashing.widget_base_dimensions = [370, 340]
  Dashing.numColumns = 5
});
</script>

<% content_for :title do %>Dashboard<% end %>

<div class="gridster">
  <ul>
    <li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
       <div data-id="transilien_next_trains" data-view="TransilienNextTrains"  data-unordered="true" data-title="VILLIERS LE BEL GONESSE ARNOUVILLE" data-moreinfo="(R)eal Time - (T)imeTable" style="background-color: #0C5DA5">
       </div>
       <i class="fa fa-subway icon-background-transilien"></i>
    </li>
  </ul>
</div>

## Utilisation

```bash
cd /home/ankorez/smashing-dashboards/mondashboard
sudo smashing start
```

[http://localhost:3030/transilien_next_trains](http://localhost:3030/transilien_next_trains "http://localhost:3030/transilien_next_trains")

Note : **transilien_next_trains** correspond au fichier transilien_next_trains.erb situé dans

```bash
~/smashing-dashboards/mondashboard/dashboards
```

On peut très bien créer son propre fichier .erb et le personnaliser pour ajouter les Widgets qu'on désire.

Source : [https://github.com/Smashing/smashing](https://github.com/Smashing/smashing "https://github.com/Smashing/smashing")

Source : [https://framagit.org/tg/transilien_next_trains](https://framagit.org/tg/transilien_next_trains "https://framagit.org/tg/transilien_next_trains")

### Service

- Création du service smashing

```
nano /etc/init.d/smashing
```

Ajouter

```bash
#!/bin/bash

### BEGIN INIT INFO

# Provides: dashboard

# Required-Start: $remote_fs $syslog

# Required-Stop: $remote_fs $syslog

# Default-Start: 2 3 4 5

# Default-Stop: 0 1 6

# Short-Description: Start daemon at boot time

# Description: Enable service provided by daemon.

### END INIT INFO

# Must be a valid filename

NAME=smashing
DASHING_DIR=/home/ankorez/smashing-dashboards/mondashboard
DAEMON=/usr/local/bin/smashing
PIDFILE="/var/run/smashing.pid"
DAEMON_OPTS="start -d -P $PIDFILE"
GEM_HOME=/var/lib/gems/2.1.0
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
case "$1" in
start)
echo -n "Starting daemon: ${NAME} "
start-stop-daemon --start --quiet --chdir $DASHING_DIR --exec $DAEMON -- $DAEMON_OPTS
echo "."
;;
stop)
echo -n "Stopping daemon: ${NAME} "
start-stop-daemon --stop --quiet --signal 2 --oknodo --pidfile $PIDFILE
echo "."
;;
restart)
start-stop-daemon --stop --quiet --signal 2 --oknodo --retry 30 --pidfile $PIDFILE
start-stop-daemon --start --quiet --chdir $DASHING_DIR --exec $DAEMON -- $DAEMON_OPTS
echo "."
;;
*)
echo "Usage: $1 {start|stop|restart}"
exit 1
esac
exit 0
```

### Crontab

- Ajout d'un crontab au boot

```bash
nano /etc/crontab
```

Ajouter

```
@reboot         root    /etc/init.d/smashing start
```
