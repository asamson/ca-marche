//a stupid toxiclibs yoyo with kinect input. thanks to dan shiffman and karsten schmidt.
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.geom.*;
import SimpleOpenNI.*;
VerletPhysics2D physics;
SimpleOpenNI context;
Chain chain;
PVector com = new PVector();                                   
PVector com2d = new PVector();   
PVector jointPos = new PVector();
PVector jointPos2d = new PVector();
void setup() {
  size(640, 480);
  smooth();
  context = new SimpleOpenNI(this);
  // Initialize the physics world
  physics=new VerletPhysics2D();
  physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.6)));
  physics.setWorldBounds(new Rect(0, 0, width, height));

  // Initialize the chain
  chain = new Chain(200, 20, 12, 0.2);
  context.enableDepth();
  context.enableUser();
}

void draw() {
  background(255);
  context.update();
  image(context.depthImage(), 0, 0);
  // Update physics
  physics.update();
  // Update chain's tail according to mouse location 
  chain.updateTail(mouseX, mouseY);
  // Display chain
  chain.display();



  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {

      if (context.getCoM(userList[i], com))
      {
        context.convertRealWorldToProjective(com, com2d);
        VerletParticle2D head=physics.particles.get(0);

        context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, jointPos);
        context.convertRealWorldToProjective(jointPos, jointPos2d);
        println(jointPos2d);
        head.lock();
        head.x = jointPos2d.x;
        head.y = jointPos2d.y;
      }
    }
  }
}


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


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

