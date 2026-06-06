int w = 20, h = 20;
int posX = -w /2 , posY = - h / 2;
void setup(){
size(600,600);
}
void draw(){
  float theta = atan2(mouseY - posY, mouseX - posX);
  pushMatrix();
  translate(mouseX, mouseY);
  rotate(theta);
  rect(-w/2, -h/2, w, h);
  popMatrix();
  posX = mouseX;
  posY = mouseY;
}
