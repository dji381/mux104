int xmin = -10, xmax = 10, ymin = -10, ymax = 10;
ArrayList<PVector> TS = new ArrayList();
float[][] zbuffer;
Face f;

void setup(){
  size(600,600);
  zbuffer = new float[width][height];
  for (int i = 0; i < width; i++)
    for (int j = 0; j < height; j++)
      zbuffer[i][j] = Float.MAX_VALUE; // "infiniment loin" au départ
  
  TS.add(new PVector(0,5,5));
  TS.add(new PVector(5,1,5));
  TS.add(new PVector(7,5,5));
  
  f = new Face(0,1,2);
}

void draw(){
  background(255);
  
  // réinitialiser le z-buffer à chaque frame
  for (int i = 0; i < width; i++)
    for (int j = 0; j < height; j++)
      zbuffer[i][j] = Float.MAX_VALUE;
  
  PVector a = worldToScreen(TS.get(f.a));
  PVector b = worldToScreen(TS.get(f.b));
  PVector c = worldToScreen(TS.get(f.c));
  //tri sommet avec le y le haut
  ArrayList<PVector> sortedVertices = new ArrayList<PVector>();
  sortedVertices.add(a);
  sortedVertices.add(b);
  sortedVertices.add(c);
  sortedVertices.sort((p1, p2) -> Float.compare(p1.y, p2.y));
  
  PVector s1 = sortedVertices.get(0); // haut
  PVector s2 = sortedVertices.get(1); // intermédiaire
  PVector s3 = sortedVertices.get(2); // bas
  
  fillTriangle(s1, s2, s3);
}

// Convertit une coordonnée monde en coordonnée écran
PVector worldToScreen(PVector p) {
  float sx = map(p.x, xmin, xmax, 0, width);
  float sy = map(p.y, ymin, ymax, 0, height);
  return new PVector(sx, sy, p.z); // on garde z tel quel
}

void fillTriangle(PVector s1, PVector s2, PVector s3) {
  
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

class Face{
  int a, b, c;
  Face(int a, int b, int c){
    this.a = a;
    this.b = b;
    this.c = c;
  }
}
