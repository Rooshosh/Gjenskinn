import java.util.Map;

final color BACKGROUNDCOLOR = color(0);
static final int MAX_PARTICLES = 2000;

final color customCursorColor = color(0, 255, 0, 100);
final color particleTargetColor = color(255, 0, 0, 100);

enum ParticleBehaviour {
    Target,
    Flowfield,
    None
}

class ParticleController {
    Overlay userInterface;
    
    Particle[] particles;

    Shader shader;

    HashMap<String, Value> controllerValues;

    boolean baseAutoTarget;

    boolean particleDisable = false; // what's this used for????

    PVector autoTargetV;

    boolean showInterface = false;
    boolean showCustomCursor = false;
    boolean visualizeDebugFunction = false;
    boolean spawnFromMouse = false;
    
    final int overlaySectionWidth = width*2/5;
    final int overlayHeight = height;

    ParticleBehaviour behaviour;
    ParticleBehaviour baseBehaviour;

    Flowfield flowField;

    color[] imageColors;

    String[] filenames;
    int imageIndex = 0;
    
    boolean mouseDoesPush = false;

    ParticleController() {
        controllerValues = new HashMap<String, Value>();
        //All the values of the particle controller that can be changed by the user thorugh the GUI
        controllerValues.put("particleAmount", new Value(1500, 1, MAX_PARTICLES));
        controllerValues.put("acceleration", new Value(1.0, 0.1, 10));
        controllerValues.put("speed", new Value(6.0, 1, 30));
        controllerValues.put("spread", new Value(1.0, 0, 25));
        controllerValues.put("autoTarget", new Value(true));
        
        baseAutoTarget = controllerValues.get("autoTarget").state;
        autoTargetV = new PVector(width/2, height/2);

        //Creates the GUI overlay
        userInterface = new Overlay(controllerValues, 0, 0, overlaySectionWidth, overlayHeight);

        //Creates the particle shader
        shader = new Shader();
        shader.drawBackground();
        
        //Populates the particles array
        regulateParticleAmount(controllerValues.get("particleAmount").amountI, new PVector(width/2, height/2), height/10);

        //Image stuff
        // we'll have a look in the data folder
        java.io.File folder = new java.io.File(dataPath(""));
        
        // list the files in the data folder
        filenames = folder.list();

        //Set the initial particle behaviour
        setBehaviour(ParticleBehaviour.Flowfield);
        baseBehaviour = behaviour;
        
        // Create the background FlowField
        flowField = new Flowfield();
    }

    void setBehaviour() {
        setBehaviour(behaviour);
    }

    void setBehaviour(ParticleBehaviour behaviour) {
        //Skip if the particle controller already uses this behaviour
        //if (this.behaviour == behaviour) return;

        this.behaviour = behaviour;
    }
    
    void regulateParticleAmount(int increase, boolean spawnAtMouse) {
      // Terrible named logic - in a hurry!
      boolean temp = spawnFromMouse;
      
      spawnFromMouse = spawnAtMouse;
      regulateParticleAmount(increase);
      spawnFromMouse = temp;
    }
    
    void regulateParticleAmount(int increase) {
      regulateParticleAmount(increase, null, 0);
    }

    void regulateParticleAmount(int increase, PVector spawnLocation, float spawnSpread) {
      
      // If initializing the program with 0 particles;
        if (particles == null && increase == 0) {
          particles = new Particle[0];
          shader.setParticles(particles);
          return;
        }
        
        //Find the current amount of particles
        int particleAmount;
        if (particles == null) particleAmount = 0;
        else particleAmount = particles.length;

        if (particleAmount + increase <= 0) increase = -particleAmount; // Sets the lower bound of 0?
        if (particleAmount + increase > MAX_PARTICLES) increase = MAX_PARTICLES - particleAmount; // Sets the upper bound
        if (increase == 0) return; // No change
        
        //Creates the new particle array with the proper size
        Particle[] newParticles;
        newParticles = new Particle[particleAmount + increase];

        //Removal
        if (increase < 0) for (int i = 0; i < newParticles.length; ++i) newParticles[i] = particles[i];
        
        //Addition
        else {
            //Copies the excisting array to the new one
            for (int i = 0; i < particleAmount; ++i) newParticles[i] = particles[i];

            //Get some variables from the controller values hashmap
            float acceleration = controllerValues.get("acceleration").amountF;
            float speed = controllerValues.get("speed").amountF;
            float spread = controllerValues.get("spread").amountF;

            for (int i = 0; i < increase; ++i) {
                //Either center position or random position
                PVector pPos;
                if (spawnLocation != null) pPos = spawnLocation.copy();
                else if (spawnFromMouse) pPos = new PVector(mouseX, mouseY);
                else pPos = new PVector(random(width), random(height)); //<>// //<>// //<>//
                
                if (spread > 0) {
                  pPos.add(PVector.random2D().mult(random(0, spawnSpread)));
                }
                
                if (showInterface) pPos = limitToOverlayGap(pPos);

                //Create the new particle at this index in the array
                newParticles[particleAmount + i] = new Particle(pPos, acceleration, speed);

                //Add a little variation
                newParticles[particleAmount + i].setSpread(spread);
            }
        }

        particles = newParticles;
        shader.setParticles(particles);
        
        // Finish by double-checking making sure that the overlay represents the same value
        controllerValues.get("particleAmount").setInt(particles.length);
    }

