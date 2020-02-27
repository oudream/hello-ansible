# BIND9

Mise en place de log dans bind Il peut être utile de logguer ce que fait notre bon vieux serveur DNS .

Ajouter un nouvel include à la conf bind

```bash
include "/etc/bind/log.conf";
```

Contenu du fichier log.conf

```
cat /etc/bind/log.conf
logging {
channel "requetes" {
file "/var/log/bind/queries.log" versions 0 size 10m;
print-time yes;
print-category yes;
};
category queries { "requetes"; };
channel "securite" {
file "/var/log/bind/securite.log" versions 0 size 5m;
print-category yes;
print-severity yes;
print-time yes;
};
category security { "securite"; };
channel "global" {
file "/var/log/bind/global.log" versions 0 size 5m;
print-category yes;
print-severity yes;
print-time yes;
};
category general { "global"; };
channel "configuration" {
file "/var/log/bind/config.log" versions 0 size 5m;
print-category yes;
print-severity yes;
print-time yes;
};
category config { "configuration"; };
};
```

Channel : Correspond à un nom qui va être associer à une categorie Category : Contrairement au channel , il existe un certains nombres de categorie prédéfinies vous pouvez voir la liste sur ce site :

[http://www.zytrax.com/books/dns/ch7/logging.html](http://www.zytrax.com/books/dns/ch7/logging.html "http://www.zytrax.com/books/dns/ch7/logging.html")

Vous pouvez à la place d’utiliser le paramètres size utiliser la rotation de log classique

```
/var/log/bind/*.log {
weekly
missingok
rotate 10
compress
delaycompress
create 775 root bind
postrotate
/etc/init.d/bind9 reload > /dev/null
endscript
}
```

Cela vous permettra de mieux diagnostiquer les éventuels problèmes que vous obtenez sur vos serveurs DNS .
