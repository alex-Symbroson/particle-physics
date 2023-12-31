final boolean DARK = true;
final color T_BG = color(DARK ? 45 : 255);
final color T_STROKE = color(DARK ? 210 : 0);
final color T_RED = DARK ? color(255,50,50) : color(255,0,0);
final color T_GREEN = DARK ? color(0,250,0) : color(100,200,100);
final color T_BLUE = DARK ? color(100,200,255) : color(100,100,200);
final color T_LGREY = DARK ? color(100) : color(200);
final color T_GREY = DARK ? color(200) : color(100);

class Particle extends Kinematic {
  float radius;
  
  Particle() { this(50); }
  Particle(float radius) { this(radius, null); }
  Particle(float radius, PVector pos) { this(radius, pos, null); }
  Particle(float radius, PVector pos, PVector vel) { this(radius, pos, vel, null); }
  Particle(float radius, PVector pos, PVector vel, PVector acc) {
    super(PI * radius * radius, pos,vel, acc);
    this.radius = radius;
  }
  
  Particle prev, cur, last;

  void display() { display(true); }
  void display(boolean col) {
    if (col)
    {
      if (coll > 0 && DBG_COLL) stroke(T_RED);
      else stroke(T_STROKE);
      if (coll > 0) coll--;
    }
    ellipse(position.x, position.y, radius * 2, radius * 2);
    
    if (!DBG_VEL) return;
    //stroke(200, 200, 255);
    //ellipse(a.prev.position.x, a.prev.position.y, 2*a.radius, 2*a.radius);
    if (col) stroke(T_BLUE);
    ellipse(position.x, position.y, 2, 2);
    line(position.x, position.y, position.x + velocity.x/6, position.y + velocity.y/6);

    if (!SIMULATE && last != null && col) set(last);
  }
  
  void update() { update(false); }
  void update(boolean intense)
  {
    if (!simulate) return;
    prev = copyRef(prev);
    if (SIMULATE && !intense) super.update();
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
        radius, position.x, position.y, velocity.x, velocity.y);
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
    if (!simulate) return;
    boolean ctrlVel = keyPressed && keyCode == CONTROL;
    if (ctrlVel) {
      velocity.set(mouseX - position.x, mouseY - position.y);
    }
    else position.set(mouseX, mouseY);
    
    prev = copyRef(prev);
    cur = copyRef(cur);
    last = copyRef(last);

    if (ctrlVel) return;
    prev.position.sub(PVector.mult(velocity, PHYSICS_STEPS * DT));
    prev.velocity.sub(PVector.mult(accelerate, PHYSICS_STEPS * DT));
    last.set(prev);
  }
}

class Line {
  PVector start, end;

  Line(float x1, float y1, float x2, float y2) {
    start = vec(x1, y1);
    end = vec(x2, y2);
  }

  void display() {
    stroke(T_STROKE);
    line(start.x, start.y, end.x, end.y);
  }

  PVector diff() { return PVector.sub(end, start); }
  PVector dir() { return diff().normalize(); }
  PVector normal() { return vec(end.y - start.y, start.x - end.x).normalize(); }
}
