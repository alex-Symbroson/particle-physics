
final PVector R_RADIUS = vec(5, 10);
final PVector R_SPEED = vec(400, 200);
final float GRAVITY = 500;
final float COLL_LOSS = 0.97;

final int NUM_PARTICLES = 300;
final int NUM_LINES = 0;

final int PHYSICS_STEPS = 40;
final float FPS = 60;
final float DT = 1/(FPS*PHYSICS_STEPS);

final boolean SAVE = false;
final boolean DEMO_PARTICLES = false;
final boolean DBG_COLL = false;
final boolean DBG_PARTICLES = false;
final boolean SIMULATE = true;

ArrayList<Particle> particles;
ArrayList<Line> lines;
float deltaTime;

PVector vec() { return new PVector(); }
PVector vec(float x, float y) { return new PVector(x, y); }
PVector vec(float x, float y, float z) { return new PVector(x, y, z); }

void debugParticles() {
  Particle ps[] = {
  new Particle(61.215, vec(674.525, 90.261), vec(1.184, -0.805)),
  new Particle(86.673, vec(532.559, 86.673), vec(1.325, 2.882)),
  new Particle(79.488, vec(320.926, 405.500), vec(3.455, -5.153)),
  new Particle(92.203, vec(330.903, 204.208), vec(3.058, 7.769)),
  new Particle(93.715, vec(613.494, 409.320), vec(0.988, -4.904)),
  };
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

boolean intense = true;
int save = 0;
void draw() {
  if (frameCount != 1) frameRate(10);
  if (keyPressed && key == 'd') clearFiles();
  if (keyPressed && key == ' ') intense = false;
  //if ((intense || keyPressed) && frameCount != 1) return;
  frameRate(60);

  background(T_BG);
  noFill();
  
  for (int q = 0; q < PHYSICS_STEPS; q++)
    handlePhysics();
  
  for (Particle particle : particles) particle.display();
  for (Line line : lines) line.display();
  
  /* if (intense) {
    println("=== intense ===");
    for(Particle p : particles) println(p);
  } */
  
  if (!SAVE) return;
  if (frameCount % 5 == 0) save++;
  if (intense) save += 5;
  if (save > 0) { saveFrame("physics-#####.png"); save--; }
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
        reflect(particle, line);
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
