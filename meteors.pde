float[] center = new float[2];
float[] position = new float[2];
Meteor[] meteors;
int numberOfMeteors;
int lengthOfTrail;

void setup(){
  size(1200, 800);
  center[0] = width/2;
  center[1] = height/2;
  position[0] = width/2;
  position[1] = height/2;
  float[] p1 = {100.0, 200.0};
  float[] p2 = {500.0, 500.0};
  numberOfMeteors = 10;
  lengthOfTrail = 10;
  println(center[0]);
  background(0);
  println("Setup meteor");
  meteors = new Meteor[numberOfMeteors];
  for (int i=0; i<numberOfMeteors; i++){
    meteors[i] = new Meteor(random(p1[0] - 100.0, p1[0] + 100.0), random(p1[1] - 100.0, p1[1] + 100.0), center[0], center[1], 10.0);
  }
  println("Setup done");
}

void draw(){
  background(0);
  stroke(255);
  noFill();
  println("Draw");
  for (int i=0; i<numberOfMeteors; i++){
    println(i);
    meteors[i].move();
    meteors[i].drawM();
  }
  fill(0);
  ellipse(center[0], center[1], 100, 100);
}

float distance(float[] p1, float[] p2){
  float sum = 0.0;
  for (int i=0; i<min(p1.length, p2.length); i++){
    sum += (p1[i] - p2[i]) * (p1[i] - p2[i]);
  }
  return sqrt(sum);
}

class Meteor{
  float size;
  float[] position;
  float[] xs;
  float[] ys;
  float[] velocity;
  float[] center;
  float gravity;
  
  //Meteor(float[] newPosition, float[] newCenter, float newGravity){
  Meteor(float x1, float y1, float x2, float y2, float newGravity){
    size = random(20, 50);
    velocity = new float[2];
    
    velocity[0] = random(-10, 10);
    velocity[1] = random(-10,10);
    
    position = new float[2];
    position[0] = x1;
    position[1] = y1;
    
    xs = new float[lengthOfTrail];
    ys = new float[lengthOfTrail];
    
    for (int i=0; i<lengthOfTrail; i++){
       xs[i] = x1;
       ys[i] = y1;
    }
    
    center = new float[2];
    center[0] = x2;
    center[1] = y2;
    
    //center = newCenter;
    gravity = newGravity;
  }
  
  void move(){
    int which = frameCount % lengthOfTrail;
    
    xs[which] = position[0];
    ys[which] = position[1]; 
    //position[0] = mouseX;
    //position[1] = mouseY;
    
    println(position[0]);
    println(position[1]);  
    
    float a = center[0] - position[0];
    float b = center[1] - position[1];
    float c2 = distance(position, center);
    
    float xForce = gravity/c2 * a / sqrt(c2); //(c2 - b2)/(a2) * (center[0] - position[0])/abs(center[0] - position[0]);
    float yForce = gravity/c2 * b / sqrt(c2);//(c2 - a2)/(b2) * (center[1] - position[1])/abs(center[1] - position[1]);
    
    println();
    println(a);
    println(b);
    println(c2);
    println(gravity/c2);
    println("xForce = ", xForce);
    println("yForce = ", yForce);
    
    velocity[0] += xForce;
    velocity[1] += yForce;
    
    position[0] += velocity[0];
    position[1] += velocity[1];
  }
  
  void drawM(){
    noStroke();
    int which = frameCount % lengthOfTrail;
    for (int i=0; i<lengthOfTrail; i++){
      fill(255 * (i+1)/lengthOfTrail);
       int index = (which + 1 + i) % lengthOfTrail;
       float elSize = size*(i+1)/lengthOfTrail;
       ellipse(xs[index], ys[index], elSize, elSize);
    }
    ellipse(position[0], position[1], size, size);
  }
}
