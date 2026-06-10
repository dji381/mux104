// =====================================================
//  Lancer de rayon de WHITTED complet
//  lumiere directe + reflexion + REFRACTION (verre)
// =====================================================

Hitable world;
Camera cam;
PVector lightPos;
int maxDepth = 15;          // un peu plus profond : le verre rebondit plus

void setup() {
  size(400, 200);

  cam = new Camera(
    new PVector(-2, -1, -1),
    new PVector(4, 0, 0),
    new PVector(0, 2, 0),
    new PVector(0, 0, 0)
  );

  lightPos = new PVector(2, 3, 1);

  // materiau : albedo, reflectivite, refIdx (0 = opaque, 1.5 = verre)
  ArrayList<Hitable> list = new ArrayList();
  list.add(new Sphere(new PVector( 0, 0, -1), 0.5, new PVector(0.8, 0.3, 0.3), 0.0, 0.0));   // boule mate rouge
  list.add(new Sphere(new PVector( 1, 0, -1), 0.5, new PVector(0.8, 0.8, 0.8), 0.85, 0.0));  // boule miroir
  list.add(new Sphere(new PVector(-1, 0, -1), 0.5, new PVector(1.0, 1.0, 1.0), 0.0, 1.5));   // boule de VERRE
  list.add(new Sphere(new PVector( 0, -100.5, -1), 100, new PVector(0.5, 0.5, 0.5), 0.0, 0.0)); // sol mat
  world = new HitableList(list);

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      float u = (float) i / (float) width;
      float v = (float) (height - 1 - j) / (float) height;
      Ray r = cam.getRay(u, v);
      PVector col = colorWhitted(r, world, maxDepth);
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
  if (depth <= 0) return new PVector(0, 0, 0);

  HitRecord rec = new HitRecord();
  if (world.hit(ray, 0.001, Float.MAX_VALUE, rec)) {

    // ---- VERRE : reflexion + refraction, pas de couleur locale ----
    if (rec.refIdx > 0) {
      return glass(ray, rec, world, depth);
    }

    // ---- OPAQUE : lumiere directe (Lambert + ombre) ----
    PVector toLight = PVector.sub(lightPos, rec.P).normalize();
    float diffuse = max(0, PVector.dot(rec.N, toLight));
    if (inShadow(rec.P, world)) diffuse = 0;
    PVector local = PVector.mult(rec.albedo, 0.1 + diffuse);   // 0.1 = ambiant

    // ---- + reflexion (miroir) ----
    if (rec.reflectivity > 0) {
      PVector reflectedDir = reflect(ray.direction().copy().normalize(), rec.N);
      PVector reflectedColor = colorWhitted(new Ray(rec.P, reflectedDir), world, depth - 1);
      local = PVector.add(PVector.mult(local, 1 - rec.reflectivity),
                          PVector.mult(reflectedColor, rec.reflectivity));
    }
    return local;

  } else {
    PVector unitDir = ray.direction().copy().normalize();
    float t = 0.5 * (unitDir.y + 1.0);
    return PVector.add(PVector.mult(new PVector(1, 1, 1), 1 - t),
                       PVector.mult(new PVector(0.5, 0.7, 1.0), t));
  }
}

// =====================================================
//  LE VERRE : reflexion + refraction, melangees par Fresnel
// =====================================================
PVector glass(Ray ray, HitRecord rec, Hitable world, int depth) {
  PVector d = ray.direction().copy().normalize();
  PVector outwardN;
  float niOverNt;   // rapport des indices de refraction
  float cosine;

  if (PVector.dot(d, rec.N) > 0) {       // le rayon SORT du verre
    outwardN = PVector.mult(rec.N, -1);
    niOverNt = rec.refIdx;
    cosine = rec.refIdx * PVector.dot(d, rec.N);
  } else {                                // le rayon ENTRE dans le verre
    outwardN = rec.N.copy();
    niOverNt = 1.0 / rec.refIdx;
    cosine = -PVector.dot(d, rec.N);
  }

  // le rayon reflechi (toujours calculable)
  PVector reflectedDir = reflect(d, rec.N);
  PVector reflectedColor = colorWhitted(new Ray(rec.P, reflectedDir), world, depth - 1);

  // le rayon refracte (null = reflexion totale interne)
  PVector refractedDir = refract(d, outwardN, niOverNt);
  if (refractedDir == null) {
    return reflectedColor;               // tout est reflechi
  }
  PVector refractedColor = colorWhitted(new Ray(rec.P, refractedDir), world, depth - 1);

  // Fresnel (Schlick) : quelle proportion est reflechie selon l'angle
  float reflectProb = schlick(cosine, rec.refIdx);
  return PVector.add(PVector.mult(reflectedColor, reflectProb),
                     PVector.mult(refractedColor, 1 - reflectProb));
}

