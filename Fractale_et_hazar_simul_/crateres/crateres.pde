int DIV = 12;
int lambda = 30;

void setup(){
  size(600,600);
  int cellSize = width / DIV;
  for (int i = 0; i < width; i += cellSize){
    for (int j = 0; j < height; j += cellSize){
      int N = poisson(lambda);
      for (int n = 0; n < N; n++){
        float d = loiPuissance(1,50,-2.5);
        float x = random(i, i+cellSize);
        float y = random(j, j+cellSize);
        circle(x,y,d);
      }
    }
  }
}

int poisson(float lambda) {
  float L = exp(-lambda);
  float w = 1;
  int k = 0;
  do {
    w *= random(1);
    k++;
  } while (w > L);
  return k - 1;
}
float loiPuissance(float x0, float x1, float n) {
  float u = random(1);              // uniforme dans [0, 1[
  float a = pow(x0, n + 1);
  float b = pow(x1, n + 1);
  return pow(a + u * (b - a), 1.0 / (n + 1));
}
