int N = 5;
void setup(){
  size(600,600);
  subdiv(0,width,0,height,N);
}
void subdiv(float left, float right, float top, float bottom, int n){
  if (n == 0) return;
  //float x = random(left, right);
  //float y = random(top, bottom);
  float mx = (left + right) / 2;
  float my = (top + bottom) / 2;
 // écart-type proportionnel à la largeur/hauteur du rectangle
  float ecartX = (right - left) / 6.0;
  float ecartY = (bottom - top) / 6.0;

  float x = mx + randomGaussian() * ecartX;
  float y = my + randomGaussian() * ecartY;
  line(left, y, right, y); 
  line(x, top, x, bottom);
  n--;
  //haut gauche
  subdiv(left,x,top,y,n);
  //haut droite
  subdiv(x,right,top,y,n);
  //bas gauche
  subdiv(left,x,y,bottom,n);
  //bas droite
  subdiv(x,right,y,bottom,n);

}
