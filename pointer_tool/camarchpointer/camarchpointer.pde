//Accurate translation of kinect pointing gesture into a cursor.
//adamsamson.us

import SimpleOpenNI.*;
int whichHand = 0;
PVector com = new PVector();                                   
PVector com2d = new PVector(); 
int playerID;
SimpleOpenNI context;



void setup() {
  size(1366, 768);
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
}

void draw() {

  background(255);

  context.update();
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
      text(Integer.toString(userList[i]), com2d.x, com2d.y);

      playerID = userList[i];
      println("player is " + playerID + "or" + userList[i]);
    }
  }



  PVector rightHand = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  PVector leftHand = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  PVector leftShoulder = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
  PVector rightShoulder = new PVector();
  context.getJointPositionSkeleton(playerID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);

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
  drawSkeleton(playerID);
  
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
  strokeWeight(50);
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