    void update() {
        //Apply user changes from the GUI
        checkValues();
        
        // Update the Flowfield (for animation) and/or changing over time
        if (behaviour == ParticleBehaviour.Flowfield)
          flowField.update();

        //Calculate and apply movement for the particles
        if (!particleDisable) updateParticles();
    }

    void handlePress(float x, float y) {
        if (showInterface) userInterface.handlePress(x, y);
        if (shader.showInterface) shader.userInterface.handlePress(x, y);
    }

    void resetParticles() {
        //Create a list of particles. Populate it with random positions
        int particleAmount = particles.length;
        regulateParticleAmount(-particleAmount);
        regulateParticleAmount(particleAmount);

        //Reset other properties
        setBehaviour(behaviour);
    }

    void spreadParticles() {
      // Prev implementation
      //Create a list of particles. Populate it with random positions
      // int particleAmount = particles.length;
      // regulateParticleAmount(-particleAmount);
      // regulateParticleAmount(particleAmount, new PVector(width/2, height/2), height/10);
      
        // Reset other properties
      // setBehaviour(behaviour);
      
      // New implementation
        // Keeps their velocity
      moveParticles(new PVector(width/2, height/2), height/10);

    }
    
    void moveParticles(PVector pos, float spread) {
      for (Particle p : particles) {
        PVector pPos = pos.copy();
        if (spread > 0) 
          pPos.add(PVector.random2D().mult(random(0, spread)));
        p.pos = pPos;
      }
    }

    void toggleOverlay() {
        showInterface = !showInterface;
        shader.showInterface = !shader.showInterface;
        
        // temp changing the behaviour so we can see the particles in the centre gap
        if (showInterface) { // On displaying
          baseBehaviour = behaviour;
          setBehaviour(ParticleBehaviour.Target);
        } else { // On hiding
          setBehaviour(baseBehaviour);
        }
    }
    
    void toggleCustomCursor() {
        showCustomCursor = !showCustomCursor;
        
        /*
        // Used earlier, but decided against. Can remove
        if (controllerValues.get("autoTarget").state == showCustomCursor)
          controllerValues.get("autoTarget").toggle();
          baseAutoTarget = !baseAutoTarget;
        */
        
        // Set autotarget vector to start out from where mouse left off
        // Don't want to use this anymore. Can remove
        // autoTargetV = new PVector(mouseX, mouseY);
    }

    //Check for changes in the controller values and apply them
    //Runs every frame
    void checkValues() {
        for (Map.Entry<String, Value> entry : controllerValues.entrySet()) {
            String valueName = entry.getKey();
            Value value = entry.getValue();

            if (!value.isChanged) continue; // Filters out the values that havent been changed
            value.isChanged = false;
            
            //Regulate the amount of particles
            if (valueName == "particleAmount") {
              regulateParticleAmount(value.amountI - particles.length);
            }

            //Update the maximum acceleration of the particles
            if (valueName == "acceleration") for (Particle particle : particles) particle.maxForce = value.amountF;

            //Update the maximum speed of the particles
            if (valueName == "speed") for (Particle particle : particles) particle.maxSpeed = value.amountF;

            //Update the particle spread
            if (valueName == "spread") for (Particle particle : particles) particle.setSpread(value.amountF);
        }

        //Use automatic targeting if the mouse is hovering the ovelay
        if (showInterface && hoveringOverlay() && !controllerValues.get("autoTarget").state)
          controllerValues.get("autoTarget").toggle();
        if (showInterface && !hoveringOverlay() && controllerValues.get("autoTarget").state != baseAutoTarget)
          controllerValues.get("autoTarget").toggle();
    }
    
