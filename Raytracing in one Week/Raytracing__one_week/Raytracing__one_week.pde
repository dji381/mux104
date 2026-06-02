PVector lowerLeftCorner, horizontal, vertical,origin;

void setup(){
  size(400,200);
  //camera
  lowerLeftCorner = new PVector(-2,-1,-1);
  horizontal = new PVector(4,0,0); //he
  vertical = new PVector(0,2,0); //le
  origin = new PVector(0,0,0);//eye
  
  for(int j = height - 1; j >= 0; j--){
    for (int i = 0; i < width; i++){
      float u = (float)i / (float) width;
      float v = (float) j / (float) height;
      Ray r = new Ray(origin,PVector.add(PVector.add(lowerLeftCorner, PVector.mult(horizontal,u)),PVector.mult(vertical,v) ) );
      PVector col = setColor(r);
      int ir = (int)(255 * col.x);
      int ig = (int)(255 * col.y);
      int ib = (int)(255 * col.z);
      stroke(ir,ig,ib);
      point(i,height - 1 - j);
  }
  }
}
PVector setColor(Ray ray){
  PVector raydir = ray.direction().copy().normalize();
  float t = 0.5 * (raydir.y + 1.0);
  return PVector.add(PVector.mult(new PVector(1.0,1.0,1.0),(1.0-t)), PVector.mult(new PVector(0.5,0.7,1.0),t));
  
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
