# 20240713 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* mise à jour des dépendances
* adaptation de la zone de changement de volume pour un affichage correct
* correction de l'alimentation de la liste des marqueurs de temps lorsqu'on en ajoute un (la fonction d'ajout ne la retournait pas)
* nettoyage des blocs de vidage et alimentation de la list des marqueurs de temps
* corrections diverses sur l'affichage
* traitement des messages d'avertissement et conseil du compîlateur pour les éliminer (variables déclarés non utilisées ou utilisées sans alimentation)
* correction des valeurs affichées dans la liste des temps (en secondes et non nanosecondes)
* interception du changement de valeur de la checkbox associée aux éléments de liste pour répercuter leur état au niveau des marques dans le projet
* ajout d'un positionnement de la vidéo sur les horaires des marques sur lesquelles on peut cliquer
* mise en place de la file d'attente et du processus de gnération des vidéos via FFmpeg
* ajout du bouton et de l'option de menu d'export des vidéos à partir du projet en cours
* traitement de l'ajout dans le file d'attente des projets à exporter
