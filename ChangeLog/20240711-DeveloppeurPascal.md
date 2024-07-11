# 20240711 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* modification de l'affichage du temps en limitant à 3 chiffres (donc en ms) après la virgule et s'assurer que nous avons toujours trois chiffres après
* ajout du FPS par défaut (à 30) dans les options du programme et mise à jour des 30 FPS partout ou c'était indiqué en dur
* ajout du FPS dans le projet
* ajout d'un écran de paramétrage des options du projet ouvert pour renseigner les FPS des vidéos du projet (et futures infos)
* remplacement de la valeur de FPS par défaut par celle du projet lors des manipulations sur un projet ouvert.
* ajout du changement du volume de lecture des vidéos sur l'écran du projet (avec stockage en paramètres)
* coupe la lecture de la vidéo lorsqu'on ferme le projet (sinon elle reste en background (au moins le son) jusqu'à en ouvrir un autre)
* suppression de la notion de partie de vidéo dans les projets, les zones à conserver ou virer sont gérées sous forme de marques "de début" jusqu'à la suivante
* ajout de la liste des marques à l'écran pour cocher / décocher les plages à conserver dans la vidéo finale
* ajout d'un bouton pour ajouter une marque à la vidéo
* ajout d'un bouton pour retirer une marque de la vidéo
* implémentation de l'ajout qui fait son job mais la liste des marqueurs ne se réaffiche pas
* implémentation de la suppression d'un marqueur qui fonctionne correctement
* ajout d'un marqueur forcé à 00:00:00,000 de tous les projets (en création ou ouverture) afin d'avoir toujours au moins le segment de la vidéo complète
* tentative (sans succès) de contournement de l'absence d'information lorsque la case à cocher d'un TListBoxItem change de valeur afin de répercuter l'information sur le marqueur concerné en détournant le style associé à l'élément
