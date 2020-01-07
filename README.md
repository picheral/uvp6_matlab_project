# uvp6_matlab_project
Outils Matlab associés à UVP6

Ce projet contient les codes matlab utilisés pour le développement de l'uvp6, notamment lors des tests, caractérisations et analyses de résultats.

## installation
Les codes tournent avec Matlab 9.7 et utilisent les packages suivant:
- Curve Fitting Toolbox 3.5.10
- Image Processing Toolbox 11.0
- Statistics and Machine Learning Toolbox 11.6

Lors de l'ouverture du projet, le path est automatiquement atualisé pour l'utilisation des codes. Est ajouté la racine du projet et les sous répertoires.

## description du projet

- *Camera_adjustment_MTF_adjust_4_mtf.m*

  Outil de reglage du focus de la caméra
  
- *Camera_caracterisation_XXXXXXXX.mlx*

  analyse de la caractérisation du focus de la caméra
  
- *Reglages_verrine_ho.m*

  outil de réglage du faisceau des verrines HO
  
- *uvp6_concatenation_fichiers_data.m*

  outil de concatenation de fichiers de données uvp6
  
- *uvp6_make_base_from_data_file_n_auto.m*

  prétraitement des données instrumentales

- **overexposure_study**

  étude de la surexposition. Pour une particule d'une taille donnée, calcule le poucentage de lignes du capteur surexposées pour différents nombres de lignes analysées.

- **Traitement_données_projets**

  Scripts pour traiter les données des différents projets

- **Ressources_partagées**

  Fonctions communes utilisées par différents scripts, notamment ce qui est lié à sfrmat3, fonction d'analyse des images de caméra.

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
