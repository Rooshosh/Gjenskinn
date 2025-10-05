class Shader { //<>// //<>//
  PGraphics canvas;
  Particle[] particles;

  Overlay userInterface;
  boolean showInterface = false;

  boolean drawTails;
  boolean useColor;
  boolean hideBehind;
  int refreshRate;
  int size;
  int alpha;

  int frames = 0;

  HashMap<String, Value> shaderValues;

  boolean shouldFade = false;
  
  // Camera settings
  boolean shouldUseWebCam = false; // This one is initiated to true elsewhere
  boolean camShouldFillScreen = true; // False indicates fit instead of fill
  boolean shouldMirrorCamera = true;
  PImage lastCamImage;

  ColorFade colorFade;

  Capture cam;

  Shader() {
    shaderValues = new HashMap<String, Value>();
    //All the values of the shader that can be changed by the user thorugh the GUI
    shaderValues.put("drawTails", new Value(true));
    shaderValues.put("useColor", new Value(true));
    shaderValues.put("hideBehind", new Value(false));
    shaderValues.put("refreshRate", new Value(10000, 1, 60));
    shaderValues.put("size", new Value(5, 1, height/2));
    shaderValues.put("colorChange", new Value(1, 1, 5));
    shaderValues.put("alpha", new Value(45, 1, 255));

    drawTails = shaderValues.get("drawTails").state;
    useColor = shaderValues.get("useColor").state;
    hideBehind = shaderValues.get("hideBehind").state;
    refreshRate = shaderValues.get("refreshRate").amountI;
    size = shaderValues.get("size").amountI;
    alpha = shaderValues.get("alpha").amountI;

    //Creates the canvas to which the particles will be drawn - Different from the main canvas
    canvas = createGraphics(width, height);

    //Creates the GUI overlay
    userInterface = new Overlay(shaderValues, width*3/5, 0, width*2/5, height);

    // Creates the object responsible for the particle coloring
    int colorChange = shaderValues.get("colorChange").amountI;
    colorFade = new ColorFade(colorChange);
  }

  void setParticles(Particle[] particles) {
    this.particles = particles;
    colorFade.setParticleAmount(particles.length);
  }

  void checkValues() {
    for (Map.Entry<String, Value> entry : shaderValues.entrySet()) {
      String valueName = entry.getKey();
      Value value = entry.getValue();

      if (!value.isChanged) continue; // Filters out the values that havent been changed
      value.isChanged = false;

      //Toggle drawing tails
      if (valueName == "drawTails") drawTails = value.state;

      //Toggle hide behind
      if (valueName == "hideBehind") hideBehind = value.state;

      //Update the color fade speed
      if (valueName == "refreshRate") refreshRate = value.amountI;

      //Update the size
      if (valueName == "size") size = value.amountI;

      //Toggle the use of color
      if (valueName == "useColor") useColor = value.state;

      //Update the alpha
      if (valueName == "alpha") alpha = value.amountI;

      //Update the color fade speed
      if (valueName == "colorChange") colorFade.fadeSpeed = value.amountI;
    }
  }

  void update() {
    checkValues();

    //Clear the particle canvas occasionally
    frames += 1;
    if (frames >= 60 * refreshRate) {
      frames = 0;
      drawBackground();
    }

    if (useColor && !shouldUseWebCam) {
      colorFade.fade();
    }
  }

  //Need a way for the color fade class to use this function
  //Pass it into the fade function as an argument?
  float[] particleProgresses() {
    float[] progresses = new float[particles.length];

    for (int i = 0; i < progresses.length; ++i) {
      int fadeRange = 1000;
      float particleDist = particles[i].distToTarget();

      //Caps the distance to the fade range
      particleDist = min(particleDist, fadeRange);

      float progress = map(particleDist, fadeRange, 0, 0, 1);

      progresses[i] = progress;
    }

    return progresses;
  }

  void display() {
    if (!drawTails) drawBackground();

    canvas.beginDraw();

    for (int i = 0; i < particles.length; ++i) {
      Particle particle = particles[i];

      if (hideBehind) {
        //color pc1 = get((int)prevPos.x, (int)prevPos.y);
        color pc2 = canvas.get((int)particle.pos.x, (int)particle.pos.y);

        if (pc2 != BACKGROUNDCOLOR) continue;
      }

      color particleColor;
      if (!shouldUseWebCam) {
        if (!useColor) particleColor = color(255);
        else particleColor = colorFade.getColor(i);
      } else {
        particleColor = getColorFromWebCam(particle.pos);
      }

      canvas.stroke(particleColor, alpha);
      canvas.strokeWeight(size);
      canvas.line(particle.prevPos.x, particle.prevPos.y, particle.pos.x, particle.pos.y);
    }

    // Custom add to make smooth tail fade out to black
    if (shouldFade) {
      canvas.noStroke();
      canvas.fill(BACKGROUNDCOLOR, 10);
      canvas.rect(0, 0, width, height);
    }

    canvas.endDraw();
    image(canvas, 0, 0);
  }

  void drawBackground() {
    canvas.beginDraw();
    canvas.background(BACKGROUNDCOLOR);
    canvas.endDraw();
  }

  void setWebCamUse(Capture cam) {
    if (cam == null) {
      shouldUseWebCam = false;
      this.cam = cam;
    } else {
      shouldUseWebCam = true;
      this.cam = cam;
    }
  }

  color getColorFromWebCam(PVector pos) {
    if (cam.available()) {
      cam.read();
      lastCamImage = cam;
      lastCamImage.loadPixels();
    }
    
    PVector camPos = translateToCamPos(pos);
    return lastCamImage.get((int)camPos.x, (int)camPos.y);
    
    
    // Replaced by new method
    /*
    float scaleRatio = (float) cam.height / (float) height; // Prob between 0 and 1
    PVector posOnCam = pos.copy().mult(scaleRatio);

    float extraXWidth = (width * scaleRatio) - cam.width;

    int camX = (int) (posOnCam.x - extraXWidth/2);
    int camY = (int) posOnCam.y;

    // Mirror camera
    camX = cam.width - camX;

    if (camX < 0) camX = 0;
    if (camX >= cam.width) camX = cam.width-1;

    return lastCamImage.get(camX, camY);
    */
  }
  
  
  
  PVector translateToCamPos(PVector particlePos) {
    PVector canvasCenter = new PVector(width/2, height/2);
    PVector camCenter = new PVector(cam.width/2, cam.height/2);
    
    float canvasAspectRatio = (float)width / (float)height;
    float camAspectRatio = (float)cam.width / (float)cam.height;
    boolean canvasWiderThanCam = canvasAspectRatio >= camAspectRatio;
    
    boolean shouldFitWidth = (canvasWiderThanCam && camShouldFillScreen) || (!canvasWiderThanCam && !camShouldFillScreen);
    
    float camScale;
    if (shouldFitWidth)
      camScale = (float)width / (float)cam.width;
    else // Fit screen instead
      camScale = (float)height / (float)cam.height;
    
    PVector particlePosFromCenter = particlePos.copy().sub(canvasCenter);
    PVector scaled = particlePosFromCenter.div(camScale);
    PVector camPos = camCenter.copy().add(scaled);
    
    // Mirror camera
    if (shouldMirrorCamera)
      camPos.x = cam.width - camPos.x;
    
    return camPos; //<>//
  }
}
