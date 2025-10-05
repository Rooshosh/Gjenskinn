class Flowfield {
    PVector[] vectors;
    float[] currentScatteredRandomNs;
    int cols, rows;
    float inc = 5;
    float zoff = 0;
    int scl = 30;
    float timeWarp = 0.004;
    
    boolean shouldChangeOverTime = true;
    boolean useSmoothNoise = false;

    Flowfield() {
        cols = floor(width / scl) + 1;
        rows = floor(height / scl) + 1;
        vectors = new PVector[cols * rows];
        
        currentScatteredRandomNs = generateScatteredRandomNumbers();
        
        advance();
    }
    
    void update() {
      // Transition animation logic - Don't advance further during this period
      if (currentlyTransitioning) {
        // Lerp
        float progress = currTransitionFrame / finishedTransitionFrames;
        float[] ns = lerpRandomValues(transitionStartNs, transitionEndNs, progress);
        vectors = generateVectors(ns);
        
        // Advance transition and check if it's finished
        currTransitionFrame++; // Advance
        if (currTransitionFrame >= finishedTransitionFrames) {
          currentlyTransitioning = false;
          currTransitionFrame = 0;
        }
      }
      
      // Change over time, but not if were in a transition animation
      else if (shouldChangeOverTime) {
        advance();
      }
    }
    
    void setStartAndEndNs() {
      if (!useSmoothNoise) {
        transitionStartNs = currentScatteredRandomNs;
        transitionEndNs = generateNoiseValues();
      }
      else {
        transitionStartNs = generateNoiseValues();
        transitionEndNs = currentScatteredRandomNs;
      }
    }

    void advance() {
      float[] ns;
      
      if (!useSmoothNoise) ns = generateScatteredRandomNumbers();
      else ns = generateNoiseValues();
      
      vectors = generateVectors(ns);
    }
    
    float[] generateScatteredRandomNumbers() {
      float[] ns = new float[cols * rows];
      
      for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; col++) {
          int i = col + row * cols;
          float r = random(1);
          ns[i] = r;
        }
      }
      currentScatteredRandomNs = ns;
      
      return ns;
    }
    
    float[] generateNoiseValues() {
      float[] ns = new float[cols * rows];
      
      float yoff = 0;
      for (int row = 0; row < rows; ++row) {
          float xoff = 0;
          for (int col = 0; col < cols; col++) {
              int i = col + row * cols;
              
              // Calculate wrapped noise coordinates
              float wrappedX = xoff / scl; 
              wrappedX %= width;           
              float wrappedY = yoff / scl; 
              wrappedY %= height; 
              
              // Use your existing noise function 
              float n = noise(wrappedX, wrappedY, zoff); 
              // float n = noise(xoff, yoff, zoff);
              ns[i] = n;

              xoff += inc;
          }
          yoff += inc;
      }
      zoff += timeWarp;
      
      return ns;
    }
    
    // Assumes start and end have the same array length
    float[] lerpRandomValues(float[] start, float[] target, float progress) {
      float[] ns = new float[start.length];
      
      for (int i = 0; i < ns.length; i++) {
        float diff = target[i] - start[i];
        
        // n values are between 0 and 1
        // If the difference is more than 0.5, we'd rather rotate in the opposite direction
        // Didn't implement
        ns[i] = start[i] + diff*progress;
      }
      
      return ns;
    }
    
    PVector[] generateVectors(float[] ns) {
      PVector[] v = new PVector[cols * rows];
      
      for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; col++) {
          int i = col + row * cols;
          float n = ns[i];
  
          float angle = n * TWO_PI * 2;
          PVector a = PVector.fromAngle(angle);
          a.setMag(1);
          v[i] = a;
        }
      }
      
      return v;
    }

    void display() {
      for (int row = 0; row < rows; ++row) {
          for (int col = 0; col < cols; col++) {
              PVector v = new PVector(col * scl, row * scl);
              // Temp test to only visualize flowfield close to the mouse
              // Didn't like it
              /*
              float maxMouseDist = width/10;
              if (v.copy().sub(new PVector(mouseX, mouseY)).mag() > maxMouseDist)
                continue;
              */

              PVector a = vectors[col + row * cols].copy();
              a.setMag(scl);

              PVector v1 = v.copy().add(a);

              strokeWeight(1);
              stroke(255, 100);
              line(v.x, v.y, v1.x, v1.y);
            }
        }
    }

    PVector readForce(PVector pos) {
        int x = floor(pos.x / scl);
        int y = floor(pos.y / scl);
        int index = x + y * cols;
        PVector force = vectors[index].copy();
        return force;
    }

    void reset() {
        zoff = 0;
        noiseSeed((int)random(10000));
        currentScatteredRandomNs = generateScatteredRandomNumbers();
        advance();
    }
    
    // Custom override to show pure random field instead of noise flowfield
    // Constants
    final float timeForTransition = 1; // Time in seconds;
    final int finishedTransitionFrames = (int) (60 * timeForTransition);
    
    // These will be used every time we toggle
    boolean currentlyTransitioning = false;
    float currTransitionFrame = 0;
    float[] transitionStartNs;
    float[] transitionEndNs;
    
    // Note:
    // currentlyRandomScattered is the state we are at or currently transitioning to
    void toggleRandomScattered() {
      if (currentlyTransitioning) return; // Block whilst in a transition animation
      
      setStartAndEndNs();
      useSmoothNoise = !useSmoothNoise;
      currentlyTransitioning = true;
      currTransitionFrame = 0;
    }
}
