ArrayList<PVector> TS = new ArrayList<PVector>();
ArrayList<Face> TF = new ArrayList();

void setup(){
  size(800,400,P3D);
  noFill();
  lights();
  stroke(255);
  TS.add(new PVector(999,999,999));
  //first face
  TS.add(new PVector(0,0,0));
  TS.add(new PVector(2,0,0));
  TS.add(new PVector(1,2,1));
  TS.add(new PVector(2,0,2));
  TS.add(new PVector(0,0,2));
  TS.add(new PVector(1,-2,1));
  
  TF.add(new Face(new PVector(1,2,3)));
  TF.add(new Face(new PVector(2,4,3)));
  TF.add(new Face(new PVector(4,5,3)));
  TF.add(new Face(new PVector(5,1,3)));
  
  TF.add(new Face(new PVector(1,2,6)));
  TF.add(new Face(new PVector(2,4,6)));
  TF.add(new Face(new PVector(4,5,6)));
  TF.add(new Face(new PVector(5,1,6)));
  

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
class Face{
  float p0, p1, p2;
  Face(PVector points){
    this.p0 = points.x;
    this.p1 = points.y;
    this.p2 = points.z;
  }
}

float rotX = 0, rotY = 0;
void mouseDragged(){
  rotY += (mouseX - pmouseX) * 0.01;
  rotX += (mouseY - pmouseY) * 0.01;
}
