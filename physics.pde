
final PVector R_RADIUS = vec(1, 7);    // radius random range
final PVector R_SPEED = vec(400, 200); // horiz/vert random speed range
final float GRAVITY = 200;
final float COLL_LOSS = 0.95;
final float SNAP_DIST = 40;            // max distance for mouse line movement

final int NUM_PARTICLES = 1000;
final int NUM_LINES = 6;
final int FPS_FRAMES = 10;
final int FONTSIZE = 15;

final int GRID = 30;

final float FPS = 60;
int PHYSICS_STEPS = 10;
float DT = 1 / (FPS * PHYSICS_STEPS);

boolean HELP = true;            // display help
boolean SAVE = false;           // save every FPS_FRAMES'th frame as image
boolean SIMULATE = true;        // physics not applied, mouse steered particle
final boolean DEMO_PARTICLES = false; // load defined list of particles

boolean DBG_COLL = false;       // red collision particles
boolean DBG_VEL = false;        // velocity direction indicator
boolean DBG_INTENSE = false;    // debug collisions with large dt

ArrayList<Particle> particles, forceFields;
ArrayList<Line> lines;
float deltaTime;

PVector vec() { return new PVector(); }
PVector vec(float x, float y) { return new PVector(x, y); }
PVector vec(float x, float y, float z) { return new PVector(x, y, z); }

void debugParticles() {
  Particle ps[] = {};
  for (Particle p : ps) particles.add(p);
}

void setup() {
  clearFiles();
  size(800, 600);
  textFont(createFont("Monospaced.bold", FONTSIZE));

  particles = new ArrayList<Particle>();
  forceFields = new ArrayList<Particle>();
  lines = new ArrayList<Line>();

  if (!SIMULATE) particles.add(new MouseParticle().set(spawnParticle()));
  if (DEMO_PARTICLES) debugParticles();
  else for (int i = 0; i < NUM_PARTICLES; i++) particles.add(spawnParticle());
  for (int i = 0; i < NUM_LINES; i++) createRandomLine();
}

boolean intense = true, pause = false;
int save = 0, tPhys = 0, tDraw = 0, tFPS = 0, physFPS, drawFPS;
PVector lp = null;
Particle fp = null;

boolean keyPress = false, mousePress = false, keyDown, keyUp, mouseDown, mouseUp;
void keyHandler()
{
  keyDown = keyPressed && !keyPress;
  keyUp = !keyPressed && keyPress;
  mouseDown = mousePressed && !mousePress;
  mouseUp = !mousePressed && mousePress;
  if (keyDown || keyUp) println((keyDown ? "keyDown " : "keyUp ") + key);
  if (mouseDown || mouseUp) println((mouseDown ? "mouseDown " : "mouseUp ") + mouseButton);
  keyPress = keyPressed;
  mousePress = mousePressed;

  if (keyDown && key == 'd') clearFiles();
  if (keyDown && key == ' ') { pause = !pause; intense = false; }
  if (keyDown && key == 'c') { DBG_COLL = !DBG_COLL; }
  if (keyDown && key == 'v') { DBG_VEL = !DBG_VEL; }
  if (keyDown && key == 'r') { SAVE = !SAVE; }
  if (keyDown && key == 'i') { DBG_INTENSE = !DBG_INTENSE; }
  if (keyDown && key == 'h') { HELP = !HELP; }
  if (keyDown && key == 'l') { SIMULATE = !SIMULATE; }
  if (keyDown && key == 'f') { fp.simulate = false; fp = null; }
  if (keyDown && key == '+') { PHYSICS_STEPS++; }
  if (keyDown && key == '-') { if (PHYSICS_STEPS > 1) PHYSICS_STEPS--; }
  if (keyDown && key == 'p') { for (Particle p : particles) println(p); println("----"); }
  DT = 1 / (FPS * PHYSICS_STEPS);
}

void printHelp()
{
  fill(T_BG);
  stroke(T_STROKE);
  rect(width-250, -1, width, 300-FONTSIZE);
  fill(T_STROKE);
  String[] helpStr = loadStrings("help.txt");
  for (int i = 0; i < helpStr.length; )
    text(helpStr[i], width - 240, ++i * FONTSIZE);
}

void snapHandler()
{
  // snap objects
  if (mousePressed) {
    if (mouseDown) lp = snapObject();
    else if (lp != null) lp.set(mouseX, mouseY);
  }

  // (de)spawn force field on click if not snapped
  if (mouseDown && lp == null)
  {
    fp = spawnForceField(mouseButton == LEFT ? 200 : -200, true);
    forceFields.add(fp);
  }
  
  if (mouseUp && fp != null) {
    forceFields.remove(fp);
    fp = null;
  }
}

