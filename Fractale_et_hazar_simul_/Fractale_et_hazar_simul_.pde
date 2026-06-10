int N = 5000;  // nombre de points — fais-le varier !

void setup() {
  size(800, 600);
  background(255);
  dessiner();
}

void draw() {
  // rien ici : on redessine uniquement quand on appuie sur une touche
}

void dessiner() {
  background(255);

  // ----- ligne de séparation -----
  stroke(0);
  line(width/2, 0, width/2, height);

  noStroke();

  // ===== MOITIÉ GAUCHE : distribution UNIFORME =====
  fill(0, 0, 255, 80);  // bleu translucide
  for (int i = 0; i < N; i++) {
    float x = random(0, width/2);
    float y = random(0, height);
    ellipse(x, y, 3, 3);
  }

  // ===== MOITIÉ DROITE : distribution NORMALE =====
  fill(255, 0, 0, 80);  // rouge translucide
  float centreX = width * 3.0/4.0;  // centre de la moitié droite
  float centreY = height / 2.0;
  float ecartTypeX = width / 12.0;  // étalement horizontal
  float ecartTypeY = height / 8.0;  // étalement vertical
  for (int i = 0; i < N; i++) {
    float x = centreX + randomGaussian() * ecartTypeX;
    float y = centreY + randomGaussian() * ecartTypeY;
    ellipse(x, y, 3, 3);
  }

  // texte d'info
  fill(0);
  text("Uniforme  (N=" + N + ")", 20, 20);
  text("Normale  (N=" + N + ")", width/2 + 20, 20);
}

void keyPressed() {
  dessiner();  // on régénère à chaque touche
}
