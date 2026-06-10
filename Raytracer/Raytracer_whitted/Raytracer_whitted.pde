// =====================================================
//  Lancer de rayon de WHITTED (recursif, deterministe)
//  Contraste avec le path tracer de Shirley :
//   - une source de lumiere explicite + rayons d'ombre
//   - un rayon de reflexion calcule precisement (pas au hasard)
//   - une profondeur max au lieu de l'arret "au ciel"
// =====================================================

Hitable world;
Camera cam;
PVector lightPos;          // la source de lumiere
int maxDepth = 5;          // nombre max de rebonds recursifs

void setup() {
  size(400, 200);

  cam = new Camera(
    new PVector(-2, -1, -1),
    new PVector(4, 0, 0),
    new PVector(0, 2, 0),
    new PVector(0, 0, 0)
  );

  lightPos = new PVector(2, 3, 1);   // <-- nouveau : une lampe dans la scene

  // chaque sphere a maintenant une COULEUR et une REFLECTIVITE (0=mat, 1=miroir)
  ArrayList<Hitable> list = new ArrayList();
  list.add(new Sphere(new PVector( 0, 0, -1), 0.5, new PVector(0.8, 0.3, 0.3), 0.0));   // boule mate rouge
  list.add(new Sphere(new PVector( 1, 0, -1), 0.5, new PVector(0.8, 0.8, 0.8), 0.85));  // boule miroir
  list.add(new Sphere(new PVector( 0, -100.5, -1), 100, new PVector(0.5, 0.5, 0.5), 0.0)); // sol mat
  world = new HitableList(list);

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      float u = (float) i / (float) width;
      float v = (float) (height - 1 - j) / (float) height;
      Ray r = cam.getRay(u, v);
      PVector col = colorWhitted(r, world, maxDepth);   // <-- deterministe, pas de moyenne ns
      stroke((int)(255 * constrain(col.x, 0, 1)),
             (int)(255 * constrain(col.y, 0, 1)),
             (int)(255 * constrain(col.z, 0, 1)));
      point(i, j);
    }
  }
}

// =====================================================
//  LE COEUR DE WHITTED
// =====================================================
PVector colorWhitted(Ray ray, Hitable world, int depth) {
  if (depth <= 0) return new PVector(0, 0, 0);   // trop de rebonds -> on arrete (noir)

  HitRecord rec = new HitRecord();
  if (world.hit(ray, 0.001, Float.MAX_VALUE, rec)) {

    // --- 1) ECLAIRAGE DIRECT : Lambert + rayon d'ombre ---
    PVector toLight = PVector.sub(lightPos, rec.P).normalize();
    float diffuse = max(0, PVector.dot(rec.N, toLight));
    if (inShadow(rec.P, world)) diffuse = 0;          // un objet bloque la lumiere
    float ambient = 0.1;
    PVector local = PVector.mult(rec.albedo, ambient + diffuse);

    // --- 2) REFLEXION : un rayon recursif, calcule precisement ---
    if (rec.reflectivity > 0) {
      PVector reflectedDir = reflect(ray.direction().copy().normalize(), rec.N);
      Ray reflectedRay = new Ray(rec.P, reflectedDir);
      PVector reflectedColor = colorWhitted(reflectedRay, world, depth - 1);  // <-- recursion
      // melange : (1 - r) * couleur locale  +  r * couleur reflechie
      local = PVector.add(PVector.mult(local, 1 - rec.reflectivity),
                          PVector.mult(reflectedColor, rec.reflectivity));
    }

    // --- 3) REFRACTION : meme principe, avec un rayon refracte en plus (voir note) ---

    return local;

  } else {
    // rien touche -> couleur du ciel (degrade), comme dans ton path tracer
    PVector unitDir = ray.direction().copy().normalize();
    float t = 0.5 * (unitDir.y + 1.0);
    return PVector.add(PVector.mult(new PVector(1, 1, 1), 1 - t),
                       PVector.mult(new PVector(0.5, 0.7, 1.0), t));
  }
}

// reflexion miroir : v - 2*(v.n)*n
PVector reflect(PVector v, PVector n) {
  return PVector.sub(v, PVector.mult(n, 2 * PVector.dot(v, n)));
}

