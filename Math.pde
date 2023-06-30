
void reflect(Particle p, Line l) {
  PVector pp = p.cur.position;
  PVector pv = p.cur.velocity;
  PVector prevPos = p.prev.position.copy();
  PVector tang = PVector.sub(l.start, prevPos).normalize();
  float dist2 = PVector.sub(l.start, prevPos).dot(l.normal);
  float radius = dist2 > 0 ? -p.radius : p.radius;
  dist2 += radius;
  float dist1 = PVector.sub(l.start, pp).dot(l.normal) + radius;
  
  if (dist1 * dist2 >= 0) return;
  
  float dot = PVector.dot(pv, tang);
  float t = dist2 / dot;
  p.position.add(PVector.mult(pv, t));
  p.display();
  
  p.velocity.sub(PVector.mult(l.normal, 2 * dot)).mult(0.7);
  p.position.add(PVector.mult(pv, 1-t));
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
    float d_2 = -(diff.mag() - a.radius - b.radius) / 2;
    a.position.sub(PVector.mult(normal, d_2));
    b.position.add(PVector.mult(normal, d_2));
    return true;
  }

  float va_n = PVector.dot(va, normal);
  float vb_n = PVector.dot(vb, normal);
  float va_t = PVector.dot(va, tang);
  
  float v_new = (2*vb_n*b.mass + va_n*(a.mass - b.mass)) / (a.mass + b.mass);
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
    if (discriminant < 0) return 0; // no collision
    
    // discard positive discriminant to ignore backward motion collisions
    float t = (-b - sqrt(discriminant)) / (2 * a);
    //print(round(t*1e3)/1e3 + " " + (1/frameRate)+"\n");
    return t; //frameCount < 100 ? t : constrain(t, -10, 0);
}

void reflect2(Particle p, Line l) {
  Particle pp = p.cur;
  PVector direction = PVector.sub(l.end, l.start).normalize();
  PVector normal = vec(direction.y, -direction.x);
  PVector prev = PVector.sub(pp.position, pp.velocity);
  float dist1 = PVector.sub(pp.position, l.start).dot(normal);
  float dist2 = PVector.sub(prev, l.start).dot(normal);
  if (dist1 * dist2 > 0) return;
  
  float t = dist1 / (dist1 - dist2);
  float dot = PVector.dot(pp.velocity, normal);
  
  p.position.add(PVector.mult(p.velocity, -t));
  p.display();
  p.velocity.sub(normal.mult(2 * dot)).mult(0.9);
  p.position.add(PVector.mult(p.velocity, t));
}

float collisionTime(Particle p, Line l) {
    PVector lineDirection = PVector.sub(l.end, l.start).normalize();
    PVector particleToLineStart = PVector.sub(l.start, p.position);

    // Calculate the perpendicular distance from the particle to the line
    float perpendicularDistance = abs(PVector.dot(particleToLineStart, l.normal));

    // Calculate the time of intersection with the line
    float t = PVector.dot(lineDirection, particleToLineStart) / PVector.dot(p.velocity, lineDirection);

    // Calculate the point of intersection
    PVector intersectionPoint = PVector.mult(p.velocity, t).add(p.position);

    // Check if the particle collides with the line within the line segment
    float lineLength = PVector.dist(l.start, l.end);
    float distanceAlongLine = PVector.dot(lineDirection, PVector.sub(intersectionPoint, l.start));

    p.display();
    p.position.add(PVector.mult(p.velocity, t));
    p.display();
    if (distanceAlongLine >= 0.0 && distanceAlongLine <= lineLength && perpendicularDistance <= p.radius) {
        return t;
    } else {
        return -1.0; // No collision within the given constraints
    }
}


boolean intersects(Particle p, Line l) {
  return distance(p.position, l) <= p.radius;
}

boolean intersects(Particle a, Particle b) {
  return PVector.dist(a.position, b.position) <= a.radius + b.radius; //<>//
}

// Distance from a point to a line segment
float distance(Particle p, PVector pos) {
  return PVector.dist(p.position, pos) - p.radius;
}

// Distance from a point to a line segment
float distance(PVector pos, Line l) {
  PVector v = PVector.sub(l.end, l.start);
  PVector w = PVector.sub(pos, l.start);
  
  float t = w.dot(v) / v.dot(v);
  t = constrain(t, 0, 1);
  
  PVector closest = PVector.add(l.start, PVector.mult(v, t));
  return PVector.dist(pos, closest);
}

float collisionTime2(Particle p, Line l) {
  float d = distance(p, l);
  PVector v = PVector.sub(l.end, l.start);
  PVector w = p.velocity.copy();
  
  float t = d / v.dot(w);
  t = constrain(t, 0, 1);
  
  PVector closest = PVector.add(l.start, PVector.mult(v, t));
  return PVector.dist(p.position, closest);
}

float distance(Particle p, Line l) {
  return distance(p.position, l) - p.radius;
}
