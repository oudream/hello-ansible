# Transmission

Ajouter *ankorez* au groupe transmission-debian ou debian transmission

```shell
sudo usermod -a -G debian-transmission ankorez
```

Changer le propriétaire du répertoire

```shell
sudo chgrp debian-transmission /mnt/transmission
```

Donner l’accès en écriture au groupe

```bash
sudo chmod 770 /mnt/transmission
```

Arreter le service

```bash
sudo service transmission-daemon stop
```

Dernière chose importante pour pouvoir créer des fichiers téléchargés

```bash
sudo nano /etc/transmission-daemon/settings.json
```

modifier la valeur **umask** de *18* à *2*

Démarrer le service

```
sudo service transmission-daemon start
```
