Camera cam;
Sphere s;

void setup(){
  size(800,400);
   background(0);
   
  cam = new Camera(
    new PVector(0, 0, 0),    // R
    new PVector(0, 0, -2),   // P  (on regarde vers la sphere)
    new PVector(0, 1, 0),    // H  (le haut = +Y)
    2.0,                     // D
    4.0 
  );
  
  s = new Sphere(0,0,-2,.5);
  
  for (int col = 0; col < width; col ++){
    for (int row = 0; row < height; row ++){
      PVector pixel3D = cam.pixelTo3D(col,row);
      PVector rayDir = PVector.sub(pixel3D, cam.O); 
      float t = s.intersect(cam.O,rayDir);
      if(t >= 0){
        stroke(255);
        point(col,row);
      }
    }
  }
 
}
class Camera {
  PVector R,P,H,N,U,V,O;
  float D, Le, He;
  
  Camera(PVector R,PVector P,PVector H, float D, float Le ){
    this.R = R.copy();
    this.P = P.copy();
    this.H = H.copy();
    this.D = D;
    this.Le = Le;
    
    N = PVector.sub(this.P,this.R);
    N.normalize();
    
    float s = PVector.dot(H,N);
    V = PVector.sub(H,PVector.mult(N,s));
    V.normalize();
    
    U = N.cross(V);
    
    O = PVector.sub(R,PVector.mult(N,D));
    
    He = Le * height / width; 
  }
   PVector pixelTo3D(int col, int row){
      float px = Le * col / width - Le /2;
      float py = He / 2 -  He * row / height;
  
      PVector p = R.copy();
      p.add(PVector.mult(U,px));
      p.add(PVector.mult(V,py));
      return p;
  }
}
  class Sphere {
    float R;
    PVector pos;
    Sphere(float x, float y, float z, float R){
      pos = new PVector(x,y,z);
      this.R = R;
    }
    
    float intersect(PVector O, PVector rayDir){
      PVector OminusPos = PVector.sub(O,pos);
      float A = rayDir.dot(rayDir);
      float B = 2 * rayDir.dot(OminusPos);
      float C = OminusPos.dot(OminusPos) - R * R;
      
      float delta = B * B - 4 * A * C;
      if (delta < 0) return -1;
      
      float t1 = (-B - sqrt(delta)) / (2 * A);
      float t2 = (-B + sqrt(delta)) / (2 * A);
      if (t1 > 0) return t1;            
      if (t2 > 0) return t2;
      
      return -1;
    }
  }
