
void checkNan(Particle p, String s)
{
  // boolean wasNan = Float.isNaN(particle.position.x)||Float.isNaN(particle.position.y);
  if (
    Float.isInfinite(p.position.x) || Float.isInfinite(p.position.y))||
    !Float.isFinite(p.position.x) || !Float.isFinite(p.position.y)||
    Float.isNaN(p.position.x) || Float.isNaN(p.position.y)
  {
    println("NAN "+p+" "+s);
    p.position.set(p.radius, p.radius);
    pause = true;
  }
}

boolean reflect(Particle p, Line l) {
  boolean intense = false;
  PVector pp = p.cur.position;
  PVector pv = p.cur.velocity;
  stroke(255, 150, 255);
  p.display(false);

  float t = collisionTime(p.cur, l);
  p.display(false);
  if (t != 0) return true;

  if (t == 0) return false;
  if (t < -4*DT) intense = true;

  float dot = PVector.dot(pv, l.normal());

  if (intense)
  {
    float d = distance(pp, l);
    stroke(T_RED);
    p.cur.display(false);
    p.display(false);
    p.velocity.sub(PVector.mult(l.normal(), 2 * dot));
    p.position.add(PVector.mult(l.normal(), dot < 0 ? d : -d));
    stroke(T_GREEN);
    p.display(false);
    return true;
  }

  p.position.add(PVector.mult(pv, t));
  p.velocity.sub(PVector.mult(l.normal(), 2 * dot));
  p.position.add(PVector.mult(pv, -t));
  return false;
}

boolean reflect(Particle a, Particle b) {
  final PVector pa = a.cur.position, pb = b.cur.position;
  final PVector va = a.cur.velocity, vb = b.cur.velocity;
  boolean intense = false;

  // collision time
  float t = collisionTime(a.cur, b.cur);
  if (t == 0) return false;
  if (t < -4 * DT)
  {
    intense = true;

    if (DBG_INTENSE) {
      Particle virt = a.copy();
      virt.position.add(PVector.mult(a.velocity, t));
      stroke(T_GREEN);
      a.cur.display(false);
      stroke(T_LGREY);
      virt.display(false);
    }
  } else if (SIMULATE) {
    a.position.add(PVector.mult(a.velocity, t));
  }

  PVector diff = PVector.sub(pb, pa);
  PVector normal = diff.copy().normalize();
  PVector tang = vec(normal.y, -normal.x);

  if (intense) {
    float d_4 = (diff.mag() - a.radius - b.radius) / 4;
    a.position.add(PVector.mult(normal, d_4));
    b.position.sub(PVector.mult(normal, d_4));
    return true;
  }

  float va_n = PVector.dot(va, normal);
  float vb_n = PVector.dot(vb, normal);
  float va_t = PVector.dot(va, tang);

  float v_new = (2 * vb_n * b.mass + va_n * (a.mass - b.mass)) / (a.mass + b.mass);
  if (SIMULATE && !intense) a.velocity = PVector.mult(tang, va_t).add(PVector.mult(normal, v_new));
  if (SIMULATE && !intense) a.position.add(PVector.mult(a.velocity, -t));
  if (intense && DBG_INTENSE)
  {
    stroke(T_GREY);
    a.prev.display(false);
    stroke(T_BLUE);
    a.display(false);
  }
  return intense;
}

float collisionTime(Particle p1, Particle p2) {
  PVector relativeVelocity = PVector.sub(p2.velocity, p1.velocity);
  PVector relativePosition = PVector.sub(p2.position, p1.position);
  float radiusSum = p1.radius + p2.radius;

  // formula for distance over time
  // x1,2 = (-b +- sqrt(b*b - 4ac)) / 2a
  float a = PVector.dot(relativeVelocity, relativeVelocity);
  float b = 2.0 * PVector.dot(relativeVelocity, relativePosition);
  float c = PVector.dot(relativePosition, relativePosition) - (radiusSum * radiusSum);

  float discriminant = b * b - 4 * a * c;
  if (discriminant < 1e-6 || a == 0) return 0; // no collision

  // discard positive discriminant to ignore backward motion collisions
  float t = (-b - sqrt(discriminant)) / (2 * a);
  //print(round(t*1e3)/1e3 + " " + (1/frameRate)+"\n");
  return t; //frameCount < 100 ? t : constrain(t, -10, 0);
}

float collisionTime(Particle p, Line line) {
  // Calculate the relative velocity between the particle and line
  PVector relativeVelocity = PVector.sub(p.velocity, line.diff());
  PVector normal = line.normal();

  float dist = PVector.dot(PVector.sub(line.start, p.position), normal);
  float time = dist / PVector.dot(relativeVelocity, normal);

  // line - pcoll correction
  float dt = p.radius / PVector.dot(p.velocity, normal);
  return dist * time > 0 ? time - dt : time + dt;
}


boolean intersects(Particle p, Line l) {
  return distance(p.position, l) <= p.radius;
}

boolean intersects(Particle a, Particle b) {
  return PVector.dist(a.position, b.position) <= a.radius + b.radius;
}

// Distance from a point to a line segment
float distance(Particle p, PVector pos) {
  return PVector.dist(p.position, pos) - p.radius;
}
 //<>//
// Distance from a point to a line segment
float distance(PVector pos, Line l) {
  PVector v = PVector.sub(l.end, l.start);
  PVector w = PVector.sub(pos, l.start);

  float t = w.dot(v) / v.dot(v);
  t = constrain(t, 0, 1);

  PVector closest = PVector.add(l.start, PVector.mult(v, t));
  return PVector.dist(pos, closest);
}

float distance(Particle p, Line l) {
  return distance(p.position, l) - p.radius; //<>//
}
