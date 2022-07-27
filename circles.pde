//import controlP5.*;
boolean mode = true;
int numberOfPoints = 200;
float theta = 0.0;
float amplitude = 200.0;
float xParam = 1;
float yParam = 2;
float xAmplitudeParam = 1.0;
float yAmplitudeParam = 1.0;
float dtheta = 0.02;
float dalpha;
float[] x;
float[] y;
//ControlP5 MyController;

void setup(){
  size(640,480);
  dalpha = TWO_PI / numberOfPoints;
  x = new float[numberOfPoints];
  y = new float[numberOfPoints];
  //MyController = new ControlP5(this);
  //MyController.addSlider("slider", 0, 200, 128, 20, 100, 10, 100);
}

void draw(){
  background(0);
  calcPlot();
  renderPlot();
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

void drawLinePlot(int size, int r, int g, int b, boolean blur){
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
  if (blur) filter(BLUR, 6);
}

void renderPlot(){
  if (mode){
    drawEllipsePlot(16, 150, 200, 255);
  }
  else{
    drawLinePlot(60, 60, 0, 0, false);
    drawLinePlot(40, 100, 0, 0, false);
    drawLinePlot(25, 150, 0, 0, false);
    drawLinePlot(10, 255, 100, 100, false);
    drawLinePlot(4, 255, 255, 255, false);
  }
}

void keyPressed() {
  
  // ZMIANA LINIE - KOŁA
  if (key == ' '){
    mode = !mode; 
  }
  
  // DODAWANIE/USUWANIE PUNKTÓW
  if (key == '+') {
    numberOfPoints += 1;
  }
  else if (key == '-') {
    numberOfPoints = max(numberOfPoints - 1, 1);
  }
  
  // ZMIANA PARAMETRÓW x/yParam
  if (key == 'x') {
    xParam += 1; 
  }
  if (key == 'z') {
    xParam -= 1; 
  }
  if (key == 'y') {
    yParam += 1; 
  }
  if (key == 't') {
    yParam -= 1; 
  }
  
  // STRZAŁKI DO ZMIANY SKALI
  if (key == CODED){
    if (keyCode == UP) {
      yAmplitudeParam = max(yAmplitudeParam-0.005, 0);
    }
    else if (keyCode == DOWN) {
      yAmplitudeParam += 0.005;
    }
    else if (keyCode == LEFT) {
      xAmplitudeParam -= 0.005;
    }
    else if (keyCode == RIGHT) {
      xAmplitudeParam += 0.005; 
    }
  }
  
  // STOP ANIMACJI
  if (key == 's'){
    if (dtheta == 0.0) dtheta = 0.02;
    else dtheta = 0.0;
  }
  
  // INFORMACJE O PARAMETRACH
  if (key == 'i'){
    print("\n\nxParam = ", xParam, "\nyParam = ", yParam, "\nnumberOfPoints = ", numberOfPoints, "\nmode = ", mode, "\nxAmplitudeParam", xAmplitudeParam, "\nyAmplitudeParam", yAmplitudeParam);
  }
  
  dalpha = TWO_PI / numberOfPoints;
  x = new float[numberOfPoints];
  y = new float[numberOfPoints];
}