void draw() {
  keyHandler();
  //if (intense) pause = true;
  if (pause && frameCount != 1) { frameRate = 10; return; }
  frameRate = 60;

  background(T_BG);
  noFill();
  
  snapHandler();

  // physics
  int time = millis();
  spatialHashMap = new HashMap<>();
  for (Particle p : particles) {
    p.last = p.copyRef(p.last);
    spatialHashMap.putIfAbsent(spatialHash(p), new ArrayList());
    spatialHashMap.get(spatialHash(p)).add(p);
  }
  for (int q = 0; q < (SIMULATE ? PHYSICS_STEPS : 1); q++)
    handlePhysics();
  tPhys += millis() - time;
  
  // draw
  time = millis();
  for (Particle particle : particles) particle.display();
  for (Line line : lines) line.display();
  stroke(T_BLUE);
  for (Particle field : forceFields) field.display(false);
  tDraw += millis() - time;
  
  // fps
  if (++tFPS == FPS_FRAMES) {
    if (tPhys != 0) physFPS = FPS_FRAMES*1000 / tPhys;
    if (tDraw != 0) drawFPS = FPS_FRAMES*1000 / tDraw;
    tFPS = tPhys = tDraw = 0; // ?
  }
  fill(T_STROKE);
  text("particles: " + particles.size(), 0, 1*FONTSIZE);
  text("phys FPS: " + physFPS, 0, 2*FONTSIZE);
  text("draw FPS: " + drawFPS, 0, 3*FONTSIZE);
  text("Ph steps: " + PHYSICS_STEPS, 0, 4*FONTSIZE);
  if (HELP) printHelp();
  
  /* if (intense) {
    println("=== intense ===");
    for(Particle p : particles) println(p);
  } */
  
  if (!SAVE) return;
  if (frameCount % 5 == 0) save++;
  if (intense) save += 5;
  if (save > 0) { saveFrame("physics-#####.png"); save--; }
}

void mouseWheel(MouseEvent ev) {
  println(ev.getCount());
  if (fp != null) fp.radius -= 10*ev.getCount();
}

PVector snapObject()
{
  PVector lp = null, mouse = vec(mouseX, mouseY);
  float dist, minLpDist = 1e9;
  for (Line line : lines) {
    dist = PVector.dist(line.start, mouse);
    if (dist < SNAP_DIST && dist < minLpDist) { lp = line.start; minLpDist = dist; }
    dist = PVector.dist(line.end, mouse);
    if (dist < SNAP_DIST && dist < minLpDist) { lp = line.end; minLpDist = dist; }
  }

  for (Particle p : forceFields) {
    dist = PVector.dist(p.position, mouse);
    if (dist < SNAP_DIST && dist < minLpDist) { lp = p.position; minLpDist = dist; }
  }
  return lp;
}

void applyForce(Particle p, Particle field)
{
  PVector d = PVector.sub(field.position, p.position);
  p.accel(new PVector(field.velocity.x * d.x, field.velocity.y * d.y));
  p.accel(field.accelerate);
}

HashMap<Integer, ArrayList<Particle>> spatialHashMap;
void spatialCollision(Particle p, int dx, int dy)
{
  ArrayList<Particle> others = spatialHashMap.get(spatialHash(p) + GRID*dy + dx);
  if (others == null) return;
  // Check collision with other particles
  for (Particle other : others) {
    if (p != other && intersects(p.cur, other.cur)) {
      p.coll = 1;
      intense = reflect(p, other) || intense;
      p.velocity.mult(COLL_LOSS);
    }
  }
}

void handlePhysics()
{
  for (Particle field : forceFields) field.update();
  for (Particle particle : particles) {
    for (Particle field : forceFields)
      if (intersects(particle, field))
        applyForce(particle, field);

    particle.update(intense && false);
  }

  for (Particle particle : particles) {
    // Check collision with lines
    for (Line line : lines) {
      //collisionTime(particle.cur, line);
      if (intersects(particle.cur, line)) {
        particle.coll = 1;
        reflect(particle, line);
        particle.velocity.mult(COLL_LOSS);
      }
    }
  }

  // Update and display particles
  for (Particle particle : particles) {
    for(int y = -1; y <= 1; y++)
      for(int x = -1; x <= 1; x++)
        spatialCollision(particle, x, y);
  }

  for (Particle particle : particles) {
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

Particle spawnForceField(int force, boolean center)
{
  Particle f = new MouseParticle(force);
  if (center) f.velocity.set(force, force);
  else f.accelerate.set(force, force);
  return f;
}

Particle spawnParticle() {
  float radius = random(R_RADIUS.x, R_RADIUS.y);
  PVector speed = vec(random(-R_SPEED.x, R_SPEED.x), random(-R_SPEED.y, R_SPEED.y));
  Particle particle = new Particle(radius, null, speed);

  loop1: while(true) {
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
