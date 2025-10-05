// Note: Bad about this implementation:
// - Creates color objects for MAX_PARTICLES particles, and updates all of these, even if less particles are in use.

class ColorFade {

    //All fade variables
    int fadeSpeed;
    int frameCount = 0;
    int colorSpread = 50;

    color[] colors;

    ColorFade(int fadeSpeed) {
        this.fadeSpeed = fadeSpeed;
        colors = createColors(MAX_PARTICLES, colorSpread);
    }
    
    color[] createColors(int amount, int variation) {
      color[] c = new color[amount];
        for (int i = 0; i < c.length; ++i) {
            int colorSkip = (int) random(variation);

            int r = 255 - colorSkip;
            int g = colorSkip;
            int b = 0;

            c[i] = color(r, g, b);
        }
      return c;
    }
    
    void setParticleAmount(int amount) {
        // Not used anymore
    }

    void fade() {
        if(fadeSpeed > 0) {
            if (frameCount >= fadeSpeed) {
                frameCount = 0;
  
                for (int i = 0; i < colors.length; ++i) {
                    color c = colors[i];
                    int r = (int) red(c);
                    int g = (int) green(c);
                    int b = (int) blue(c);
  
                    if (b == 0 && g < 255) {
                        r--;
                        g++;
                    } else if (r == 0 && b < 255) {
                        g--;
                        b++;
                    } else if (g == 0 && r < 255) {
                        b--;
                        r++;
                    }
  
                    colors[i] = color(r, g, b);
                }
            }
            frameCount++;
        }
    }

    color getColor(int colorIndex) {
        return colors[colorIndex];
    }
}
