

class Armature {
  Particle head, neck, hip, knee, foot;
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector target;
  float r;
  float r2;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int headingx;
  int headingy;
  int counter;
  int count;
  float anum;
  float anumcalc;
  int bodyLength;
  Armature(float x, float y) {
    acceleration = new PVector(10, 10);
    velocity = new PVector(0, 0);
    location = new PVector(x, y);
    target = new PVector(headingx, headingy);
    r2 = 2;
    maxspeed = 1;
    maxforce = 0.02;
    count = int(random(200));
    bodyLength = int(random(5, 20));

    head = new Particle(width/2, height/2);
    physics.addParticle(head);
    neck = new Particle(width/2 + 30, height/2);
    physics.addParticle(neck);
    hip = new Particle(width/2 + 60, height/2);
    physics.addParticle(hip); 
    knee = new Particle(width/2 + 90, height/2);
    physics.addParticle(knee); 
    foot = new Particle(width/2 + 120, height/2);
    physics.addParticle(foot); 

    //option to give each particle some repulsion, tends to help in low drag situations
    /*if (bodyLength >= 4) {
     physics.addBehavior(new AttractionBehavior(head, bodyLength-2, -1.2f, 0.01f));
     physics.addBehavior(new AttractionBehavior(neck, bodyLength-2, -1.2f, 0.01f));
     physics.addBehavior(new AttractionBehavior(hip, bodyLength-2, -1.2f, 0.01f));
     physics.addBehavior(new AttractionBehavior(knee, bodyLength-2, -1.2f, 0.01f));
     physics.addBehavior(new AttractionBehavior(foot, bodyLength-2, -1.2f, 0.01f));
     }*/
    VerletSpring2D spring=new VerletSpring2D(head, neck, bodyLength, 0.1);
    physics.addSpring(spring);
    VerletSpring2D spring2=new VerletSpring2D(neck, hip, bodyLength, 0.1);
    physics.addSpring(spring2);
    VerletSpring2D spring3=new VerletSpring2D(hip, knee, bodyLength, 0.1);
    physics.addSpring(spring3);
    VerletSpring2D spring4=new VerletSpring2D(knee, foot, bodyLength, 0.1);
    physics.addSpring(spring4);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelerationelertion to 0 each cycle
    acceleration.mult(0);
    if (counter >= count) {
      counter = 0;

      //changing this line changes the tendency to change heading.  I highly recommend perlin noise here.
      count = int(random(200));

      headingx = int(random(width));
      headingy = int(random(height));
    }
    target.x = headingx;
    target.y = headingy;

    counter++;
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // A method that calculates a steering force towards a target
  void arrive() {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    float d = desired.mag();
    if (d < 100) {
      float m = map(d, 0, 100, 0, maxspeed);
      desired.setMag(m);
    } else {
      desired.setMag(maxspeed);
    }

    //changing the properties of this line changes the overal vigor and speed of swimming, before scale
    anumcalc = .06*(desired.magSq()*(20/bodyLength));
    println(desired.magSq());
    anum+=anumcalc;
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }

  void display() {



    head.lock();

    //more swimming motion stuff
    head.x=location.x + (((bodyLength))-abs(velocity.mag()))*(sin(anum)*velocity.y);
    head.y=location.y + (((bodyLength))-abs(velocity.mag()))*((-1*sin(anum))*velocity.x); //+ .1*(1-sin(anum)*target.x);



    r = r2*(map(bodyLength, 5, 20, .5, 3));


    stroke(0);
    strokeWeight(2);
    line(head.x, head.y, neck.x, neck.y);
    line(neck.x, neck.y, hip.x, hip.y);
    line(hip.x, hip.y, knee.x, knee.y);
    line(knee.x, knee.y, foot.x, foot.y);




    head.display();
    neck.display();
    hip.display();
    knee.display();
    foot.display();
  }
}
class Particle extends VerletParticle2D {

  Particle(float x, float y) {
    super(x, y);
  }
  void display() {
    fill(175);
    stroke(0);
    ellipse(x, y, 5, 5);
  }
}

