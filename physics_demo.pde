ArrayList<Particle> particles;
ArrayList<Line> lines;

void setup() {
  size(800, 600);
  particles = new ArrayList<Particle>();
  lines = new ArrayList<Line>();
  
  // Spawn 10 particles
  for (int i = 0; i < 30; i++) {
    spawnParticle();
  }
  
  // Create 5 random non-intersecting lines
  for (int i = 0; i < 5; i++) {
    createRandomLine();
  }
}

void draw() {
  background(255);
  
  for (var particle : particles) {
    particle.update();
  }
  
  // Update and display particles
  for (var particle : particles) {
    
    // Check collision with lines
    for (Line line : lines) {
      if (intersects(particle.cur, line)) {
        reflect(particle, line);
      }
    }
    
    // Check collision with screen edges
    if (particle.position.x < particle.radius || particle.position.x > width - particle.radius) {
      particle.velocity.x *= -1;
    }
    if (particle.position.y > height - particle.radius) {
      particle.position.y = 0;
      particle.velocity.set(0, 0);
    }
  }
  
  for (var particle : particles) particle.display();
  for (var line : lines) line.display();
}

void spawnParticle() {
  float radius = 14;
  float x = random(radius, width - radius);
  float y = random(0, height);
  float speedY = random(1, 5);
  Particle particle = new Particle(radius, new PVector(x, y), new PVector(0, speedY), null);
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
