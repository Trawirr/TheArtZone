// Parameters for noise and visualization
float noiseScale = 0.01;  // Scale of the Perlin noise
float contourInterval = 0.05;  // Spacing between contour lines
float heightScale = 800;  // Scale factor for height
int cols, rows;
float[][] heights;
int resolution = 6;  // Pixels between sample points
float rotationY = 0;
float mapSize = 800;  // Size of the square map area

float x_speed = 0.001;
float y_speed = 0.001;
float x = 0;
float y = 0;

float viewRotationX = PI/4;  // Camera tilt (around X axis)
float viewRotationZ = 0;  // Camera rotation (around Y axis)

boolean displayMode = true;

import themidibus.*;
import spout.*;

MidiBus myBus;
Spout spout;

void setup() {
  fullScreen(P3D);
  
  cols = int(mapSize / resolution);
  rows = int(mapSize / resolution);
  heights = new float[cols][rows];

  // Generate height map using Perlin noise
  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      heights[x][y] = noise(xoff, yoff);
      xoff += noiseScale;
    }
    yoff += noiseScale;
  }
  noFill();
  smooth();
  
  MidiBus.list();
  myBus = new MidiBus(this, 1, -1);
  spout = new Spout(this);
  spout.setSenderName("contour");
}

void draw() {
  background(0);
  
  if (displayMode){
    // Generate height map using Perlin noise
    x += x_speed;
    y += y_speed;
    float yoff = y;
    for (int y = 0; y < rows; y++) {
      float xoff = x;
      for (int x = 0; x < cols; x++) {
        heights[x][y] = noise(xoff, yoff);
        xoff += noiseScale;
      }
      yoff += noiseScale;
    }
  
    // Set up 3D view
    translate(width / 2, height / 2, -100);
    rotateX(viewRotationX);
    rotateZ(viewRotationZ);
    scale(0.75);
  
    // Center the square map
    translate(-mapSize / 2, -mapSize / 2, 0);
  
    // Draw contour lines
    strokeWeight(2);
    for (float level = 0; level < 1.0; level += contourInterval) {
      float hue = level * 255;
      stroke(hue, 100, 200);
  
      ArrayList<ArrayList<PVector>> contourLines = new ArrayList<ArrayList<PVector>>();
      boolean[][] visited = new boolean[cols - 1][rows - 1];
  
      for (int y = 0; y < rows - 1; y++) {
        for (int x = 0; x < cols - 1; x++) {
          if (!visited[x][y]) {
            float[] square = {
              heights[x][y],
              heights[x + 1][y],
              heights[x + 1][y + 1],
              heights[x][y + 1]
            };
  
            ArrayList<PVector> points = getContourPoints(x, y, square, level);
            if (points.size() >= 2) {
              ArrayList<PVector> contourLine = traceContour(x, y, level, visited);
              if (contourLine.size() > 0) {
                contourLines.add(contourLine);
              }
            }
          }
        }
      }
  
      for (ArrayList<PVector> line : contourLines) {
        beginShape();
        for (PVector p : line) {
          vertex(p.x * resolution, p.y * resolution, (level - 0.5) * heightScale);
        }
        endShape();
      }
    }
  }

  
  spout.sendTexture();
}


