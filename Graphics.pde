final boolean DARK = true;
final color T_BG = color(DARK ? 45 : 255);
final color T_STROKE = color(DARK ? 210 : 0);
final color T_RED = DARK ? color(255,50,50) : color(255,0,0);
final color T_GREEN = DARK ? color(250,0,0) : color(100,200,100);
final color T_BLUE = DARK ? color(100,50,255) : color(100,100,200);
final color T_LGREY = DARK ? color(100) : color(200);
final color T_GREY = DARK ? color(200) : color(100);

class Particle extends Kinematic {
  float radius;
  int coll = 1;
  
  Particle() { this(50); }
  Particle(float radius) { this(radius, null); }
  Particle(float radius, PVector pos) { this(radius, pos, null); }
  Particle(float radius, PVector pos, PVector vel) { this(radius, pos, vel, null); }
  Particle(float radius, PVector pos, PVector vel, PVector acc) {
    super(PI * radius * radius, pos,vel, acc);
    this.radius = radius;
  }
  
  Particle prev, cur;

  void display() { display(true); }
  void display(boolean col) {
    if(col)
    {
      if (coll-- > 0 && DBG_PARTICLES) stroke(T_RED);
      else stroke(T_STROKE);
    }
    ellipse(position.x, position.y, radius * 2, radius * 2);
    
    if (!DBG_PARTICLES) return;
    //stroke(200, 200, 255);
    //ellipse(a.prev.position.x, a.prev.position.y, 2*a.radius, 2*a.radius);
    if (col) stroke(T_BLUE);
    ellipse(position.x, position.y, 2, 2);
    line(position.x, position.y, position.x + velocity.x/6, position.y + velocity.y/6);
  }
  
  void update() { update(false); }
  void update(boolean intense)
  {
    prev = copyRef(prev);
    if (SIMULATE) {
      if (!intense) super.update();
    } else {
      prev.position.sub(velocity);
      prev.velocity.sub(accelerate);
    }
    cur = copyRef(cur);
  }
  
  Particle copy() {
    return new Particle(radius, position, velocity, accelerate);
  }
  
  // returns p or new Particle with this props
  Particle copyRef(Particle p) {
    if (p == null) return new Particle(radius, position, velocity, accelerate);
    return p.set(this);
  }
  
  Particle set(Particle p) {
    super.set(p);
    radius = p.radius;
    return this;
  }
  
  @Override
  public String toString() {
      return String.format("Particle(%.3f, (%.3f, %.3f), (%.3f, %.3f))", 
        radius, prev.position.x, prev.position.y, prev.velocity.x, prev.velocity.y);
  }
}

class MouseParticle extends Particle {
  MouseParticle() { super(); }
  MouseParticle(float radius) { super(radius); }
  MouseParticle(float radius, PVector pos) { super(radius, pos); }
  MouseParticle(float radius, PVector pos, PVector vel) { super(radius, pos, vel); }
  
  @Override
  void update(boolean intense)
  {
    println("hello");
    position.set(mouseX, mouseY);
    prev = copyRef(prev);
    cur = copyRef(cur);

    prev.position.sub(velocity);
    prev.velocity.sub(accelerate);
  }
}

class Line {
  PVector start, end;
  PVector diff, normal;

  Line(float x1, float y1, float x2, float y2) {
    start = vec(x1, y1);
    end = vec(x2, y2);
    
    diff = PVector.sub(end, start);
    normal = vec(diff.y, -diff.x).normalize();
  }

  void display() {
    stroke(T_STROKE);
    line(start.x, start.y, end.x, end.y);
  }
}
