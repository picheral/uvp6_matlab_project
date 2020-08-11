# uvp6_matlab_project
Outils Matlab associés à UVP6

Ce projet contient les codes matlab utilisés pour le développement de l'uvp6, notamment lors des tests, caractérisations et analyses de résultats.

## installation
Les codes tournent avec Matlab 9.7 et utilisent les packages suivant:
- Curve Fitting Toolbox 3.5.10
- Image Processing Toolbox 11.0
- Statistics and Machine Learning Toolbox 11.6

Lors de l'ouverture du projet, le path est automatiquement actualisé pour l'utilisation des codes. Est ajouté la racine du projet et les sous répertoires.

## description du projet

- **Intercalibrage**

  Scripts et fonctions pour l'intercalibrage des instruments et la création du rapport. Script pour la création de thresholds.

- **Ressources_partagees**

  Fonctions communes utilisées par différents scripts, notamment ce qui est lié à sfrmat3 (fonction d'analyse des images de caméra), les fits, le calcul du score, la qualité, les I/O, les modifications des bases pour les deux instruments.
  
- **UVP5_mise_base**

  Mise en base des données UVP5.
  
- **UVP6_correction_zonale**

  Création des matrices de correction zonale. Analyse de la correction zonale.
  
- **UVP6_overexposure_study**

  étude de la surexposition. Pour une particule d'une taille donnée, calcule le poucentage de lignes du capteur surexposées pour différents nombres de lignes analysées.

- **UVP6_traitement_donnees_projets**

  Scripts pour traiter les données des différents projets: mise en base, concatenation, calibration horloge et profondeur.
  
- **UVP_reglages_caractérisations**

  Scripts pour le réglage des instruments: réglage des verrines, du focus, de l'ouverture,...

- **resources**

  fichiers projet de matlab


# bonnes pratiques de git
- gitignore : fichier listant les types de fichiers à exclure du suivi de git. Doit être inclu dans git **seulement** les fichiers de codes (ou les petits fichiers textes)
- commit : toujours mettre un commentaire. Le commit est seulement local.
- push : ne pas oublier de pusher pour mettre à jour le dépot github, après un commit
- branche : toujours créer une branche pour faire une modif
- master : ne **jamais** comiter directement sur master
- merger les branches : merger depuis github afin d'assurer une bonne traçabilité
- gestion local : toujours vérifier que les branches locales sont à jour avant de les modifier (pull), **notamment master**

# bonnes pratiques de matlab project
Les codes font partie d'un projet matlab qui aide à laur gestion.

Avant de lancer un code, il est impératif d'ouvrir le projet matlab (ouvrir le fichier \*.prj). Le path sera automatiquement updaté pour faire tourner les codes. La fenêtre projet permet de vérifier les fichiers/dossiers suivis par matlab project et git.

Il est recommandé d'effectuer les actions de refactoring sur les dossiers/fichiers (déplacer, supprimer, renomer,...) dans la fenêtre projet. Ainsi ces changements seront bien pris en compte par Matlab project et git.