// =====================================================
//  HELPERS optiques
// =====================================================

// reflexion miroir : v - 2*(v.n)*n
PVector reflect(PVector v, PVector n) {
  return PVector.sub(v, PVector.mult(n, 2 * PVector.dot(v, n)));
}

// refraction (loi de Snell). Renvoie la direction refractee, ou null si
// reflexion totale interne (pas de refraction possible).
PVector refract(PVector v, PVector n, float niOverNt) {
  PVector uv = v.copy().normalize();
  float dt = PVector.dot(uv, n);
  float discriminant = 1.0 - niOverNt * niOverNt * (1 - dt * dt);
  if (discriminant > 0) {
    // niOverNt * (uv - n*dt) - n*sqrt(discriminant)
    PVector refracted = PVector.sub(uv, PVector.mult(n, dt));
    refracted.mult(niOverNt);
    refracted.sub(PVector.mult(n, sqrt(discriminant)));
    return refracted;
  }
  return null;   // reflexion totale interne
}

// approximation de Fresnel par Schlick : % de lumiere reflechie
float schlick(float cosine, float refIdx) {
  float r0 = (1 - refIdx) / (1 + refIdx);
  r0 = r0 * r0;
  return r0 + (1 - r0) * pow(1 - cosine, 5);
}

// rayon d'ombre : un objet bloque-t-il la lumiere ?
boolean inShadow(PVector point, Hitable world) {
  PVector toLight = PVector.sub(lightPos, point);
  float distToLight = toLight.mag();
  Ray shadowRay = new Ray(point, toLight.copy().normalize());
  HitRecord rec = new HitRecord();
  return world.hit(shadowRay, 0.001, distToLight, rec);
}


// =====================================================
//  CAMERA
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
//  RAY
// =====================================================
class Ray {
  PVector A, B;
  Ray(PVector a, PVector b) { this.A = a.copy(); this.B = b.copy(); }
  PVector origin()    { return A; }
  PVector direction() { return B; }
  PVector pointAtParameter(float t) { return PVector.add(A, PVector.mult(B, t)); }
}

// =====================================================
//  HIT_RECORD  (+ refIdx)
// =====================================================
class HitRecord {
  float t;
  PVector P, N;
  PVector albedo;
  float reflectivity;
  float refIdx;          // 0 = opaque, >0 = verre (indice de refraction)
}

interface Hitable {
  boolean hit(Ray r, float tMin, float tMax, HitRecord rec);
}

// =====================================================
//  SPHERE  (+ refIdx, discriminant corrige)
// =====================================================
class Sphere implements Hitable {
  PVector center;
  float R;
  PVector albedo;
  float reflectivity;
  float refIdx;

  Sphere(PVector center, float radius, PVector albedo, float reflectivity, float refIdx) {
    this.center = center.copy();
    this.R = radius;
    this.albedo = albedo.copy();
    this.reflectivity = reflectivity;
    this.refIdx = refIdx;
  }

  boolean hit(Ray r, float tMin, float tMax, HitRecord rec) {
    PVector OC = PVector.sub(r.origin(), center);
    float a = PVector.dot(r.direction(), r.direction());
    float b = 2.0 * PVector.dot(OC, r.direction());
    float c = PVector.dot(OC, OC) - R * R;
    float delta = b * b - 4 * a * c;
    if (delta > 0) {
      float temp = (-b - sqrt(delta)) / (2.0 * a);
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
    rec.refIdx = refIdx;
  }
}

// =====================================================
//  HITABLE_LIST
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
        rec.refIdx = tempRec.refIdx;
      }
    }
    return hitAnything;
  }
}
