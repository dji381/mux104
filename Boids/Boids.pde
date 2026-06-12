ArrayList<Boid> boids;
int N = 120;
void setup() {
  size(700, 700);
  boids = new ArrayList<Boid>();
  for (int i = 0; i < N; i++) {
    boids.add(new Boid(random(width), random(height)));
  }
}

void draw() {
  background(20);
 for (Boid b : boids) {
  b.flock(boids);
  b.update();
  b.wrap();
  b.show();
}
}
class Boid{
  PVector pos, vel;
  
  Boid(float x, float y){
    this.pos = new PVector(x,y);
    this.vel = PVector.random2D();   // une direction au hasard (vecteur unitaire)
    this.vel.mult(2);
  }
  PVector cohesion(ArrayList<Boid> boids) {
  float r = 50;
  PVector center = new PVector(0, 0);
  int count = 0;
  for (Boid other : boids) {
    float d = PVector.dist(pos, other.pos);
    if (other != this && d < r) {
      center.add(other.pos);    // on somme les positions des voisins
      count++;
    }
  }
  if (count > 0) {
    center.div(count);                       // barycentre = moyenne
    PVector dir = PVector.sub(center, pos);  // moi -> barycentre (comme la gravité)
    dir.normalize();                         // on garde juste la DIRECTION
    return dir;
  }
  return new PVector(0, 0);                   // pas de voisin : aucune force
}

PVector alignment(ArrayList<Boid> boids) {
  float r = 50;
  PVector avg = new PVector(0, 0);
  int count = 0;
  for (Boid other : boids) {
    float d = PVector.dist(pos, other.pos);
    if (other != this && d < r) {
      avg.add(other.vel);     // on somme les VITESSES, pas les positions
      count++;
    }
  }
  if (count > 0) { avg.div(count); avg.normalize(); }
  return avg;
}

PVector separation(ArrayList<Boid> boids) {
  float r = 25;                              // rayon court
  PVector steer = new PVector(0, 0);
  int count = 0;
  for (Boid other : boids) {
    float d = PVector.dist(pos, other.pos);
    if (other != this && d < r) {
      PVector away = PVector.sub(pos, other.pos);  // voisin -> moi (je fuis)
      away.normalize();
      away.mult(1/d);            // proche = pousse fort (inverse de la distance)
      steer.add(away);
      count++;
    }
  }
  if (count > 0) { steer.div(count); steer.normalize(); }
  return steer;
}

  void update(){
    pos.add(vel);
  }
  void show() {
  float angle = vel.heading();
  fill(200);
  noStroke();
  pushMatrix();
  translate(pos.x, pos.y);   // on se place sur le boid
  rotate(angle);             // on tourne selon sa direction
  triangle(8, 0, -5, 4, -5, -4);
  popMatrix();
}
  void wrap() {
  if (pos.x < 0)      pos.x = width;
  if (pos.x > width)  pos.x = 0;
  if (pos.y < 0)      pos.y = height;
  if (pos.y > height) pos.y = 0;
}

void flock(ArrayList<Boid> boids) {
  PVector sep = separation(boids);
  PVector ali = alignment(boids);
  PVector coh = cohesion(boids);

  sep.mult(1.5);   // séparation prioritaire
  ali.mult(1.0);
  coh.mult(1.0);

  PVector force = new PVector(0, 0);
  force.add(sep);
  force.add(ali);
  force.add(coh);
  force.mult(0.2);   // "agilité" : à quelle vitesse le boid tourne

  vel.add(force);     // v += force   <-- identique à ta planète et tes particules !
  vel.limit(3);       // on plafonne la vitesse : un boid n'accélère pas à l'infini
}
}
