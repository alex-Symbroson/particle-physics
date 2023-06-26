final int NUM_PARTICLES = 5;
final int NUM_LINES = 0;
final boolean SAVE = false;
final boolean DBG_PARTICLES = false;
final boolean SIMULATE = true;
final float FPS = 60;
final float DT = 1/FPS;

ArrayList<Particle> particles;
ArrayList<Line> lines;
float deltaTime;

void debugParticles() {
  Particle ps[] = {
  new Particle(61.215, new PVector(674.525, 90.261), new PVector(1.184, -0.805)),
  new Particle(86.673, new PVector(532.559, 86.673), new PVector(1.325, 2.882)),
  new Particle(79.488, new PVector(320.926, 405.500), new PVector(3.455, -5.153)),
  new Particle(92.203, new PVector(330.903, 204.208), new PVector(3.058, 7.769)),
  new Particle(93.715, new PVector(613.494, 409.320), new PVector(0.988, -4.904)),
  };
  for(Particle p : ps) particles.add(p);
}

void setup() {
  clearFiles();
  size(800, 600);

  particles = new ArrayList<Particle>();
  lines = new ArrayList<Line>();

  // if (SIMULATE) particles.add(new MouseParticle(100));
  if (DBG_PARTICLES) debugParticles();
  else for (int i = 0; i < NUM_PARTICLES; i++) spawnParticle();
  for (int i = 0; i < NUM_LINES; i++) createRandomLine();
}

boolean intense = true;
int save = 0;
void draw() {
  frameRate(10);
  if (keyPressed && key == 'd') clearFiles();
  if (keyPressed && key == ' ') intense = false;
  if ((intense || keyPressed) && frameCount != 1) return;
  frameRate(60);

  background(255);
  noFill();

  for (Particle particle : particles) particle.update(intense);

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
        //particle.velocity.mult(0.95);
      }
    }
    
    // Check collision with lines
    for (Line line : lines)
      if (intersects(particle.cur, line)) {
        reflect(particle, line);
      }
    
    // Check collision with screen edges
    if (particle.position.x < particle.radius) {
      particle.velocity.x = abs(particle.velocity.x);
      particle.position.x = particle.radius;
    }
    if (particle.position.x > width - particle.radius) {
      particle.velocity.x = -abs(particle.velocity.x);
      particle.position.x = width - particle.radius;
    }
    if (particle.position.y < particle.radius) {
      particle.velocity.y = abs(particle.velocity.y);
      particle.position.y = particle.radius;
    }
    if (particle.position.y > height - particle.radius) {
      particle.velocity.y = -abs(particle.velocity.y);
      particle.position.y = height - particle.radius;
    }
    //if (particle.velocity.x < 0 && particle.position.x < particle.radius) particle.position.x = width+particle.radius;
    //if (particle.velocity.x > 0 && particle.position.x > width - particle.radius) particle.position.x = -particle.radius;
    //if (particle.velocity.y < 0 && particle.position.y < particle.radius) particle.position.y = height+particle.radius;
    //if (particle.velocity.y > 0 && particle.position.y > height - particle.radius) particle.position.y = -particle.radius;
  }
  
  for (Particle particle : particles) particle.display();
  for (Line line : lines) line.display();
  
  if (intense) {
    println("=== intense ===");
    for(Particle p : particles) println(p);
  }
  
  if (!SAVE) return;
  if (frameCount % 5 == 0) save++;
  if (intense) save += 5;
  if (save > 0) { saveFrame("physics-#####.png"); save--; }
}

void spawnParticle() {
  float radius = random(50, 100);
  PVector speed = new PVector(random(-400, 400), random(-200, 200));
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
  
  particles.add(particle);
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
