// =============================================================
//  MUX104 - Exercice 3, partie 1
//  Lecture d'un fichier OBJ minimal (sommets + faces)
// =============================================================

// ---- Structures de stockage --------------------------------

// Liste des sommets. Chaque sommet est un PVector (x, y, z).
ArrayList<PVector> sommets = new ArrayList<PVector>();

// Liste des faces. Chaque face est un tableau d'entiers
// contenant les INDICES des sommets qui la composent.
ArrayList<int[]> faces = new ArrayList<int[]>();
//Bounding volume
float xmin, xmax, ymin, ymax, zmin, zmax;

void setup() {
  size(700, 700);
  // On charge le fichier. dans le dossier
  // "data" de sketch Processing.
  chargerOBJ("eiffel.obj");
  background(0);stroke(250);fill(200);
  findBoundingBox();
  drawXY();
  
}


// ---- La fonction de lecture --------------------------------

void chargerOBJ(String nomFichier) {

  // loadStrings lit tout le fichier et renvoie un tableau
  // où chaque case = une ligne du fichier.
  String[] lignes = loadStrings(nomFichier);

  if (lignes == null) {
    println("ERREUR : fichier introuvable : " + nomFichier);
    return;
  }

  // On parcourt chaque ligne du fichier.
  for (String ligne : lignes) {

    // On découpe la ligne en morceaux séparés par des espaces.
    // Exemple : "v 1.0 2.0 3.0" devient ["v", "1.0", "2.0", "3.0"]
    // trim() enlève les espaces inutiles au début/fin.
    // split("\\s+") découpe sur un ou plusieurs espaces.
    String[] mots = trim(ligne).split("\\s+");

    // Ligne vide : on l'ignore.
    if (mots.length == 0 || mots[0].equals("")) {
      continue;
    }

    // ---- Cas 1 : une ligne de sommet (commence par "v") ----
    if (mots[0].equals("v")) {
      float x = float(mots[1]);
      float y = float(mots[2]);
      float z = float(mots[3]);
      sommets.add(new PVector(x, y, z));
    }

    // ---- Cas 2 : une ligne de face (commence par "f") ------
    else if (mots[0].equals("f")) {

      // Le nombre de sommets de la face = nombre de mots - 1
      // (on enlève le "f" du début).
      int nbCoins = mots.length - 1;
      int[] face = new int[nbCoins];

      for (int i = 0; i < nbCoins; i++) {
        // En OBJ, une face peut s'écrire "f 1/2/3" (sommet/texture/normale).
        // On ne garde que le premier nombre (l'indice du sommet).
        String coin = mots[i + 1].split("/")[0];

        // ATTENTION : OBJ numérote à partir de 1, mais nos
        // ArrayList commencent à 0. On soustrait donc 1.
        face[i] = int(coin) - 1;
      }

      faces.add(face);
    }
  }
}
void findBoundingBox(){
  xmin = xmax = sommets.get(0).x;
  ymin = ymax = sommets.get(0).y;
  zmin = zmax = sommets.get(0).z;
  for (int i = 1; i < sommets.size(); i++){
    float x = sommets.get(i).x, y = sommets.get(i).y, z = sommets.get(i).z;
    if(x < xmin) xmin = x;
    if(x > xmax) xmax = x;
    
    if(y < ymin) ymin = y;
    if(y > ymax) ymax = y;
    
    if(z < zmin) zmin = z;
    if (z > zmax) zmax = z; 
  } 
}
void drawXY(){
  // Pour chaque face, on relie ses sommets par des lignes.
  for (int[] face : faces) {
      float w = xmax - xmin;
      float h = ymax - ymin;
      float aspectRatio =  300 / max(w,h);
      PVector a = sommets.get(face[0]);
      PVector b = sommets.get(face[1]);
      PVector c = sommets.get(face[2]);
    
      float x1 = (a.x - xmin) * aspectRatio;
      float y1 = (ymax - a.y) * aspectRatio;
      
      float x2 = (b.x - xmin) * aspectRatio;
      float y2 = (ymax - b.y) * aspectRatio;
      
      float x3 = (c.x - xmin) * aspectRatio;
      float y3 = (ymax - c.y) * aspectRatio;
      
      line(x1,y1,x2,y2);
      line(x2,y2,x3,y3);
      line(x3,y3,x1,y1);
  }
}
void drawZY() {
  // Cette vue (vue de côté) dessine Z en horizontal et Y en vertical.
  // Donc les étendues qui comptent sont celles de Z et de Y.
  float etendueZ = zmax - zmin;
  float etendueY = ymax - ymin;

  // UNE seule échelle, basée sur la plus grande étendue.
  // La vue occupe une zone de 300px de côté.
  float echelle = 300.0 / max(etendueZ, etendueY);

  // La vue de côté commence à x = 350 à l'écran (à droite).
  float offsetX = 350;

  for (int[] face : faces) {
    PVector a = sommets.get(face[0]);
    PVector b = sommets.get(face[1]);
    PVector c = sommets.get(face[2]);

    // même echelle appliquée à Z et Y -> pas de distorsion
    float z1 = offsetX + (a.z - zmin) * echelle;
    float y1 = (ymax - a.y) * echelle;   // ymax - y inverse le Y

    float z2 = offsetX + (b.z - zmin) * echelle;
    float y2 = (ymax - b.y) * echelle;

    float z3 = offsetX + (c.z - zmin) * echelle;
    float y3 = (ymax - c.y) * echelle;

    line(z1, y1, z2, y2);
    line(z2, y2, z3, y3);
    line(z3, y3, z1, y1);
  }
}
