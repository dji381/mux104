Point p0, p1, p2, p3;

void setup() {
  size(600, 600);
  p0 = new Point(10, 150);
  p1 = new Point(50, 10);
  p2 = new Point(100, 50);
  p3 = new Point(200, 150);
  strokeWeight(2);
}

void draw() {
  background(255);

  // p1 suit la souris
  p1.x = mouseX;
  p1.y = mouseY;

  // les 4 points de contrôle dans un tableau
  PVector[] ctrl = {
    new PVector(p0.x, p0.y),
    new PVector(p1.x, p1.y),
    new PVector(p2.x, p2.y),
    new PVector(p3.x, p3.y)
  };

  // 1) la courbe de Bézier (noir)
  noFill();
  stroke(0);
  bezier(ctrl[0].x, ctrl[0].y, ctrl[1].x, ctrl[1].y,
         ctrl[2].x, ctrl[2].y, ctrl[3].x, ctrl[3].y);

  // 2) le polygone de contrôle (gris clair)
  stroke(200);
  for (int i = 0; i < ctrl.length - 1; i++)
    line(ctrl[i].x, ctrl[i].y, ctrl[i+1].x, ctrl[i+1].y);

  // 3) les lignes de De Casteljau pour un t qui oscille (bleu)
  float t = (sin(frameCount * 0.02) + 1) / 2;  // t va et vient entre 0 et 1
  stroke(0, 150, 255);
  PVector surLaCourbe = deCasteljau(ctrl, t);

  // 4) le point courant sur la courbe (rouge)
  noStroke();
  fill(255, 0, 0);
  ellipse(surLaCourbe.x, surLaCourbe.y, 8, 8);
}

// Algorithme de De Casteljau récursif.
// Dessine les lignes intermédiaires et renvoie le point de la courbe au paramètre t.
PVector deCasteljau(PVector[] pts, float t) {
  // cas de base : un seul point => c'est le point sur la courbe
  if (pts.length == 1) {
    return pts[0];
  }

  // calcule le niveau suivant : on interpole entre chaque paire de points consécutifs
  PVector[] suivant = new PVector[pts.length - 1];
  for (int i = 0; i < suivant.length; i++) {
    float x = lerp(pts[i].x, pts[i+1].x, t);
    float y = lerp(pts[i].y, pts[i+1].y, t);
    suivant[i] = new PVector(x, y);
  }

  // dessine les lignes de De Casteljau de ce niveau
  for (int i = 0; i < suivant.length - 1; i++) {
    line(suivant[i].x, suivant[i].y, suivant[i+1].x, suivant[i+1].y);
  }

  // récursion sur le niveau suivant
  return deCasteljau(suivant, t);
}

class Point {
  int x, y;
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
