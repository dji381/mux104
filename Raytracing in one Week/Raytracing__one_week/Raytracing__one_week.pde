PVector lowerLeftCorner, horizontal, vertical,origin;
Hitable world;
void setup(){
  size(400,200);
  //camera
  lowerLeftCorner = new PVector(-2,-1,-1);
  horizontal = new PVector(4,0,0); //he
  vertical = new PVector(0,2,0); //le
  origin = new PVector(0,0,0);//eye
  ArrayList<Hitable> list = new ArrayList();
  list.add(new Sphere(new PVector(0,0,-1),0.5));
  list.add(new Sphere(new PVector(0,-100.5,-1),100));
  world = new HitableList(list);
  for(int j = height - 1; j >= 0; j--){
    for (int i = 0; i < width; i++){
      float u = (float)i / (float) width;
      float v = (float) j / (float) height;
      Ray r = new Ray(origin,PVector.add(PVector.add(lowerLeftCorner, PVector.mult(horizontal,u)),PVector.mult(vertical,v) ) );
      PVector col = setColor(r,world);
      int ir = (int)(255 * col.x);
      int ig = (int)(255 * col.y);
      int ib = (int)(255 * col.z);
      stroke(ir,ig,ib);
      point(i,height - 1 - j);
  }
  }
}
PVector setColor(Ray ray, Hitable world){
   HitRecord rec = new HitRecord();
   if(world.hit(ray,0.0,Float.MAX_VALUE,rec)){
     return PVector.mult(new PVector(rec.N.x + 1.0,rec.N.y + 1.0,rec.N.z + 1.0 ),0.5);
   }else{
    PVector raydir = ray.direction().copy().normalize();
    float t = 0.5 * (raydir.y + 1.0);
    return PVector.add(PVector.mult(new PVector(1.0,1.0,1.0),(1.0-t)), PVector.mult(new PVector(0.5,0.7,1.0),t));
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
    float temp = (-b - sqrt(b*b-a*c)) / a;
    if(temp < tMax && temp> tMin){
      rec.t = temp;
      rec.P = r.pointAtParameter(rec.t);
      rec.N = PVector.sub(rec.P, center);
      rec.N.normalize();
      return true;
    }
    temp = (-b + sqrt(b*b-a*c)) /  a;
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
