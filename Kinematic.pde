

class Kinematic {
  PVector position = vec();
  PVector velocity = vec();
  PVector accelerate = vec();
  boolean simulate = true;
  float mass = 1;
  int coll = 0;

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
    if (!simulate) return;
    velocity.add(PVector.mult(accelerate, DT));
    velocity.y += GRAVITY * DT;
    position.add(PVector.mult(velocity, DT));
  }

  void accel(PVector a) {
    velocity.add(PVector.mult(a, DT));
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

int spatialHash(Particle p)
{
  return spatialHashCoords(p.position.x, p.position.y);
}

int spatialHashCoords(float x, float y)
{
  int cellX = (int)(GRID * x / width);
  int cellY = (int)(GRID * y / height);
  return GRID * cellY + cellX;
}