ArrayList<PVector> traceContour(int startX, int startY, float level, boolean[][] visited) {
  ArrayList<PVector> contourLine = new ArrayList<PVector>();
  int x = startX;
  int y = startY;
  boolean tracing = true;

  while (tracing && x >= 0 && x < cols-1 && y >= 0 && y < rows-1 && !visited[x][y]) {
    visited[x][y] = true;
    float[] square = {
      heights[x][y],
      heights[x+1][y],
      heights[x+1][y+1],
      heights[x][y+1]
    };

    ArrayList<PVector> points = getContourPoints(x, y, square, level);

    if (points.size() >= 2) {
      if (contourLine.size() == 0) {
        contourLine.add(points.get(0));
        contourLine.add(points.get(1));
      } else {
        PVector lastPoint = contourLine.get(contourLine.size() - 1);
        PVector p1 = points.get(0);
        PVector p2 = points.get(1);

        if (PVector.dist(lastPoint, p1) < PVector.dist(lastPoint, p2)) {
          contourLine.add(p1);
          contourLine.add(p2);
        } else {
          contourLine.add(p2);
          contourLine.add(p1);
        }
      }

      PVector lastPoint = contourLine.get(contourLine.size() - 1);
      int nextX = x;
      int nextY = y;

      if (abs(lastPoint.x - x) < 0.1) nextX--;
      else if (abs(lastPoint.x - (x+1)) < 0.1) nextX++;
      else if (abs(lastPoint.y - y) < 0.1) nextY--;
      else if (abs(lastPoint.y - (y+1)) < 0.1) nextY++;

      if (nextX < 0 || nextX >= cols-1 || nextY < 0 || nextY >= rows-1 || visited[nextX][nextY]) {
        tracing = false;
      } else {
        x = nextX;
        y = nextY;
      }
    } else {
      tracing = false;
    }
  }

  return contourLine;
}

ArrayList<PVector> getContourPoints(int x, int y, float[] square, float level) {
  ArrayList<PVector> points = new ArrayList<PVector>();

  for (int i = 0; i < 4; i++) {
    int j = (i + 1) % 4;
    float v1 = square[i];
    float v2 = square[j];

    if ((v1 < level && v2 >= level) || (v1 >= level && v2 < level)) {
      float t = (level - v1) / (v2 - v1);

      float px, py;
      if (i == 0) {
        px = x + t;
        py = y;
      } else if (i == 1) {
        px = x + 1;
        py = y + t;
      } else if (i == 2) {
        px = x + (1 - t);
        py = y + 1;
      } else {
        px = x;
        py = y + (1 - t);
      }

      points.add(new PVector(px, py));
    }
  }

  return points;
}

void keyPressed() {

  // Arrow keys to adjust view
  if (keyCode == LEFT) {
    viewRotationZ  -= PI/32;
  }
  if (keyCode == RIGHT) {
    viewRotationZ += PI/32;
  }
  if (keyCode == UP) {
    viewRotationX -= PI/32;
  }
  if (keyCode == DOWN) {
    viewRotationX += PI/32;
  }
  if (key == '8') {
    y_speed += 0.01;
  }
  if (key == '2') {
    y_speed -= 0.01;
  }
  if (key == '6') {
    x_speed += 0.01;
  }
  if (key == '4') {
    x_speed -= 0.01;
  }
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  // 1 - prędkość
  if (number == 1){
     viewRotationX = value * PI / 127;
  }
  // 2 - liczba punktów
  else if (number == 2){
    viewRotationZ = value * 2 * PI / 127;
  }
  // 3, 4 - parametry x i y
  else if (number == 3){
    x_speed = value / 1000;
  }
  else if (number == 4){
    y_speed = value / 1000;
  }
  // 5, 6 - skala po x i y
  else if (number == 5){
    heightScale = 10 * value;
  }
  else if (number == 6){
    contourInterval = 1.0 - 0.99 / 127 * value;
  }
  else if (number == 7){
    mapSize = (int)(value * 10);
    cols = int(mapSize / resolution);
    rows = int(mapSize / resolution);
    heights = new float[cols][rows];
  }
  //println();
  //println("Controller Change:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Number:"+number);
  //println("Value:"+value);
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  // PAD 1 - zmiana trybu
  if (pitch == 36) {
    noiseSeed((long)random(10000));
  }
  
  // PAD 2 - zablokowanie/odblokowanie ustawień
  if (pitch == 37) {
    displayMode = !displayMode;
  }
  
  //println();
  //println("Note On:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  //// Receive a noteOff
  //println();
  //println("Note Off:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
}
