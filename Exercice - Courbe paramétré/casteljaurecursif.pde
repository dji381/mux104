// calcul d'une courbe de Bezier par subdivision (De Casteljau)
// version recursive
// PC mars20

float[] x = {50,150,450,550};
float[] y = {450,50,250,450};
float D;

void setup(){
  size(600,600);
  smooth();
  noFill();
}

void draw(){
 background(0);
 stroke(255, 255, 255);
 strokeWeight(3);
 D = map(mouseX, 0, width, 1, 1000);
 monbezier(x[0], y[0], x[1], y[1], x[2], y[2], x[3], y[3]);
 // pour comparer
 // bezier(x[0], y[0], x[1], y[1], x[2], y[2], x[3], y[3]);
}

void monbezier(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3){
float xl,yl,xh,yh,xr,yr,xlh,ylh,xhr,yhr,xm,ym;
  if (madistance(x0,y0,x3,y3) < D) {
    line(x0,y0,x1,y1);line(x1,y1,x2,y2);line(x2,y2,x3,y3);
  }
  else {
   xl = (x0 + x1)/2; yl = (y0 + y1)/2;
   xr = (x2 + x3)/2; yr = (y2 + y3)/2;
   xh = (x1 + x2)/2; yh = (y1 + y2)/2;
   xlh = (xl + xh)/2; ylh = (yl + yh)/2;
   xhr = (xh + xr)/2; yhr = (yh + yr)/2;
   xm = (xlh + xhr)/2; ym = (ylh + yhr)/2;
   stroke(255, 0, 0);
   // la partie gauche en rouge
   monbezier(x0,y0,xl,yl,xlh,ylh,xm,ym);
   stroke(0,0,255);
   // la partie droite en bleu
   monbezier(xm,ym,xhr,yhr,xr,yr,x3,y3);
  }
}

float madistance(float x0, float y0, float x1, float y1) {
  return sqrt((x0-x1)*(x0-x1)+(y0-y1)*(y0-y1));
}
    
  
