import themidibus.*;
import spout.*;

boolean newMode = true;
boolean settingsMode = true;

int newNumberOfPoints = 0;
float newXParam = 0;
float newYParam = 0;
float newXAmplitudeParam = 0.0;
float newYAmplitudeParam = 0.0;
float newDtheta = 0.0;

boolean mode;
int numberOfPoints;
float theta = 0.0;
float amplitude = 400;
float xParam;
float yParam;
float xAmplitudeParam;
float yAmplitudeParam;
float dtheta;
float dalpha;
float[] x;
float[] y;
MidiBus myBus;
Spout spout;

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  // 1 - prędkość
  if (number == 1){
     newDtheta = (value - 64)/200.0;
  }
  // 2 - liczba punktów
  else if (number == 2){
    newNumberOfPoints = value*2;
    dalpha = TWO_PI / numberOfPoints;
    x = new float[numberOfPoints];
    y = new float[numberOfPoints];
  }
  // 3, 4 - parametry x i y
  else if (number == 3){
    newXParam = value; 
  }
  else if (number == 4){
    newYParam = value; 
  }
  // 5, 6 - skala po x i y
  else if (number == 5){
    newXAmplitudeParam = value/100.0; 
  }
  else if (number == 6){
    newYAmplitudeParam = value/100.0;
  }
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  // PAD 1 - zmiana trybu
  if (pitch == 36) {
    newMode = !newMode;
  }
  
  // PAD 2 - zablokowanie/odblokowanie ustawień
  if (pitch == 37) {
    settingsMode = !settingsMode;
  }
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void update_settings(){
  numberOfPoints = newNumberOfPoints;
  dalpha = TWO_PI / numberOfPoints;
  x = new float[numberOfPoints];
  y = new float[numberOfPoints];
  
  xParam = newXParam;
  yParam = newYParam;
  xAmplitudeParam = newXAmplitudeParam;
  yAmplitudeParam = newYAmplitudeParam;
  dtheta = newDtheta;
  
  mode = newMode;
}

// SETUP
void setup(){
  size(1920, 1080, P3D);
  textureMode(NORMAL);
  dalpha = TWO_PI / numberOfPoints;
  x = new float[numberOfPoints];
  y = new float[numberOfPoints];
  MidiBus.list();
  myBus = new MidiBus(this, 1, -1);
  spout = new Spout(this);
  spout.setSenderName("Spout from Processing");
}


// DRAW
void draw(){
  background(0);
  if (settingsMode){
    update_settings(); 
  }
  calcPlot();
  renderPlot();
  spout.sendTexture();
}


void calcPlot(){
   float alpha = 0.0;
   for (int i=0; i<numberOfPoints; i++){
     x[i] = (cos(alpha * xParam + theta) * amplitude * xAmplitudeParam + width/2);
     y[i] = (sin(alpha * yParam + theta) * amplitude * yAmplitudeParam + height/2);
     alpha += dalpha;
   }
   
   theta = (theta + dtheta) % TWO_PI;
}


void drawEllipsePlot(int size, int r, int g, int b){
  noStroke();
  fill(r, g, b);
  for (int i=0; i<numberOfPoints; i++) {
    if (i % 2 == 0) fill(255, 255, 255);
    else fill(r, g, b);
    ellipse(x[i], y[i], size, size);
  }
}
void drawLinePlot(int size, int r, int g, int b){
  stroke(r, g, b);
  strokeWeight(size);
  for (int i=0; i<numberOfPoints; i++) {
    if (i == 0){
      line(x[x.length-1], y[y.length-1], x[i], y[i]); 
    }
    else {
      line(x[i-1], y[i-1], x[i], y[i]);
    }
  }
}


void drawCurvePlot(int size, int r, int g, int b){
  stroke(r, g, b);
  strokeWeight(size);
  noFill();
  beginShape();
  curveVertex(x[x.length-1], y[y.length-1]);
  for (int i=0; i<numberOfPoints; i++) {
    strokeCap(ROUND);
    curveVertex(x[i], y[i]); 
  }
  curveVertex(x[0], y[0]);
  curveVertex(x[1], y[1]);
  endShape();
}


void renderPlot(){
  if (mode){
    drawEllipsePlot(16, 150, 200, 255);
  }
  else{
    drawCurvePlot(60, 60, 0, 0);
    drawCurvePlot(40, 100, 0, 0);
    drawCurvePlot(25, 150, 0, 0);
    drawCurvePlot(10, 255, 100, 100);
    drawCurvePlot(4, 255, 255, 255);
  }
}


//void keyPressed() {
  
//  // ZMIANA LINIE - KOŁA
//  if (key == ' '){
//    newMode = !newMode; 
//  }
  
//  if (key == 'm'){
//    settingsMode = !settingsMode;
//  }
  
//  // DODAWANIE/USUWANIE PUNKTÓW
//  if (key == '+') {
//    newNumberOfPoints += 1;
//  }
//  else if (key == '-') {
//    newNumberOfPoints = max(numberOfPoints - 1, 1);
//  }
  
//  // ZMIANA PARAMETRÓW x/yParam
//  if (key == 'x') {
//    newXParam += 1; 
//  }
//  if (key == 'z') {
//    newXParam -= 1; 
//  }
//  if (key == 'y') {
//    newYParam += 1; 
//  }
//  if (key == 't') {
//    newYParam -= 1; 
//  }
  
//  // STRZAŁKI DO ZMIANY SKALI
//  if (key == CODED){
//    if (keyCode == UP) {
//      newYAmplitudeParam = max(yAmplitudeParam-0.005, 0);
//    }
//    else if (keyCode == DOWN) {
//      newYAmplitudeParam += 0.005;
//    }
//    else if (keyCode == LEFT) {
//      newXAmplitudeParam -= 0.005;
//    }
//    else if (keyCode == RIGHT) {
//      newXAmplitudeParam += 0.005; 
//    }
//  }
  
//  // STOP ANIMACJI
//  if (key == 's'){
//    if (dtheta == 0.0) dtheta = 0.02;
//    else dtheta = 0.0;
//  }
  
//  // INFORMACJE O PARAMETRACH
//  if (key == 'i'){
//    print("\n\nxParam = ", xParam, "\nyParam = ", yParam, "\nnumberOfPoints = ", numberOfPoints, "\nmode = ", mode, "\nxAmplitudeParam", xAmplitudeParam, "\nyAmplitudeParam", yAmplitudeParam);
//  }
  
//  dalpha = TWO_PI / numberOfPoints;
//  x = new float[numberOfPoints];
//  y = new float[numberOfPoints];
//}
