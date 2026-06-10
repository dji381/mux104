float H = .9;
// 12 sommets approximant l'Hexagone (sens horaire)
PVector[] france = {
  new PVector(300,  80),   // Nord (Dunkerque)
  new PVector(470, 150),   // Nord-Est (Strasbourg)
  new PVector(495, 270),   // Jura / Suisse
  new PVector(470, 400),   // Alpes
  new PVector(400, 470),   // Côte d'Azur
  new PVector(320, 485),   // Méditerranée
  new PVector(265, 500),   // Frontière espagnole
  new PVector(175, 470),   // Pays Basque
  new PVector(160, 360),   // Atlantique (Bordeaux)
  new PVector(110, 285),   // Vendée
  new PVector( 55, 230),   // Pointe de Bretagne
  new PVector(175, 150)    // Cotentin / Normandie
};
void setup(){
  background(255);
  size(600,600,P3D);
  
  // 1) le polygone de base (rouge) : le squelette à 12 côtés
  //stroke(220, 80, 80);
  //for (int i = 0; i < france.length; i++){
  //  PVector a = france[i];
  //  PVector b = france[(i+1) % france.length];   // % referme le polygone
  //  line(a.x, a.y, b.x, b.y);
  //}
  // stroke(0);
  // for (int i = 0; i < france.length; i++){
  //  PVector a = france[i];
  //  PVector b = france[(i+1) % france.length];
  //  subdivFbm(a, b, 10, 10);
  //}

}
void subdivFbm(PVector left, PVector right, float amp,int n){
  if (n == 0){
    line(left.x, left.y, right.x, right.y);
    return; 
  }
 
  float x = (left.x + right.x)/2.0 + amp * randomGaussian();
  float y = (left.y + right.y)/2.0 + amp * randomGaussian();
  PVector milieu = new PVector(x,y);
  float nAmp = amp / pow(2,H);
  
  subdivFbm(left,milieu,nAmp,n-1);
  subdivFbm(milieu,right,nAmp,n-1);
}
