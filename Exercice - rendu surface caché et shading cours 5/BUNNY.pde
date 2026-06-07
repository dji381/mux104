// =============================================================
//  MUX104 - Exercice 3, partie 1
//  Lecture d'un fichier OBJ minimal (sommets + faces)
// =============================================================

// ---- Structures de stockage --------------------------------

// Liste des sommets. Chaque sommet est un PVector (x, y, z).
ArrayList<PVector> sommets = new ArrayList<PVector>();

// Liste des faces. Chaque face est un tableau d'entiers
// contenant les INDICES des sommets qui la composent.
ArrayList<Face> faces = new ArrayList<Face>();

//camera
float theta = radians(45);
float phi = radians(45); 
float R = 1.3;
float D = 20;
PVector Oprim = new PVector(); //position camera

//// dimension de l'ecran en coord scene, devraient etre dans un objet camera 
float minx = -2;
float maxx = 2;
float miny = -2;
float maxy = 2;

void setup() {
  size(700, 700);
  // On charge le fichier. dans le dossier
  // "data" de sketch Processing.
  chargerOBJ("bunny.obj");
  // calcul barycentre de l'objet
  float sx = 0;
  float sy = 0;
  float sz = 0;
  for (int s=0;s<sommets.size();s++){ 
   sx += sommets.get(s).x;
   sy += sommets.get(s).y;
   sz += sommets.get(s).z;
  }
  sx = sx/sommets.size();sy = sy/sommets.size();sz = sz/sommets.size();
  // translater le barycentre a l'origine du repere scene
  for (int s=0;s<sommets.size();s++){ 
   sommets.get(s).x -= sx;
   sommets.get(s).y -= sy;
   sommets.get(s).z -= sz;
  }
  background(0);stroke(250);fill(200);
  
}
void draw(){
 theta = radians(mouseX);
 phi = radians(mouseY);
 background(0);stroke(250);fill(200);
 calcOprim();
 drawOBJ();
}
void calcOprim(){
  Oprim.x = R* cos(theta)* cos(phi);
  Oprim.y = R * sin(theta) * cos(phi);
  Oprim.z = R * sin(phi);
}
void drawOBJ() {
  // On se place au centre de la fenêtre et on agrandit,
  // car la projection perspective donne de petites valeurs.
  pushMatrix();
  strokeWeight(1.0 / 300);        // garde un trait fin malgré le scale

  for (Face face : faces) {
    PVector a = sommets.get(face.a);
    PVector b = sommets.get(face.b);
    PVector c = sommets.get(face.c);
    face.calcNormal();
    if(face.theta > 0){
          // --- étape 1 : repère observateur ---
    float xa = -a.x * sin(theta) + a.y * cos(theta);
    float ya = -a.x * cos(theta) * sin(phi) - a.y * sin(theta) * sin(phi) + a.z * cos(phi);
    float za = -a.x * cos(theta) * cos(phi) - a.y * sin(theta) * cos(phi) - a.z * sin(phi) + R;

    float xb = -b.x * sin(theta) + b.y * cos(theta);
    float yb = -b.x * cos(theta) * sin(phi) - b.y * sin(theta) * sin(phi) + b.z * cos(phi);
    float zb = -b.x * cos(theta) * cos(phi) - b.y * sin(theta) * cos(phi) - b.z * sin(phi) + R;

    float xc = -c.x * sin(theta) + c.y * cos(theta);
    float yc = -c.x * cos(theta) * sin(phi) - c.y * sin(theta) * sin(phi) + c.z * cos(phi);
    float zc = -c.x * cos(theta) * cos(phi) - c.y * sin(theta) * cos(phi) - c.z * sin(phi) + R;

    // sécurité : on saute la face si un point est derrière l'observateur
    if (za <= 0 || zb <= 0 || zc <= 0) continue;

    // --- étape 2 : projection perspective ---
    float px_a = D * xa / za;
    float py_a = D * ya / za;
    float px_b = D * xb / zb;
    float py_b = D * yb / zb;
    float px_c = D * xc / zc;
    float py_c = D * yc / zc;
    
    //---remap ecran -----
    
    px_a = map(px_a,minx,maxx, 0, width);
    py_a = map(py_a, miny, maxy,height,0);
    
    px_b = map(px_b,minx,maxx, 0, width);
    py_b = map(py_b, miny, maxy,height,0);
    
    px_c = map(px_c,minx,maxx, 0, width);
    py_c = map(py_c, miny, maxy,height,0);
    line(px_a, py_a, px_b, py_b);
    line(px_b, py_b, px_c, py_c);
    line(px_c, py_c, px_a, py_a);   // ← corrigé (referme le triangle)
    }

  }
  popMatrix();
}

class Face {
  int a, b, c;
  float theta;
  PVector normal;
  Face(int a, int b, int c){
    this.a = a;
    this.b = b;
    this.c = c;
    this.calcNormal();
  }
  void calcNormal(){
    PVector p1 = sommets.get(a);
    PVector p2 = sommets.get(b);
    PVector p3 = sommets.get(c);
    PVector P = PVector.sub(p1,p2);
    PVector Q = PVector.sub(p3,p1);
    normal = P.cross(Q);
    normal.normalize();
    this.theta = PVector.dot(normal,PVector.sub(Oprim,p1));
  }
  
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

      faces.add(new Face(face[0],face[1],face[2]));
    }
  }
}
