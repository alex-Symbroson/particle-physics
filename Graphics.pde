class Particle extends Kinematic {
  float radius;
  int coll = 1;
  
  Particle(float radius) { this(radius, null); }
  Particle(float radius, PVector pos) { this(radius, pos, null); }
  Particle(float radius, PVector pos, PVector vel) { this(radius, pos, vel, null); }
  Particle(float radius, PVector pos, PVector vel, PVector acc) {
    super(PI * radius * radius, pos,vel, acc);
    this.radius = radius;
  }
  
  Particle prev, cur;

  void display() {
    if (coll-- > 0) stroke(255,0,0);
    else stroke(0);
    ellipse(position.x, position.y, radius * 2, radius * 2);
  }
  
  void update()
  {
    prev = copyRef(prev);
    super.update();
    cur = copyRef(cur);
  }
  
  Particle copy() {
    return new Particle(radius, position, velocity, accelerate);
  }
  
  Particle copyRef(Particle p) {
    if (p == null) return new Particle(radius, position, velocity, accelerate);
    return p.set(this);
  }
  
  Particle set(Particle p) {
    super.set(p);
    radius = p.radius;
    return this;
  }
}

class Line {
  PVector start, end;
  PVector diff, normal;

  Line(float x1, float y1, float x2, float y2) {
    start = new PVector(x1, y1);
    end = new PVector(x2, y2);
    
    diff = PVector.sub(end, start);
    normal = new PVector(diff.y, -diff.x).normalize();
  }

  void display() {
    stroke(0);
    line(start.x, start.y, end.x, end.y);
  }
}
