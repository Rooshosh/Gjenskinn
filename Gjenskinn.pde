import processing.video.*;

Capture cam;

ParticleController particleController;

final int fastForwardIterations = 10;
boolean fastForward = false;

boolean shiftIsPressed = false;

int pictureWaitSeconds = 5;
int pictureWaitRemainingFrames = -1;

void setup() {
  // size(1072, 603);
  fullScreen(); 
  // size(200, 800);
  noCursor();
  particleController = new ParticleController();
  toggleWebCam();
}

void draw() {
  if (!fastForward) {
    particleController.update();
    particleController.display();

    // Screenshot behaviour
    if (pictureWaitRemainingFrames > 0) {
      pictureWaitRemainingFrames--;
      displayScreenshotCountdown();
    }
    else if (pictureWaitRemainingFrames == 0) {
      // Take screenshot
      saveFrame("/Users/henrikreusch/Desktop/code-screenshot-######.jpg");
      pictureWaitRemainingFrames = -1;
    }
  } else {  // Fast Forward
    for (int i = 0; i < fastForwardIterations; i++) {
      particleController.update();
      particleController.display();
    }
  }
}

void displayScreenshotCountdown() {
  textSize(width/15);
  textAlign(RIGHT, TOP);
  text(floor(pictureWaitRemainingFrames/60)+1, width-width*1/20, width*1/40);
}

void mousePressed() {
    if (mouseButton == LEFT) {
      particleController.handlePress(mouseX, mouseY);
      particleController.mouseDoesPush = true;
    }
    if (mouseButton == RIGHT) { // Right clicking creates a particle at the mouse coordinates
      particleController.regulateParticleAmount(1, true);
    }
}

void mouseReleased() {
  particleController.mouseDoesPush = false;
}

//Control different functions using the keyboard.
void keyPressed() {
  //Press q to close the program.
  if (key == 'Q' || key == 'q') {
    exit();
  }
  
  //Toggle custom cursor
  if (key == 'C') {
    particleController.toggleCustomCursor();
  }
  
  if (key == 'c') {
    particleController.shader.drawBackground();
  }

  // Reset flowfield
  if (key == 'r') {
    // particleController.resetParticles();
    particleController.flowField.reset();
    particleController.autoTargetV = new PVector(width/2, height/2);
    // particleController.shader.drawBackground();
  }
  // Toggle randomized scattered
  if (key == 'R') {
    particleController.flowField.toggleRandomScattered();
  }
  
  //Spread particles the screen so it can draw a new
  if (key == 'S' || key == 's') {
    particleController.spreadParticles();
    particleController.shader.drawBackground();
  }

  //Toggle whether the overlay is visible or not
  if (key == 'O' || key == 'o') {
    particleController.toggleOverlay();
  }


  //Set particle behaviour
  if (key == 'f') {
    particleController.setBehaviour(ParticleBehaviour.Flowfield);
  }
  if (key == 'F') {
    particleController.flowField.shouldChangeOverTime = !particleController.flowField.shouldChangeOverTime;
  }
  if (key == 'T' || key == 't') {
    particleController.setBehaviour(ParticleBehaviour.Target);
  }
  if (key == 'N' || key == 'n') {
    particleController.setBehaviour(ParticleBehaviour.None);
  }
  // Smart iterative toggle
  if (key == 'B' || key == 'b') {
    ParticleBehaviour b = particleController.behaviour;
    ParticleBehaviour newB;
    
    if (b == ParticleBehaviour.None) newB = ParticleBehaviour.Target;
    else if (b == ParticleBehaviour.Target) newB = ParticleBehaviour.Flowfield;
    else newB = ParticleBehaviour.None;
    
    particleController.setBehaviour(newB);
  }
  
  // New ones
  if (key == 'V' || key == 'v') {
    particleController.visualizeDebugFunction = !particleController.visualizeDebugFunction;
  }
  if (key == 'A' || key == 'a') {
    particleController.controllerValues.get("autoTarget").toggle();
    particleController.baseAutoTarget = !particleController.baseAutoTarget;
  }
  // Toggle tails
  if (key == 'z') {
    particleController.shader.shaderValues.get("drawTails").toggle();
  }
  // Toggle fade of tails
  // (Only visible if tails are visible)
  if (key == 'x') {
    particleController.shader.shouldFade = !particleController.shader.shouldFade;
  }
  if (keyCode == UP) {
    if (!shiftIsPressed)
      particleController.shader.shaderValues.get("size").incrementt();
    else
      particleController.shader.shaderValues.get("size").changeQuick(20);
  }
  if (keyCode == DOWN) {
    if (!shiftIsPressed)
      particleController.shader.shaderValues.get("size").decrement();
    else
      particleController.shader.shaderValues.get("size").changeQuick(-20);
  }
  if (keyCode == LEFT) {
    particleController.shader.shaderValues.get("alpha").changeQuick(-10);
  }
  if (keyCode == RIGHT) {
    particleController.shader.shaderValues.get("alpha").changeQuick(10);
  }
  if (key == '-') {
    particleController.regulateParticleAmount(-1);
  }
  if (key == '+') {
    particleController.regulateParticleAmount(1, true);
  }
  // Speed up for creating artworks
  if (key == ' ') {
    if (particleController.shader.shouldUseWebCam) pictureWaitRemainingFrames = 60 * pictureWaitSeconds;
    else fastForward = true;
  }
  // Toggle colors
  if (key == 'm' || key == 'M') {
    particleController.shader.shaderValues.get("useColor").toggle();
  }
  if (keyCode == SHIFT) shiftIsPressed = true;
  
  
  //Toggle WebCam Usage
  if (key == 'd') {
    toggleWebCam();
  }
}

void keyReleased() {
  if (key == ' ') {
    fastForward = false;
  }
  if (keyCode == SHIFT) shiftIsPressed = false;
}

void mouseWheel(MouseEvent event) {
  int increase = -event.getCount();
  int currParticles = particleController.particles.length;
  if (currParticles + increase < 3) return;
  
  particleController.regulateParticleAmount(increase);
  particleController.setBehaviour(); // Remove ?
}

void toggleWebCam() {
  boolean shouldUseWebCam = particleController.shader.shouldUseWebCam;
  
  if (!shouldUseWebCam) { // Turning it on
    String[] cameras = Capture.list();
    
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      
      // The camera can be initialized directly using an 
      // element from the array returned by list():
      cam = new Capture(this, cameras[0]);
      cam.start();
    }
  }
  else { // Turning it off
    cam.stop();
    cam = null;
  }
  particleController.shader.setWebCamUse(cam);
}
