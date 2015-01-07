//Simple particle chains that oscillate as if to swim, to be used as an animation tool (or whatever)
//Thanks to Karsten Schmidt, Craig Reynolds, Dan Shiffman.
//adamsamson.us
import toxi.geom.*;
import toxi.physics2d.*;
import SimpleOpenNI.*;
import toxi.physics2d.behaviors.*;

VerletPhysics2D physics;
ArrayList<Armature> v;



void setup() {
  size(640, 1136);

  physics = new VerletPhysics2D();
  physics.setDrag(0.08f);
  v = new ArrayList<Armature>();
  for (int i=0; i <= 20; i++) {
    v.add(new Armature(int(random(width)), int(random(height))));
  }
}

void draw() {
  background(255);

  physics.update();
  // Draw an ellipse at the mouse location
  fill(200);
  stroke(0);
  strokeWeight(2);

  // Steering Behavior Stuff
  for (int i=0; i <= 20; i++) {
    Armature q = v.get(i);
    q.arrive();
    q.update();
    q.display();
  }

}

