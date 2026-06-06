ArrayList<PVector> TS = new ArrayList<PVector>();
ArrayList<Face> TF = new ArrayList<Face>();
HashMap<String, Integer> cacheMilieux;
int lod = 4;

void setup(){
  size(800,400,P3D);
  TS.add(new PVector(999,999,999)); // index 0 bidon (on commence a 1)

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

  // ✅ subdivision UNE SEULE FOIS, ici
  for (int i = 0; i < lod; i++) {
    subDiv();
  }
  println(TS.size() + " sommets, " + TF.size() + " faces");
}

void draw(){
  background(0);
  lights();
  translate(width/2, height/2, 0);
  rotateX(rotX); rotateY(rotY);
  scale(150);
  stroke(255); noFill(); strokeWeight(0.005);

  for (Face f : TF) {              // on ne fait QUE dessiner ici
    PVector a = TS.get(f.p0);
    PVector b = TS.get(f.p1);
    PVector c = TS.get(f.p2);
    beginShape();
    vertex(a.x, a.y, a.z);
    vertex(b.x, b.y, b.z);
    vertex(c.x, c.y, c.z);
    endShape(CLOSE);
  }
}

void subDiv(){
  ArrayList<Face> nouvellesFaces = new ArrayList<Face>();
  cacheMilieux = new HashMap<String, Integer>();
  for (Face f : TF){
    int i0 = f.p0, i1 = f.p1, i2 = f.p2;
    int a = milieu(i0, i2);
    int b = milieu(i0, i1);
    int c = milieu(i1, i2);
    nouvellesFaces.add(new Face(i0, b, a));
    nouvellesFaces.add(new Face(b, i1, c));
    nouvellesFaces.add(new Face(a, b, c));
    nouvellesFaces.add(new Face(a, c, i2));
  }
  TF = nouvellesFaces;
}

int milieu(int i, int j) {
  int min = min(i, j), max = max(i, j);
  String cle = min + "_" + max;
  if (cacheMilieux.containsKey(cle)) return cacheMilieux.get(cle);
  PVector p = PVector.add(TS.get(i), TS.get(j));
  p.mult(0.5);
  p.normalize();
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