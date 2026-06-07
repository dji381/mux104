// navigateur 3D elementaire v3
// chargement de fichier OBJ *avec* placement dans la scene
// *coloriage a plat* 

// position de la source de lumiere
float LUM[] = {100,100.0,100.0};

// position de l'observateur, devraient etre dans un objet camera   
float R = 20;
float theta = 0;
float phi = 0 ;
// distance de l'ecran, devraient etre dans un objet camera  
float D = 20;
// dimension de l'ecran en coord scene, devraient etre dans un objet camera 
float minx = -2;
float maxx = 2;
float miny = -2;
float maxy = 2;
// variables diverses, devraient etre dans un objet camera 
float sthe,cthe,sphi,cphi,x,y,z,xx,yy,zz;
float px,py,pz,qx,qy,qz,nn,xobs,yobs,zobs;

// table des sommets et des faces

class Sommet {
  float x,y,z;
  float xp,yp; // coordonnees 2D
  Sommet(float px, float py, float pz){x=px;y=py;z=pz;}
  void projeter() {
   float xx = -x*sthe +y*cthe;
   float yy = -x*cthe*sphi -y*sthe*sphi +z*cphi; 
   float zz = -x*cthe*cphi -y*sthe*cphi -z*sphi +R;
   xp = D*xx/zz;
   yp = D*yy/zz;
   xp = map(xp, minx, maxx, 0, width);
   yp = map(yp, miny, maxy, height, 0);
  }
}  
ArrayList<Sommet> TS = new ArrayList<Sommet>();

class Face {
  int v1,v2,v3; //index des sommets de la face
  float nx,ny,nz; // vecteur normale de la face
  float vis; //test de visibilite
  float intensite; //intensite pour le coloriage a plat
  Face(int p1, int p2, int p3){v1=p1;v2=p2;v3=p3;}
  void calculeNormale(){
   float px=TS.get(v2).x-TS.get(v1).x;
   float py=TS.get(v2).y-TS.get(v1).y;
   float pz=TS.get(v2).z-TS.get(v1).z;
   float qx=TS.get(v3).x-TS.get(v1).x;
   float qy=TS.get(v3).y-TS.get(v1).y;
   float qz=TS.get(v3).z-TS.get(v1).z;
   nx=py*qz-qy*pz;
   ny=pz*qx-qz*px;
   nz=px*qy-qx*py;
   nn=sqrt(nx*nx+ny*ny+nz*nz);
   nx/=nn;ny/=nn;nz/=nn;
  }
  void calculeVisibilite(){
   float px=xobs-TS.get(v1).x;
   float py=yobs-TS.get(v1).y;
   float pz=zobs-TS.get(v1).z;
   vis=px*nx+py*ny+pz*nz;
  }
  void calculeIntensite(){
   float px=LUM[0]-TS.get(v1).x;
   float py=LUM[1]-TS.get(v1).y;
   float pz=LUM[2]-TS.get(v1).z;
   float nn=sqrt(px*px+py*py+pz*pz);
   px/=nn;py/=nn;pz/=nn;
   intensite = px*nx+py*ny+pz*nz; /* entre -1 et +1 */
   intensite = (intensite+1)/2; /* valeur finale entre 0 et 1 */
  }
}
ArrayList<Face> TF = new ArrayList<Face>();

void setup(){
  size(600,600);
  LireFichierOBJ("bunny.obj"); R=1.3;
  //LireFichierOBJ("cassini.obj"); R=200;
  //LireFichierOBJ("eiffel.obj"); R=1000;
  //LireFichierOBJ("Guerilla.obj"); R=500;
  //LireFichierOBJ("tessel4.obj"); R=20;
  println("nombre de sommets "+TS.size());
  println("nombre de faces "+TF.size());
   // calcul des normales des faces
  for (int f=0;f<TF.size();f++){ 
   TF.get(f).calculeNormale();
  }
  // calcul barycentre de l'objet
  float sx = 0;
  float sy = 0;
  float sz = 0;
  for (int s=0;s<TS.size();s++){ 
   sx += TS.get(s).x;
   sy += TS.get(s).y;
   sz += TS.get(s).z;
  }
  sx = sx/TS.size();sy = sy/TS.size();sz = sz/TS.size();
  // translater le barycentre a l'origine du repere scene
  for (int s=0;s<TS.size();s++){ 
   TS.get(s).x -= sx;
   TS.get(s).y -= sy;
   TS.get(s).z -= sz;
  }
}

void draw(){
 theta = map(mouseX,0,width,-PI,PI);
 phi = map(mouseY,0,height,+PI/2,-PI/2);
 // coord. cartesiennes de l'observateur 
 sthe=sin(theta);
 cthe=cos(theta);
 sphi=sin(phi);
 cphi=cos(phi);
 xobs= R*cthe*cphi;
 yobs= R*sthe*cphi;
 zobs= R*sphi;
 // calcul des visibilites
 for (int f=0;f<TF.size();f++){ 
   TF.get(f).calculeVisibilite();
 }
 // calcul des intensites
 for (int f=0;f<TF.size();f++){ 
   TF.get(f).calculeIntensite();
 }
 // dessin scene
 background(117,160,219);
 for (int f=0;f<TF.size();f++){ 
  Sommet v1 = TS.get(TF.get(f).v1);
  Sommet v2 = TS.get(TF.get(f).v2);
  Sommet v3 = TS.get(TF.get(f).v3);
  // projection perspective
  v1.projeter();
  v2.projeter();
  v3.projeter();
  // trace tenant compte de la visibilite
  if  (TF.get(f).vis>0) { 
    fill(TF.get(f).intensite*255);
    stroke(TF.get(f).intensite*255);
    triangle(TS.get(TF.get(f).v1).xp,TS.get(TF.get(f).v1).yp, 
             TS.get(TF.get(f).v2).xp,TS.get(TF.get(f).v2).yp, 
             TS.get(TF.get(f).v3).xp,TS.get(TF.get(f).v3).yp);
  }
 }
}

void LireFichierOBJ(String nomFichier){
 String lines[] = loadStrings(nomFichier);
 for (int i=0; i < lines.length; i++) {
  String[] vals = splitTokens(lines[i]);
  //println(i,vals.length);
  if (vals.length == 0) continue;
  //if (vals[0].equals("#")) continue;
  if (vals[0].equals("v")) {
    float x = float(vals[1]);
    float y = float(vals[2]);
    float z = float(vals[3]);
    TS.add(new Sommet(x,y,z));
  }
  if (vals[0].equals("f")) {
    // on enleve 1 car le obj commence au rang 1 
    String[] v1 = split(vals[1],'/');
    int iv1 = int(v1[0])-1;
    String[] v2 = split(vals[2],'/');
    int iv2 = int(v2[0])-1;
    String[] v3 = split(vals[3],'/');
    int iv3 = int(v3[0])-1;
    TF.add(new Face(iv1,iv2,iv3));
  }
 }
}
