# YunoHost

YunoHost est une distribution basée sur Debian GNU/Linux composée, essentiellement, de logiciels libres, ayant pour objectif de faciliter l’auto-hébergement. YunoHost facilite l’installation et l’utilisation d’un serveur personnel. Autrement dit, YunoHost permet d’héberger sur sa machine et chez soi son courrier électronique, son site web, sa messagerie instantanée, son agrégateur de nouvelles (flux RSS), son partage de fichiers, sa seedbox et bien d'autres… Le nom YunoHost vient de l'anglais Y-U-No-Host (“Why you no host?”), signifiant « Pourquoi ne pas t'héberger ? ». Il s'agit d'un jeu de mot issu du mème internet “Y U NO”3.

## DynDNS

- Mettre à jour son nom de domaine

```shell
 yunohost dyndns update
```

## Erreurs

*[Errno 62] [https://dyndns.yunohost.org/test/ankorez.nohost.me](https://dyndns.yunohost.org/test/ankorez.nohost.me "https://dyndns.yunohost.org/test/ankorez.nohost.me") took too long to answer, gave up. dyndns_could_not_check_available*

il faut faire

```
rm /etc/cron.d/yunohost-dyndns
```

Source : [https://yunohost.org/#/](https://yunohost.org/#/ "https://yunohost.org/#/")
