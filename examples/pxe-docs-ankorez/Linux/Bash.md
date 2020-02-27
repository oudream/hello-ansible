# bash

Coloration syntaxique On modifie le fichier de configuration Du bash pour avoir une coloration.

Pour cela on se rend dans le répertoire de notre utilisateur par défaut puis on édite le fichier de config de son bash (.bashrc) :

```bash
vi ~/.bashrc
```

On décommente la ligne

```bash
**force_color_prompt=yes**
```

On enregistre

On va maintenant remplacer le fichier Du répertoire root par celui-ci pour que le bash Du root ait aussi cette configuration Du bash (on peut aussi remplacer celui d’autres utilisateurs souhaités)

```bash
su
cp /home/manomano/.bashrc ~/.bashrc
```

On resource la config

```
source ~/.bashrc
```
