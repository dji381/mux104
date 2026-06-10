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
float[][] zbuffer;
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
//Lumiere
Light lumiere;
void setup() {
  size(700, 700);
  lumiere = new Light();
  // On charge le fichier. dans le dossier
  // "data" de sketch Processing.
  chargerOBJ("bunny.obj");
  zbuffer = new float[width][height];
  for (int i = 0; i < width; i++)
    for (int j = 0; j < height; j++)
      zbuffer[i][j] = Float.MAX_VALUE; // "infiniment loin" au départ[i][j] = Float.MAX_VALUE;
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
  background(0);
  
}
void draw(){
    // réinitialiser le z-buffer à chaque frame
  for (int i = 0; i < width; i++)
    for (int j = 0; j < height; j++)
      zbuffer[i][j] = Float.MAX_VALUE;
      
 theta = radians(mouseX);
 phi = radians(mouseY);
 background(0);
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
    
    
    PVector col = PVector.mult(face.col,face.lambert);
    fill(col.x,col.y,col.z);
    stroke(col.x,col.y,col.z);
    triangle(px_a, py_a, px_b, py_b,px_c, py_c);
    
    //fillTriangle(new PVector(px_a,py_a,za),new PVector(px_b,py_b,zb),new PVector(px_c,py_c,zc));
    //line(px_a, py_a, px_b, py_b);
    //line(px_b, py_b, px_c, py_c);
    //line(px_c, py_c, px_a, py_a); 
    }

  }
  popMatrix();
}

void fillTriangle(PVector s1, PVector s2, PVector s3) {
  // aire signée à l'écran → ignorer les lamelles
  float aire = (s2.x-s1.x)*(s3.y-s1.y) - (s3.x-s1.x)*(s2.y-s1.y);
  if (abs(aire) < 1) return;
    // trier par Y croissant (s1 = haut, s3 = bas)
  PVector[] v = {s1, s2, s3};
  for (int i = 0; i < 2; i++)
    for (int j = i + 1; j < 3; j++)
      if (v[j].y < v[i].y) { PVector tmp = v[i]; v[i] = v[j]; v[j] = tmp; }
  s1 = v[0]; s2 = v[1]; s3 = v[2];
  
  // PARTIE HAUTE : de s1.y à s2.y
  for (int y = (int)s1.y; y < (int)s2.y; y++) {
    PVector pLong  = interpEdge(s1, s3, y); // arête longue s1->s3
    PVector pShort = interpEdge(s1, s2, y); // arête courte s1->s2
    scanLine(y, pLong, pShort);
  }
  
  // PARTIE BASSE : de s2.y à s3.y
  for (int y = (int)s2.y; y <= (int)s3.y; y++) {
    PVector pLong  = interpEdge(s1, s3, y); // arête longue s1->s3
    PVector pShort = interpEdge(s2, s3, y); // arête courte s2->s3 (changement)
    scanLine(y, pLong, pShort);
  }
}

// Interpole le long d'une arête A->B à la hauteur y
// Renvoie un PVector où x = position X, z = profondeur
PVector interpEdge(PVector A, PVector B, float y) {
  if (B.y == A.y) return new PVector(A.x, y, A.z); // arête horizontale
  
  float t = (y - A.y) / (B.y - A.y);   // proportion verticale (0 à 1)
  float x = A.x + t * (B.x - A.x);     // X interpolé
  float z = A.z + t * (B.z - A.z);     // Z interpolé en même temps
  
  return new PVector(x, y, z);
}

// Colorie une ligne horizontale, en interpolant Z entre les deux bords
void scanLine(int y, PVector p1, PVector p2) {
  if (y < 0 || y >= height) return;   // garde verticale
  
  // déterminer gauche (a) et droite (b) selon X
  PVector left  = (p1.x < p2.x) ? p1 : p2;
  PVector right = (p1.x < p2.x) ? p2 : p1;
  
  float xa = left.x,  za = left.z;
  float xb = right.x, zb = right.z;
  
  for (int x = (int)xa; x <= (int)xb; x++) {
    if (x < 0 || x >= width) continue;  // garde horizontale
    
    float t = (xb == xa) ? 0 : (x - xa) / (xb - xa);
    float zp = za + t * (zb - za);   // Z interpolé pour ce pixel
    
    // --- Z-Buffer ---
    if (zp < zbuffer[x][y]) {   // ce pixel est plus proche ?
      zbuffer[x][y] = zp;       // on mémorise sa profondeur
      point(x, y);              // on le colorie
    }
  }
}
class Face {
  int a, b, c;
  float theta;
  PVector normal;
  PVector col = new PVector(205,100,0);
  float intensite;
  float lambert;
  float Ks = 2; // Intensité speculaire
  float Kd = 1.0; // Coef de reflexion diffuse
  float n = 20;
  Face(int a, int b, int c){
    this.a = a;
    this.b = b;
    this.c = c;
  }
  void calcNormal(){
    PVector p1 = sommets.get(a);
    PVector p2 = sommets.get(b);
    PVector p3 = sommets.get(c);
    PVector P = PVector.sub(p2,p1);
    PVector Q = PVector.sub(p3,p1);
    normal = P.cross(Q);
    normal.normalize();
    this.theta = PVector.dot(normal,PVector.sub(Oprim,p1));
    
    //---loi de lambert ---
    PVector S = lumiere.lumiere.copy();
    float cosAngle = PVector.dot(normal,S);
    cosAngle = max(0, cosAngle);
    this.intensite = Kd * cosAngle;
    
    //---Phong----
    // spéculaire : rayon réfléchi S' = 2(N·S)N - S
    PVector Sp = PVector.sub(PVector.mult(normal, 2 * PVector.dot(normal,S)), S);
    PVector viewDir = PVector.sub(Oprim,p1);
    float spec = Ks * pow(max(0,PVector.dot(Sp, viewDir)),n);
    this.lambert= intensite + spec;
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
class Light{
  PVector lumiere = new PVector(0, 0, 1); // direction de la lumière
  float Ip = 255;  // intensité de la source
  
  Light(PVector dirLight, float Ip){
    this.lumiere = dirLight;
    this.Ip = Ip;
  }
  Light(){}
}
