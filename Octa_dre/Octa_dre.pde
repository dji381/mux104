ArrayList<PVector> TS = new ArrayList<PVector>();
ArrayList<Face> TF = new ArrayList();
HashMap<String, Integer> cacheMilieux;
int lod = 4;
void setup(){
  size(800,400,P3D);
  noFill();
  lights();
  stroke(255);
  // octaedre UNITAIRE centre sur l'origine
  TS.add(new PVector( 1, 0, 0)); // 1  equateur
  TS.add(new PVector( 0, 0, 1)); // 2
  TS.add(new PVector( 0, 1, 0)); // 3  apex haut
  TS.add(new PVector(-1, 0, 0)); // 4  equateur
  TS.add(new PVector( 0, 0,-1)); // 5
  TS.add(new PVector( 0,-1, 0)); // 6  apex bas

  TF.add(new Face(1,2,3));
  TF.add(new Face(2,4,3));
  TF.add(new Face(4,5,3));
  TF.add(new Face(5,1,3));
  TF.add(new Face(1,2,6));
  TF.add(new Face(2,4,6));
  TF.add(new Face(4,5,6));
  TF.add(new Face(5,1,6));
  for (int i = 0; i < lod; i++) {
    subDiv();                    // chaque etape : x4 triangles
  }

}
void draw(){
  background(0);
  lights();
  translate(width/2, height/2, 0);  // (1) on se recentre
  rotateX(rotX); rotateY(rotY);
  scale(60);                        // (2) on agrandit (2 unites -> 120 px)

  stroke(255);
  noFill();
  strokeWeight(0.03);               // trait fin car tout est mis a l'echelle x60

  for (Face f : TF) {               // (3) on parcourt TOUTES les faces
    PVector a = TS.get(int(f.p0));
    PVector b = TS.get(int(f.p1));
    PVector c = TS.get(int(f.p2));
    beginShape();
    vertex(a.x, a.y, a.z);
    vertex(b.x, b.y, b.z);
    vertex(c.x, c.y, c.z);
    endShape(CLOSE);
  }

}
// ------------------------------------------------------------
//  2. Une etape de subdivision : chaque triangle -> 4 triangles
//
//          i1
//          /\
//         /  \
//        b----c
//       /\    /\
//      /  \  /  \
//    i0----a----i2
// ------------------------------------------------------------
void subDiv(){
  ArrayList<Face> nouvellesFaces = new ArrayList();
  cacheMilieux = new HashMap<String, Integer>(); // remis a zero a chaque etape
  
  for (Face f : TF){
    int i0 = f.p0, i1 = f.p1, i2 = f.p2;
    int a = milieu(i0, i2);  // milieu normalise des aretes
    int b = milieu(i0, i1);
    int c = milieu(i1, i2);
    
      // 4 nouveaux triangles (cf. schema de Leech)
    nouvellesFaces.add(new Face(i0, b, a));
    nouvellesFaces.add(new Face(b, i1, c));
    nouvellesFaces.add(new Face(a, b, c));
    nouvellesFaces.add(new Face(a, c, i2));
  }
  TF = nouvellesFaces;
}
int milieu(int i, int j) {
  // cle canonique : on trie les indices pour que (i,j) == (j,i)
  int min = min(i, j), max = max(i, j);
  String cle = min + "_" + max;

  if (cacheMilieux.containsKey(cle)) {
    return cacheMilieux.get(cle); // deja calcule -> on reutilise
  }

  PVector p = PVector.add(TS.get(i), TS.get(j));
  p.mult(0.5);        // milieu de l'arete
  p.normalize();      // projection sur la sphere unite (rayon 1)

  int indice = TS.size();
  TS.add(p);
  cacheMilieux.put(cle, indice);
  return indice;
}
class Face {
  int p0, p1, p2;
  Face(int a, int b, int c){ p0=a; p1=b; p2=c; }
}

float rotX = 0, rotY = 0;
void mouseDragged(){
  rotY += (mouseX - pmouseX) * 0.01;
  rotX += (mouseY - pmouseY) * 0.01;
}