    void updateAutoTarget() {
      autoTargetV.add(PVector.random2D().mult(30));
      
      // Keep particles in centre-ish if showing the GUI
      // Just need to limit the x-axis
      if (showInterface) {
        autoTargetV = limitToOverlayGap(autoTargetV);
      }
      
      // Crossover when exiting screen
      if (autoTargetV.x < 0) autoTargetV.x = width;
      if (autoTargetV.x > width) autoTargetV.x = width;
      if (autoTargetV.y < 0) autoTargetV.y = height;
      if (autoTargetV.y > height) autoTargetV.y = 0;
    }

    //Updating the particles every frame - Calculating and applying movement
    void updateParticles() {
        //Skip if the particles have been diabled - Usually for debugging
        if (particleDisable) return; // TODO: What's this used for?

        // Normal mouse or target tracking
        if (behaviour == ParticleBehaviour.Target) {
            //Make the particles move towards the mouse. 1 Step
            PVector particleTarget;
            if (controllerValues.get("autoTarget").state) {
              updateAutoTarget();
              particleTarget = autoTargetV;
            } else {
              particleTarget = new PVector(mouseX, mouseY);
            }
            
            for (Particle particle : particles) {
                particle.followTarget(particleTarget);
            }
        }
        
        // Flowfield interaction
        else if (behaviour == ParticleBehaviour.Flowfield) {
            //Update all the particles with a force depending on where they are on the force field
            for (Particle particle : particles) {
                particle.edgeWrap();
                particle.applyForce(flowField.readForce(particle.pos));
                particle.updatePos();
            }
        }
        
        // None behaviour
        else if (behaviour == ParticleBehaviour.None) {
            // Update all the particles with a force depending on where they are on the force field
            for (Particle particle : particles) {
                particle.updatePos();
                particle.breakGradually();
            }
        }
        
        // Push out particles
        if (mouseDoesPush && (!showInterface || !hoveringOverlay())) {
          PVector mouse = new PVector(mouseX, mouseY);
          for (Particle particle : particles) {
                particle.avoid(mouse);
            }
        }

        shader.update();
    }

    void display() {
        //Display all the particles
        shader.display();
        
        //Display the flowfield
        if (visualizeDebugFunction && behaviour == ParticleBehaviour.Flowfield)
          flowField.display();
        
        // Draw the custom cursor
        /*
        Previous version
        if (showCustomCursor && behaviour == ParticleBehaviour.Target && !controllerValues.get("autoTarget").state)
        */
        if (showCustomCursor && !hoveringOverlay())
          displayCustomCursor();
          
        // Draw the auto-target
        if (visualizeDebugFunction && controllerValues.get("autoTarget").state && behaviour == ParticleBehaviour.Target)
          displayAutoTarget();
        
        //Add the overlay on top
        if (showInterface) userInterface.display();
        if (shader.showInterface) shader.userInterface.display();
        
        if (hoveringOverlay()) cursor();
        else if (showInterface && !showCustomCursor) cursor();
        else noCursor();
    }
    
    float targetVisualizerSize = 10;
    
    void displayCustomCursor() {
      fill(customCursorColor);
      if (!controllerValues.get("autoTarget").state && behaviour == ParticleBehaviour.Target) fill(particleTargetColor); // If mouse cursor is currently the target of the particles
      noStroke();
      
      
      if (mouseX == 0 && mouseY == 0) ellipse(width/2, height/2, targetVisualizerSize, targetVisualizerSize); // When initializing the program, before Processing detects the mouse coordinates
      else ellipse(mouseX, mouseY, targetVisualizerSize, targetVisualizerSize);
    }
    
    void displayAutoTarget() {
      if (autoTargetV == null) return;
      
      fill(particleTargetColor);
      noStroke();
      ellipse(autoTargetV.x, autoTargetV.y, targetVisualizerSize, targetVisualizerSize);
    }
    
    boolean hoveringOverlay() {
      return showInterface && (userInterface.checkHover() || shader.userInterface.checkHover());
    }
    
    // Modifeis the vector in place. Returns a reference to the same vector.
    PVector limitToOverlayGap(PVector org) {
      float margin = 0.1; // Percent of gap to be left outside of calculation on either side
      float centreX = width/2;
      float overlayGapWidth = width - overlaySectionWidth*2;
      float _half = overlayGapWidth/2;
      float _m = margin*overlayGapWidth;
      float leftLim = centreX - _half + _m;
      float rightLim = centreX + _half - _m;
      
      float _x = org.x;
      _x = max(leftLim, _x); // Left constraint
      _x = min(_x, rightLim); // Right constraint
      
      org.x = _x;
      
      return org;
    }
}
