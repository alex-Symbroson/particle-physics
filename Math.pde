
static boolean intersects(Particle p, Line l) {
  return distance(p.position, l) <= p.radius;
}

static void reflect(Particle p, Line l) {
  Particle pp = p.cur;
  PVector prevPos = p.prev.position.copy();
  float dist2 = l.start.copy().sub(prevPos).dot(l.normal);
  if(dist2 > 0) pp.radius = -pp.radius;
  dist2 += pp.radius;
  float dist1 = l.start.copy().sub(pp.position).dot(l.normal) + pp.radius;
  
  if (dist1 * dist2 >= 0) return;
  p.coll = 20;
  
  float dot = pp.velocity.copy().dot(l.normal);
  float t = dist2 / dot;
  prevPos.add(pp.velocity.copy().mult(t));
  
  p.velocity.sub(l.normal.copy().mult(2 * dot)).mult(0.7);
  p.position.set(prevPos.add(pp.velocity.copy().mult(1-t)));
}


static void reflect2(Particle p, Line l) {
  Particle pp = p.cur;
  PVector direction = PVector.sub(l.end, l.start).normalize();
  PVector normal = new PVector(direction.y, -direction.x);
  PVector prev = PVector.sub(pp.position, pp.velocity);
  float dist1 = PVector.sub(pp.position, l.start).dot(normal);
  float dist2 = PVector.sub(prev, l.start).dot(normal);
  if (dist1 * dist2 > 0) return;
  p.coll = 20;
  
  float t = dist1 / (dist1 - dist2);
  float dot = PVector.dot(pp.velocity, normal);
  
  //particle.position.add(PVector.mult(particle.velocity, -t));
  p.velocity.sub(normal.mult(2 * dot)).mult(0.9);
  //particle.position.add(PVector.mult(particle.velocity, t));
}

// Distance from a point to a line segment
static float distance(Particle p, PVector pos) {
  return PVector.dist(p.position, pos) - p.radius;
}

// Distance from a point to a line segment
static float distance(PVector pos, Line l) {
  PVector v = PVector.sub(l.end, l.start);
  PVector w = PVector.sub(pos, l.start);
  
  float t = w.dot(v) / v.dot(v);
  t = constrain(t, 0, 1);
  
  PVector closest = PVector.add(l.start, PVector.mult(v, t));
  float d = PVector.dist(pos, closest);
  
  return d;
}

static float distance(Particle p, Line l) {
  return distance(p.position, l) - p.radius;
}
