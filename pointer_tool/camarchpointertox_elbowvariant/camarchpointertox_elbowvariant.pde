//Accurate translation of kinect pointing gesture into a cursor.
//demonstration with toxiclibs 2d physics particles, thanks to Karsten Schmidt
//adamsamson.us

import SimpleOpenNI.*;
int whichHand = 0;
PVector com = new PVector();                                   
PVector com2d = new PVector(); 
int playerID;
SimpleOpenNI context;



import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

int NUM_PARTICLES = 150;

VerletPhysics2D physics;
AttractionBehavior mouseAttractor, mouseAttractor2;

Vec2D vecPos;




void setup() {
  size(1020, 620, OPENGL);
   smooth();

  //initialize kinect
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    //  exit();
    //  return;
  }
  context.setMirror(true);
  context.enableDepth();
  context.enableUser();


  physics = new VerletPhysics2D();
  physics.setDrag(0.01f);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  // the NEW way to add gravity to the simulation, using behaviors
  // physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.15f)));
  vecPos = new Vec2D(0, 0);
  mouseAttractor = new AttractionBehavior(vecPos, 300, 0.9f);
   mouseAttractor2 = new AttractionBehavior(vecPos, 100, -1.9f);
  physics.addBehavior(mouseAttractor);
   physics.addBehavior(mouseAttractor2);
}
void addParticle() {
  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(width / 2, 0));
  physics.addParticle(p);
  // add a negative attraction force field around the new particle
  physics.addBehavior(new AttractionBehavior(p, 50, -1.2f, 0.01f));
}




void draw() {

  background(230,230,200);
  noStroke();
  fill(40);
  if (physics.particles.size() < NUM_PARTICLES) {
    addParticle();
  }
  context.update();
  physics.update();





  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      //  stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      //    drawSkeleton(userList[i]);
    }
    if (context.getCoM(userList[i], com))
    {  
      //   println(com.z);
      context.convertRealWorldToProjective(com, com2d);
      // println(com2d.x, com2d.y);
     // text(Integer.toString(userList[i]), com2d.x, com2d.y);

      playerID = userList[i];
      println("player is " + playerID + "or" + userList[i]);
    }
  }



  PVector rightHand = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  PVector leftHand = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  PVector leftShoulder = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_LEFT_ELBOW, leftShoulder);
  PVector rightShoulder = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightShoulder);

  if (leftHand.z > rightHand.z) {
    whichHand = 1;
    //println("left");
  } else {
    whichHand = 2;
    //println("right");
  }
  PVector pointTo = new PVector();
  if (whichHand == 1) {
    pointTo.y = (((rightHand.y-rightShoulder.y)*rightShoulder.z)/(rightShoulder.z-rightHand.z))+rightShoulder.y;
    pointTo.x = (((rightHand.x-rightShoulder.x)*rightShoulder.z)/(rightShoulder.z-rightHand.z))+rightShoulder.x;
  } else if (whichHand == 2) {
    pointTo.y = (((leftHand.y-leftShoulder.y)*leftShoulder.z)/(leftShoulder.z-leftHand.z))+leftShoulder.y;
    pointTo.x = (((leftHand.x-leftShoulder.x)*leftShoulder.z)/(leftShoulder.z-leftHand.z))+leftShoulder.x;
  }

  fill(0);

  //you might tweak this depending on your resolution or physical setup
  ellipse(map(pointTo.x, -3000, 3000, 0, width), map(pointTo.y, 2000, -2000, 0, height), 30, 30);
  //  drawSkeleton(playerID);

  vecPos.x = map(pointTo.x, -3000, 3000, 0, width);
  vecPos.y= map(pointTo.y, 2000, -2000, 0, height);
  // create a new positive attraction force field around the mouse position (radius=250px)




  for (VerletParticle2D p : physics.particles) {
    //   ranger = new PVector(abs(pointTo.x-p.x), abs(pointTo.y-p.y));
    noStroke();

    float wDistancer = sqrt(sq(vecPos.x-width)+sq(vecPos.y-height));
  
        float pDistancer = sqrt(sq(vecPos.x-p.x)+sq(vecPos.y-p.y));
    if (pDistancer <= 300) {
        fill(255,0,0, 70+int((map(pDistancer, 300, 0, 0, 175))));
        ellipse(p.x, p.y, 30-(map(pDistancer, 300, 0, 0, 25)), 30-(map(pDistancer, 300, 0, 0, 25)));
    }
    else{
          fill(255,0,0, 70);
      ellipse(p.x, p.y, 30, 30);
    }
    for (VerletParticle2D f : physics.particles) {

  
      float fDistancer = sqrt(sq(vecPos.x-f.x)+sq(vecPos.y-f.y));
/*
      if (fDistancer <= 150) {
      
        line(vecPos.x, vecPos.y, f.x, f.y);
      }
      */
        if (fDistancer <= 200 && pDistancer <= 200) {
          float sDistancer = sqrt(sq(p.x-f.x)+sq(p.y-f.y));
          if(sDistancer <=50){
            stroke(255,0,0, 100);
        strokeWeight(1);
            line(p.x, p.y, f.x, f.y);
          }
      }
    }
  }
}


//make a stick figure guy


void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */
  pushMatrix();
  translate(363, 400);
  strokeWeight(20);
  stroke(255, 60, 60);
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);


  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
  popMatrix();
}


//SimpleOpenNI events


void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