// rayon d'ombre : y a-t-il un objet entre le point et la lumiere ?
boolean inShadow(PVector point, Hitable world) {
  PVector toLight = PVector.sub(lightPos, point);
  float distToLight = toLight.mag();
  Ray shadowRay = new Ray(point, toLight.copy().normalize());
  HitRecord rec = new HitRecord();
  // 0.001 pour ne pas se toucher soi-meme ; distToLight pour ne pas compter au-dela de la lampe
  return world.hit(shadowRay, 0.001, distToLight, rec);
}


// =====================================================
//  CAMERA  (inchangee)
// =====================================================
class Camera {
  PVector lowerLeftCorner, horizontal, vertical, origin;
  Camera(PVector lowerLeftCorner, PVector horizontal, PVector vertical, PVector origin) {
    this.lowerLeftCorner = lowerLeftCorner.copy();
    this.horizontal = horizontal.copy();
    this.vertical = vertical.copy();
    this.origin = origin.copy();
  }
  Ray getRay(float u, float v) {
    return new Ray(origin, PVector.add(PVector.add(lowerLeftCorner, PVector.mult(horizontal, u)),
                                       PVector.mult(vertical, v)));
  }
}

// =====================================================
//  RAY  (inchange)
// =====================================================
class Ray {
  PVector A, B;
  Ray(PVector a, PVector b) { this.A = a.copy(); this.B = b.copy(); }
  PVector origin()    { return A; }
  PVector direction() { return B; }
  PVector pointAtParameter(float t) { return PVector.add(A, PVector.mult(B, t)); }
}

// =====================================================
//  HIT_RECORD  (+ couleur et reflectivite du materiau touche)
// =====================================================
class HitRecord {
  float t;
  PVector P, N;
  PVector albedo;       // couleur diffuse de l'objet
  float reflectivity;   // 0 = mat, 1 = miroir parfait
}

interface Hitable {
  boolean hit(Ray r, float tMin, float tMax, HitRecord rec);
}

// =====================================================
//  SPHERE  (+ materiau, + discriminant corrige)
// =====================================================
class Sphere implements Hitable {
  PVector center;
  float R;
  PVector albedo;
  float reflectivity;

  Sphere(PVector center, float radius, PVector albedo, float reflectivity) {
    this.center = center.copy();
    this.R = radius;
    this.albedo = albedo.copy();
    this.reflectivity = reflectivity;
  }

  boolean hit(Ray r, float tMin, float tMax, HitRecord rec) {
    PVector OC = PVector.sub(r.origin(), center);
    float a = PVector.dot(r.direction(), r.direction());
    float b = 2.0 * PVector.dot(OC, r.direction());
    float c = PVector.dot(OC, OC) - R * R;
    float delta = b * b - 4 * a * c;
    if (delta > 0) {
      float temp = (-b - sqrt(delta)) / (2.0 * a);     // discriminant coherent !
      if (temp < tMax && temp > tMin) { fill(r, temp, rec); return true; }
      temp = (-b + sqrt(delta)) / (2.0 * a);
      if (temp < tMax && temp > tMin) { fill(r, temp, rec); return true; }
    }
    return false;
  }

  void fill(Ray r, float t, HitRecord rec) {
    rec.t = t;
    rec.P = r.pointAtParameter(t);
    rec.N = PVector.sub(rec.P, center);
    rec.N.normalize();
    rec.albedo = albedo;
    rec.reflectivity = reflectivity;
  }
}

// =====================================================
//  HITABLE_LIST  (copie bien tous les champs)
// =====================================================
class HitableList implements Hitable {
  ArrayList<Hitable> list;
  HitableList(ArrayList<Hitable> l) { list = l; }

  boolean hit(Ray r, float tMin, float tMax, HitRecord rec) {
    HitRecord tempRec = new HitRecord();
    boolean hitAnything = false;
    float closestSoFar = tMax;
    for (int i = 0; i < list.size(); i++) {
      if (list.get(i).hit(r, tMin, closestSoFar, tempRec)) {
        hitAnything = true;
        closestSoFar = tempRec.t;
        rec.t = tempRec.t;
        rec.P = tempRec.P;
        rec.N = tempRec.N;
        rec.albedo = tempRec.albedo;
        rec.reflectivity = tempRec.reflectivity;
      }
    }
    return hitAnything;
  }
}
