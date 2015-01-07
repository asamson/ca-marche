//KONJECTURE BY ADAM SAMSON 
//adamsamson.us 2014
//This method of tracking is my own! Corners of a flat surface are determined by comparing the depth values of surrounding pixels and searching for a contiguous area of similar depth.
//Use the calibration mode to match the virtual camera's parameters to the angle and orientation of the projector relative to the kinect.  
//
import processing.video.*;
import processing.opengl.*;
import SimpleOpenNI.*;
SimpleOpenNI kinect;
Movie myMovie;
//PImage myMovie;
  int currentDepthValue;
int closestValue;
int closestX;
int closestY;
int topLeftX;
int topLeftY;
int topRightX;
int topRightY;
int bottomLeftX;
int bottomLeftY;
int bottomRightX;
int bottomRightY;
int neighborThresh =   7;  //the diagonal distance between the corner point and the four diagonal tracking points
int innerThresh = 5;  //the diagonal distance in pixels between the corner point being checked and the interior point being compared
int edgeThresh = 50;  //the minimum difference between two adjacent points to constitute an edge.
int planeThresh = 20;  //the maximum difference between a depth value at a corner and a corresponding value at the interior of the plane.  How different in depth contiguous points can be
int bias = 0;        //how obtuse the edge detection can afford to be without disturbing corner.  0 affords least obtuse but also highest accuracy.
boolean calibrate = true;

//coordinates for linear interpolation and ultimately to determine the video quad's coordinates
float TLX1;
float TLX2;
float TLY1;
float TLY2;
float TRX1;
float TRX2;
float TRY1; 
float TRY2; 
float BLX1;
float BLX2;
float BLY1;
float BLY2;
float BRX1;
float BRX2;
float BRY1;
float BRY2;
float TLz;
float TRz;
float BLz;
float BRz;
//calibration controls
int mode = 0;
float frustX = 0;
float frustY = 0;
int camX = 0;
int camY = 0;
int camZ = 0;
int centX = 0;
int centY = 0; 

void setup() {
  size(1024, 768, P3D);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  closestValue = 8000;
  myMovie = new Movie(this, "kinectmovie.mov");
 // PImage myMovie = loadImage("myMovie.jpg");
  myMovie.play();
  myMovie.speed(1);
  myMovie.loop();
}

