class Particle {
    PVector pos;
    PVector prevPos;
    PVector vel;

    float maxForce;
    float maxSpeed;

    PVector target;

    float slowDownRange = 100;

    Particle(PVector pos, float maxForce, float maxSpeed) {
        this.pos = pos;
        this.prevPos = pos;
        this.vel = new PVector();

        this.maxForce = maxForce;
        this.maxSpeed = maxSpeed;
    }

    //Create small variations in the maximum speeds
    void setSpread(float spread) {
        maxSpeed *= random(1, 1 + spread);
    }

    void applyForce(PVector force) {
        vel.add(force);
    }

    void avoid(PVector source) {
      final float reach = 300;
      
      PVector diff = pos.copy().sub(source);
      float dist = diff.mag();
      if (dist > reach) return;
      
      // Distance is between 0 and reach
      float closeness = 1 - (dist / reach);
      // closeness is linear, between 1 and 0; - 1 means very close to cursor. 0 means at effect range edge.
      float effect = pow(closeness,2);
      // effect is still between 1 and 0, but the distribution has shifted from linear to exponential.
      
      // Diff already points in the direction from the mouse to the partilcle, so we want to push it more in this direction
      applyForce(diff.normalize().mult(effect*10));

      //Move the particle based on its velocity for this frame
      prevPos = pos.copy();
      pos.add(vel);
    }

    void setTarget(PVector target) {
        this.target = target.copy();
    }

    void followTarget(PVector target) {
        //Limit the turning force base on the variable
        PVector acc = target.copy().sub(pos);
        acc.limit(maxForce);

        applyForce(acc);

        updatePos();
    }

    void updatePos() {
        //Limit the velocity to avoid infinite speedup
        vel.limit(maxSpeed);

        //Move the particle based on its velocity for this frame
        prevPos = pos.copy();
        pos.add(vel);
    }

    void arriveTarget() {
        //Add braking when arriving
        PVector desired = target.copy().sub(pos);
        float d = desired.mag();

        if (d < slowDownRange) {
            float m = map(d, 0, slowDownRange, 0, maxSpeed);
            desired.setMag(m);
        }

        applyForce(desired.sub(vel));
    }
    
    void breakGradually() {
        //Add braking when arriving
        // float speed = vel.mag();
        float breakForce = 0.05;

        applyForce(vel.copy().mult(-1*breakForce));
    }

    void edgeWrap() {
        if (pos.x < 0) pos.x = width;
        if (pos.x > width) pos.x = 0;
        if (pos.y < 0) pos.y = height;
        if (pos.y > height) pos.y = 0;
    }

    float distToTarget() {
        return(pos.copy().sub(target).mag()); //<>//
    }
}
