Hitable world;
Camera cam;
int ns = 100;
void setup(){
  size(800,400);
  //camera
  cam = new Camera(  
  new PVector(-2,-1,-1),
  new PVector(4,0,0), //he
  new PVector(0,2,0), //le
  new PVector(0,0,0)
  );
 
  ArrayList<Hitable> list = new ArrayList();
  list.add(new Sphere(new PVector(0,0,-1.0),0.5));
  list.add(new Sphere(new PVector(0,-100.5,-1.0),100.0));
  world = new HitableList(list);
  for(int j = height - 1; j >= 0; j--){
    for (int i = 0; i < width; i++){
      PVector col = new PVector(0, 0, 0);    // accumulateur, remis a zero par pixel
      for (int s = 0; s < ns; s++) {
        float u = ((float)i + random(1)) / (float) width;  
        float v = ((float)j + random(1)) / (float) height;
        Ray r = cam.getRay(u, v);
        col.add(setColor(r, world));         // on accumule
      }
      col.div(ns);  
      col = new PVector(sqrt(col.x), sqrt(col.y), sqrt(col.z));   // éclaircit (gamma)
      // on moyenne
      int ir = (int)(255 * col.x);
      int ig = (int)(255 * col.y);
      int ib = (int)(255 * col.z);
      stroke(ir,ig,ib);
      point(i,height - j);
  }
  }
}
class Camera {
  PVector lowerLeftCorner, horizontal, vertical,origin;
  Camera(PVector lowerLeftCorner, PVector horizontal, PVector vertical, PVector origin){
    this.lowerLeftCorner = lowerLeftCorner.copy();
    this.horizontal = horizontal.copy();
    this.vertical = vertical.copy();
    this.origin = origin.copy();
  }
  Ray getRay(float u, float v){
    PVector dr = new PVector();
     dr.set(lowerLeftCorner).add(PVector.mult(horizontal,u)).add(PVector.mult(vertical,v));
       return new Ray(origin,dr);  
     }
}
PVector randomInUnitSphere() {
  PVector p;
  do {
    // une fléchette au hasard dans le cube [-1, 1]
    p = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
  } while (p.magSq() >= 1.0);   // tombée hors de la boule ? on relance
  return p;
}
PVector setColor(Ray ray, Hitable world) {
  HitRecord rec = new HitRecord();

  if (world.hit(ray, 0.0001, Float.MAX_VALUE, rec)) {
    // on touche un objet -> on fabrique le rebond
    PVector pointToTouch = PVector.add(PVector.add(rec.N, randomInUnitSphere()), rec.P);
    Ray bounce = new Ray(rec.P, PVector.sub(pointToTouch,rec.P));
    // on suit le rebond, en gardant la moitié de la lumière
    return PVector.mult(setColor(bounce, world), 0.5);
  } else {
    // on file dans le ciel -> dégradé (comme avant)
    PVector raydir = ray.direction().copy().normalize();
    float t = 0.5 * (raydir.y + 1.0);
    return PVector.add(PVector.mult(new PVector(1.0, 1.0, 1.0), 1.0 - t),
                       PVector.mult(new PVector(0.5, 0.7, 1.0), t));
  }
}
class Ray{
  PVector A,B;
  Ray(PVector a, PVector b){
    this.A = a.copy();
    this.B = b.copy();
  }
   PVector origin(){
     return this.A;
   }
   PVector direction(){
     return this.B;
   }
   PVector pointAtParameter(float t){
     return PVector.add(A,PVector.mult(B,t));
   }
}
class HitRecord {
  float t;
  PVector P, N;
}
interface Hitable {
  boolean hit(Ray r, float tMin, float tMax,HitRecord rec);
}

class Sphere implements Hitable {
  PVector center;
  float R;
  Sphere(PVector center, float radius) {
    this.center = center.copy();
    this.R = radius;
  }
  boolean hit (Ray r, float tMin, float tMax,HitRecord rec){
    
  PVector OC = PVector.sub(r.origin(), center);
  float a = PVector.dot(r.direction(),r.direction());
  float b = 2.0 * PVector.dot(OC,r.direction());
  float c = PVector.dot(OC,OC) - R * R;
  float delta = b *b - 4 * a * c;
  
  if(delta > 0){
    float temp = (-b - sqrt(delta)) / (2*a);
    if(temp < tMax && temp> tMin){
      rec.t = temp;
      rec.P = r.pointAtParameter(rec.t);
      rec.N = PVector.sub(rec.P, center);
      rec.N.normalize();
      return true;
    }
    temp = (-b + sqrt(delta)) /  (2.0*a);
    if(temp < tMax && temp > tMin){
      rec.t = temp;
      rec.P = r.pointAtParameter(rec.t);
      rec.N = PVector.sub(rec.P, center);
      rec.N.normalize(); 
      return true;
    }
  }
  return false;
}
}

class HitableList implements Hitable{
  ArrayList<Hitable> list;
  HitableList(ArrayList<Hitable> l){
    list = l;
  }
  boolean hit (Ray r, float tMin, float tMax,HitRecord rec){
    HitRecord tempRec = new HitRecord();
    boolean hitAnything = false;
    float closestSoFar = tMax;
    for (int i = 0; i< list.size(); i++){
      boolean hit = list.get(i).hit(r,tMin, closestSoFar, tempRec);
      if(hit){
        hitAnything = true;
        closestSoFar = tempRec.t;
        rec.t = tempRec.t;          
        rec.P = tempRec.P;          
        rec.N = tempRec.N;
      }
    }
    return hitAnything;
  }
}
