

class Kinematic {
  static final float GRAVITY = 0.1;
  
  PVector position = new PVector();
  PVector velocity = new PVector();
  PVector accelerate = new PVector();
  float mass = 1;

  Kinematic() { }
  Kinematic(float mass) { this(mass, null); }
  Kinematic(float mass, PVector pos) { this(mass, pos, null); }
  Kinematic(float mass, PVector pos, PVector vel) { this(mass, pos, vel, null); }
  Kinematic(float mass, PVector pos, PVector vel, PVector acc) {
    if (pos != null) position.set(pos);
    if (vel != null) velocity.set(vel);
    if (acc != null) accelerate.set(acc);
    this.mass = mass;
  }

  void update() {
    float dt = 1/60;
    velocity.add(PVector.mult(accelerate, dt));
    velocity.y += Kinematic.GRAVITY*dt;
    position.add(PVector.mult(velocity, dt));
  }
  
  Kinematic copy() {
    return new Kinematic(mass, position, velocity, accelerate);
  }
  
  Kinematic copyRef(Kinematic p) {
    if (p == null) return new Kinematic(mass, position, velocity, accelerate);
    return p.set(this);
  }
  
  Kinematic set(Kinematic k) {
    position.set(k.position);
    velocity.set(k.velocity);
    accelerate.set(k.accelerate);
    mass = k.mass;
    return this;
  }
}