void draw() {
  background(0);
  if(calibrate == true){
  image(kinect.depthImage(), 0, 0);
  }
  kinect.update();
  myMovie.read();
  int[] depthValues = kinect.depthMap();
  closestValue = 8000;
    camera( camX,  camY,-1000+camZ,  centX,   centY,0,0.0,1.0,0.0);
frustum(-5-frustX, 5+frustX,-5-frustY,5+frustY,10,150000);
  //populate array with values from depth map, correct any unusable (depth 0) values to 8000
  for (int i = 0; i < 307200; i++) {
    currentDepthValue = depthValues[i];
    if (depthValues[i] == 0) {
      depthValues[i] = 8000;
    }
    
    //determine closest point
    if (currentDepthValue > 910 && currentDepthValue < closestValue) {
      closestValue = currentDepthValue;
    }
  }
  println(closestValue);
  
  //trac
  for (int i = 0; i < 307200; i++) {

    
    //creates small frame around trackable area to pragmatically prevent out of bounds exceptions
    if (i > (640 * (neighborThresh+innerThresh)) && (i % 640) > 10 && (i % 640) < (640 - (neighborThresh+innerThresh)) && i < (307200 - (640*(neighborThresh+innerThresh)))) {    

      //tracking for top left corner.  Check to see if point is close enough, then check four closeby points diagonally.  Based on what is and is not close (only down/right can be) evaluate 2 more points towards the predicted interior of the plane for consistency.
      if (depthValues[i] > (closestValue-150) && depthValues[i] < (closestValue+800)) { //if current z value is a high point
        if (depthValues[i + (640 * neighborThresh) + neighborThresh] <= (depthValues[i] +edgeThresh) &&  //down right
        depthValues[i - (640 * (neighborThresh+bias)) + neighborThresh] > (depthValues[i] +edgeThresh) &&  //up right
        depthValues[i + (640 * neighborThresh) - (neighborThresh+bias)] > (depthValues[i] +edgeThresh) &&  //down left
        depthValues[i - 1282] > (depthValues[i] +edgeThresh)) {  // up left
          if (depthValues[i + (640 * innerThresh) + innerThresh] <= (depthValues[i] +edgeThresh)&&

            abs(depthValues[i + (640 * (innerThresh)) + (innerThresh)] -(depthValues[i])) <= planeThresh &&
            abs(depthValues[i + (640 * (innerThresh+neighborThresh)) + (innerThresh+neighborThresh)] -(depthValues[i])) <= planeThresh) {
            topLeftX = i%640;  //pixels left is x for top left corner (write if then for modulo fix)
            topLeftY = i/640;  //pixels down is y for top left corner
            TLX2 = float(topLeftX);
            TLY2 = float(topLeftY);
            TLz =depthValues[i];
          }
        }





        //tracking for bottom left corner, only up/right can be close.
        if (depthValues[i - (640 * neighborThresh) + neighborThresh] <= (depthValues[i] +edgeThresh) && //up right
        depthValues[i + (640 * (neighborThresh+bias)) + neighborThresh] > (depthValues[i] +edgeThresh) &&  //down right
        depthValues[i + (1278)] > (depthValues[i] +edgeThresh) &&  //down left
        depthValues[i - (640 * neighborThresh) - (neighborThresh+bias)] > (depthValues[i] +edgeThresh)) { //up left
          if (depthValues[i - (640 * innerThresh) + innerThresh] <= (depthValues[i] +edgeThresh) && 
            abs(depthValues[i - (640 * innerThresh) + innerThresh] - (depthValues[i])) <= planeThresh &&
            abs(depthValues[i - (640 * (innerThresh+neighborThresh)) + (innerThresh+neighborThresh)] - (depthValues[i])) <= planeThresh) {
            bottomLeftX = i%640;  //pixels left is x for bottom left corner
            bottomLeftY = i/640;  //pixels down is y for bottom left corner
            BLX2 = float(bottomLeftX);
            BLY2 = float(bottomLeftY);
            BLz = depthValues[i];
          }
        }

        //tracking for top right corner, only down/left can be close.
        if (depthValues[i + (640 * neighborThresh) - neighborThresh] <= (depthValues[i] +edgeThresh) && //down left
        depthValues[i + (640 * neighborThresh) + (neighborThresh+bias)] > (depthValues[i] +edgeThresh) &&  //down right
        depthValues[i - (640 * (neighborThresh+bias)) - neighborThresh] > (depthValues[i] +edgeThresh) &&  //up left
        depthValues[i - (1278)] > (depthValues[i] +edgeThresh)) {  //up right
          if (depthValues[i + (640 * neighborThresh) - neighborThresh] <= (depthValues[i] +edgeThresh) && 
            abs(depthValues[i + (640 * innerThresh) - innerThresh] -(depthValues[i])) <= planeThresh  &&
            abs(depthValues[i + (640 * (innerThresh+neighborThresh)) - (innerThresh+neighborThresh)] -(depthValues[i])) <= planeThresh) { 

            topRightX= i%640;
            topRightY= i/640;
            TRX2 = float(topRightX);
            TRY2 = float(topRightY);
          }
        }
        //tracking for bottom right corner, only up/left can be close.
        if (depthValues[i - (640 * neighborThresh) - neighborThresh] <= (depthValues[i] +edgeThresh) && //up left
        depthValues[i + (640 * (neighborThresh+bias)) - neighborThresh] > (depthValues[i] +edgeThresh) &&   //down left
        depthValues[i - (640 * neighborThresh) + (neighborThresh+bias)] > (depthValues[i] +edgeThresh) &&  //up right
        depthValues[i + (1282)] > (depthValues[i] +planeThresh)) {   //down right
          if (depthValues[i - (640 * neighborThresh) - neighborThresh] <= (depthValues[i] +edgeThresh) && 
            abs(depthValues[i - (640 * innerThresh) - innerThresh] -(depthValues[i])) <= planeThresh &&
            abs(depthValues[i - (640 * (innerThresh +neighborThresh)) - (innerThresh+neighborThresh)] -(depthValues[i])) <= planeThresh) {
            bottomRightX = i%640;
            bottomRightY = i/640;
            BRX2 = float(bottomRightX);
            BRY2 = float(bottomRightY);
          }
        }

        //   }
      }
    }
  }
  //}
   // myMovie.read();
//image(myMovie, 0,0);
//draw circles to reflect corner tracking parameters
  if(calibrate==true){
  fill(255, 0, 0);
  ellipse (topLeftX, topLeftY, 4, 4);
  ellipse (topLeftX+ neighborThresh, topLeftY+ neighborThresh, 4, 4);  //down right
  ellipse (topLeftX- neighborThresh, topLeftY- neighborThresh, 4, 4);  //up left
  ellipse (topLeftX- (neighborThresh+bias), topLeftY + neighborThresh, 4, 4);  //down left
  ellipse (topLeftX+ neighborThresh, topLeftY - (neighborThresh+bias), 4, 4);  //up right
  ellipse (topLeftX+ innerThresh, topLeftY + innerThresh, 4, 4);
  fill(0, 255, 0);
  ellipse (bottomLeftX, bottomLeftY, 4, 4);
  ellipse (bottomLeftX+ neighborThresh, bottomLeftY + (neighborThresh+bias), 4, 4); //down right
  ellipse (bottomLeftX- (neighborThresh+bias), bottomLeftY - neighborThresh, 4, 4);  //up left
  ellipse (bottomLeftX- neighborThresh, bottomLeftY + neighborThresh, 4, 4);  //down left
  ellipse (bottomLeftX+ neighborThresh, bottomLeftY - neighborThresh, 4, 4);  //up right
  ellipse (bottomLeftX+ innerThresh, bottomLeftY - innerThresh, 4, 4);
  fill(0, 0, 255);
  ellipse (bottomRightX, bottomRightY, 4, 4);
  ellipse (bottomRightX+ neighborThresh, bottomRightY + neighborThresh, 4, 4);  //down right
  ellipse (bottomRightX- neighborThresh, bottomRightY - neighborThresh, 4, 4);  //up left
  ellipse (bottomRightX+ (neighborThresh+bias), bottomRightY - neighborThresh, 4, 4);  //up right
  ellipse (bottomRightX- neighborThresh, bottomRightY + (neighborThresh+bias), 4, 4);  //down left
  ellipse (bottomRightX- innerThresh, bottomRightY - innerThresh, 4, 4);
  fill(255, 100, 100);
  ellipse (topRightX, topRightY, 4, 4);
  ellipse (topRightX- neighborThresh, topRightY+ neighborThresh, 4, 4);  //down left
  ellipse (topRightX- neighborThresh, topRightY - (neighborThresh+bias), 4, 4);  //up left
  ellipse (topRightX+ neighborThresh, topRightY - neighborThresh, 4, 4);  //up right
  ellipse (topRightX+ (neighborThresh+bias), topRightY + neighborThresh, 4, 4);  //down right
  ellipse (topRightX- innerThresh, topRightY + innerThresh, 4, 4);
}

//smooth values before rendering the quad.  added to remove tracking hiccups, now unneccessary.
  float cTLx = lerp(TLX2, TLX1, 0.7);
  float cTLy = lerp(TLY2, TLY1, 0.7);
  float cTRx = lerp(TRX2, TRX1, 0.7);
  float cTRy = lerp(TRY2, TRY1, 0.7);
  float cBLx = lerp(BLX2, BLX1, 0.7);
  float cBLy = lerp(BLY2, BLY1, 0.7);
  float cBRx = lerp(BRX2, BRX1, 0.7);
  float cBRy = lerp(BRY2, BRY1, 0.7);

//draw the quad
 // fill(0, 255, 0);
  beginShape();
  texture(myMovie);
  vertex(cTLx, cTLy,0,0,0);
  vertex(cTRx, cTRy, 0, myMovie.width, 0);
  vertex(cBRx, cBRy, 0, myMovie.width, myMovie.height);
  vertex(cBLx, cBLy, 0, 0, myMovie.height);
  endShape(CLOSE);

//load set of points for lerping against values from next frame
  TLX1 = cTLx;
  TLY1 = cTLy;
  TRX1 = cTRx;
  TRY1 = cTRy;
  BLX1 = cBLx;
  BLY1 = cBLy;
  BRX1 = cBRx;
  BRY1 = cBRy;
}


