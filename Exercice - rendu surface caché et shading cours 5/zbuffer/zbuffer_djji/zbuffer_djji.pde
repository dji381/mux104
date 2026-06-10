float xmin, xmax, ymin, ymax;
ArrayList<PVector> TS = new ArrayList();
ArrayList<Face> faces = new ArrayList();
float[][] zbuffer;
void setup(){
  size(600,600);
  chargerOBJ("bunny.obj");
  calculerBornes();
  zbuffer = new float[width][height];
}
void draw(){
   background(255);
    for (int i = 0; i< width; i++)
      for (int j = 0; j < height; j++)
        zbuffer[i][j] = Float.MAX_VALUE; // "infiniment loin" au départ
    
    for(Face face: faces){
      zBuffer(face);
    } 
    
}
void calculerBornes() {
  xmin = Float.MAX_VALUE; xmax = -Float.MAX_VALUE;
  ymin = Float.MAX_VALUE; ymax = -Float.MAX_VALUE;
  for (PVector p : TS) {
    if (p.x < xmin) xmin = p.x;
    if (p.x > xmax) xmax = p.x;
    if (p.y < ymin) ymin = p.y;
    if (p.y > ymax) ymax = p.y;
  }
}
void zBuffer(Face f){
  PVector a = worldToPx(TS.get(f.a));
  PVector b = worldToPx(TS.get(f.b));
  PVector c = worldToPx(TS.get(f.c));
  
  ArrayList<PVector> sortedVert = new ArrayList();
  sortedVert.add(a);
  sortedVert.add(b);
  sortedVert.add(c);
  
  sortedVert.sort((p1,p2) -> Float.compare(p1.y,p2.y));
  
  fillTriangle(sortedVert.get(0),sortedVert.get(1),sortedVert.get(2));
}

void fillTriangle(PVector a,PVector b,PVector c){
  
  //partie haute a -> b
  for (int i = (int)a.y; i < b.y; i++){
    PVector pLong = interpPoint(a,c,i);
    PVector pShort = interpPoint(a,b,i);
    scanline(i, pLong, pShort);
  } 
  
  //partie haute b -> c
  for (int i = (int)b.y; i <= c.y; i++){
    PVector pLong = interpPoint(a,c,i);
    PVector pShort = interpPoint(b,c,i); 
    scanline(i, pLong, pShort);
  } 
}
PVector interpPoint(PVector a, PVector b, int y){
  float t = (a.y == b.y) ? 0 : map(y, a.y, b.y, 0, 1);
  float x = lerp(a.x, b.x, t);
  float z = lerp(a.z, b.z, t);
  return new PVector(x, y, z);
}
void scanline(int y, PVector a, PVector b){
  if (y < 0 || y >= height) return;
  
  PVector left  = a.x < b.x ? a : b;
  PVector right = a.x < b.x ? b : a;
  
  for (int x = (int)left.x; x <= right.x; x++){
    if (x < 0 || x >= width) continue;
    
    // si les deux bords sont au même X, pas d'interpolation possible
    float t = (right.x == left.x) ? 0 : map(x, left.x, right.x, 0, 1);
    float z = lerp(left.z, right.z, t);
    
    if (z < zbuffer[x][y]){
      zbuffer[x][y] = z;
      point(x, y);
    }
  }
}

PVector worldToPx(PVector p){
  float x = map(p.x,xmin,xmax, 0, width );
  float y = map(p.y, ymin, ymax, height,0);
  return new PVector(x,y,p.z);
}
class Face{
  int a, b, c;
  Face(int a, int b, int c){
    this.a = a;
    this.b = b;
    this.c = c;
  }
}

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
      TS.add(new PVector(x, y, z));
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
