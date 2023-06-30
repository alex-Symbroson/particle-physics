
final PVector R_RADIUS = vec(30, 80);   // radius random range
final PVector R_SPEED = vec(400, 200); // horiz/vert random speed range
final float GRAVITY = 200;
final float COLL_LOSS = 0.99;

final int NUM_PARTICLES = 0;
final int NUM_LINES = 1;
final int FPS_FRAMES = 10;

final int PHYSICS_STEPS = 10;
final float FPS = 60;
final float DT = 1 / (FPS * PHYSICS_STEPS);

final boolean SAVE = false;           // save every FPS_FRAMES'th frame as image
final boolean SIMULATE = !true;        // physics not applied, mouse steered particle
final boolean DEMO_PARTICLES = false; // load defined list of particles

final boolean DBG_COLL = !false;      // red collision particles
final boolean DBG_VEL = !false;        // velocity direction indicator
final boolean DBG_INTENSE = false;    // debug collisions with large dt

ArrayList<Particle> particles;
ArrayList<Line> lines;
float deltaTime;

PVector vec() { return new PVector(); }
PVector vec(float x, float y) { return new PVector(x, y); }
PVector vec(float x, float y, float z) { return new PVector(x, y, z); }

void debugParticles() {
  Particle ps[] = {};
  for(Particle p : ps) particles.add(p);
}

void setup() {
  clearFiles();
  size(800, 600);

  particles = new ArrayList<Particle>();
  lines = new ArrayList<Line>();

  if (!SIMULATE) particles.add(new MouseParticle().set(spawnParticle()));
  if (DEMO_PARTICLES) debugParticles();
  else for (int i = 0; i < NUM_PARTICLES; i++) particles.add(spawnParticle());
  for (int i = 0; i < NUM_LINES; i++) createRandomLine();
}

boolean intense = true, pause = false;
int save = 0, tPhys = 0, tDraw = 0, tFPS = 0, physFPS, drawFPS;
boolean keyPress = false;
void draw() {
  frameRate(10);
  if (keyPressed && !keyPress && key == 'd') clearFiles();
  if (keyPressed && !keyPress && key == ' ') { pause = !pause; intense = false; }
  keyPress = keyPressed;
  //if (intense) pause = true;
  if (pause && frameCount != 1) return;
  frameRate(60);

  background(T_BG);
  noFill();
  
  snapLines();

  // physics
  int time = millis();
  for (Particle p : particles) p.last = p.copyRef(p.last);
  for (int q = 0; q < PHYSICS_STEPS; q++)
    handlePhysics();
  tPhys += millis() - time;
  
  // draw
  time = millis();
  for (Particle particle : particles) particle.display();
  for (Line line : lines) line.display();
  tDraw += millis() - time;
  
  // fps
  if (++tFPS > FPS_FRAMES) {
    if (tPhys != 0) physFPS = tFPS*1000 / tPhys;
    if (tDraw != 0) drawFPS = tFPS*1000 / tDraw;
    tFPS = 0;
    tPhys = 0;
  }
  text(physFPS, 0, height);
  text(drawFPS, 20, height);
  
  // reset
  if (SIMULATE)
    for (Particle p : particles) p.set(p.last);
  /* if (intense) {
    println("=== intense ===");
    for(Particle p : particles) println(p);
  } */
  
  if (!SAVE) return;
  if (frameCount % 5 == 0) save++;
  if (intense) save += 5;
  if (save > 0) { saveFrame("physics-#####.png"); save--; }
}

void snapLines()
{
  PVector mouse = vec(mouseX, mouseY);
  PVector lp = null;
  float dist, minLpDist = 1e6;
  for (Line line : lines) {
    dist = PVector.dist(line.start, mouse);
    if (mousePressed && dist < 50 && dist < minLpDist) lp = line.start;
    dist = PVector.dist(line.end, mouse);
    if (mousePressed && dist < 50 && dist < minLpDist) lp = line.end;
  }
  if (lp != null) lp.set(mouse);
}

void handlePhysics() {
  for (Particle particle : particles) particle.update(intense && false);

  // Update and display particles
  for (Particle particle : particles)
  {
    // Check collision with other particles
    for (Particle other : particles)
    {
      if (particle != other && intersects(particle.cur, other.cur)) 
      {
        particle.coll = 1;
        intense = reflect(particle, other) || intense;
        particle.velocity.mult(COLL_LOSS);
      }
    }
    
    // Check collision with lines
    for (Line line : lines) {
      if (intersects(particle.cur, line)) {
        particle.coll = 1;
        reflect(particle, line);
        particle.velocity.mult(COLL_LOSS);
      }
    }
    
    // Check collision with screen edges
    if (particle.position.x < particle.radius) {
      particle.velocity.x = abs(particle.velocity.x);
      particle.position.x = particle.radius;
      particle.velocity.mult(COLL_LOSS);
    }
    if (particle.position.x > width - particle.radius) {
      particle.velocity.x = -abs(particle.velocity.x);
      particle.position.x = width - particle.radius;
      particle.velocity.mult(COLL_LOSS);
    }
    if (particle.position.y < particle.radius) {
      particle.velocity.y = abs(particle.velocity.y);
      particle.position.y = particle.radius;
      particle.velocity.mult(COLL_LOSS);
    }
    if (particle.position.y > height - particle.radius) {
      particle.velocity.y = -abs(particle.velocity.y);
      particle.position.y = height - particle.radius;
      particle.velocity.mult(COLL_LOSS);
    }
    //if (particle.velocity.x < 0 && particle.position.x < particle.radius) particle.position.x = width+particle.radius;
    //if (particle.velocity.x > 0 && particle.position.x > width - particle.radius) particle.position.x = -particle.radius;
    //if (particle.velocity.y < 0 && particle.position.y < particle.radius) particle.position.y = height+particle.radius;
    //if (particle.velocity.y > 0 && particle.position.y > height - particle.radius) particle.position.y = -particle.radius;
  }
}

Particle spawnParticle() {
  float radius = random(R_RADIUS.x, R_RADIUS.y);
  PVector speed = vec(random(-R_SPEED.x, R_SPEED.x), random(-R_SPEED.y, R_SPEED.y));
  Particle particle = new Particle(radius, null, speed);

  loop1: while(true)
  {
    particle.position.x = random(radius, width - radius);
    particle.position.y = random(radius, height - radius);
    for (Particle other : particles) 
      if (intersects(particle, other))
        continue loop1;
    break;
  }
  
  return particle;
}

void createRandomLine() {
  float x1 = random(width);
  float y1 = random(height);
  float x2 = random(width);
  float y2 = random(height);
  Line line = new Line(x1, y1, x2, y2);
  lines.add(line);
}

void clearFiles() {
  File dir = new File(sketchPath(""));
  File[] files = dir.listFiles();
  
  // Delete PNG files
  if (files == null) return;
  for (File file : files) {
    if (file.isFile() && file.getName().toLowerCase().endsWith(".png")) {
      file.delete();
      println("Deleted file: " + file.getName());
    }
  }
}