//click anywhere to find out the depth value
void mousePressed() {
  int[] depthValues = kinect.depthMap();
  int clickPosition = mouseX + (mouseY * 640);
  int clickDepth = depthValues[clickPosition];
  println(clickDepth);
}

void keyPressed()
{
  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }
if(key == 'a'){
  calibrate =!calibrate;
}
     if(key == '0'){
      mode = 0;
    }
    if(key == '1'){
      mode = 1;
    }
    if(key == '2'){
      mode = 2;
    }
    if(key == '3'){
      mode = 3;
    }
    if(key == '4'){
      mode = 4;
    }
    if(key == '5'){
      mode = 5;
    }
    
    if (key == CODED){
    if (keyCode == UP) {
      switch(mode){
        case 1:
        camY+=10;
        break;
        case 2:
        camZ+=10;
        break;
        case 3:
        centY+=10;
        break;
        case 4:
        frustY+=.1;
        break;
      }
    }
    if (keyCode == DOWN) {
   switch(mode){
        case 1:
        camY-=30;
        break;
        case 2:
        camZ-=30;
        break;
        case 3:
        centY-=30;
        break;
        case 4:
        frustY-=.1;
        break;
      }
    } 
    if(keyCode == RIGHT){
      switch(mode){
        case 1:
        camX+=10;
        break;
        case 3:
        centX+=10;
        break;
        case 4:
        frustX+=.1;
        break;
      }
    }
    if (keyCode == LEFT){
       switch(mode){
        case 1:
        camX-=10;
        break;
        case 3:
        centX-=10;
        break;
        case 4:
        frustX-=.1;
        break;
      }
    }
    }
    }
