# Gjenskinn - Interactive Particle System

An interactive particle system created in Processing that generates beautiful, dynamic artworks through real-time manipulation of particle behavior, flow fields, and visual effects.

## What is Processing?

[Processing](https://processing.org/) is a flexible software sketchbook and a language for learning how to code within the context of the visual arts. It's designed for artists, designers, researchers, and hobbyists who want to create interactive graphics, animations, and visual applications. Processing uses a simplified version of Java and provides a friendly development environment for creative coding.

## Features

- **Interactive Particle System**: Up to 2000 particles that can be controlled in real-time
- **Multiple Behavior Modes**: 
  - Flowfield (particles follow dynamic vector fields)
  - Target (particles follow mouse cursor or auto-target)
  - None (free-floating particles)
- **Visual Effects**:
  - Color-coded particles with automatic color cycling
  - Particle trails and fade effects
  - Webcam integration for color sampling
  - Real-time visual parameter adjustment
- **Flow Field Generation**: Procedural noise-based and random scattered vector fields
- **Screenshot Functionality**: Automatic screenshot capture with countdown
- **Real-time Parameter Control**: GUI overlay for adjusting all system parameters

## Screenshots

Here are some examples of the visual artworks you can create:

![Color Flowfield](Image%20Showcase/Website/Color-Flowfield-Normal-1-scaled.jpeg.webp)
*Color particles following a flowfield*

![Big HideBehind Target](Image%20Showcase/Website/Big-HideBehind-Target-White-3-scaled.jpeg.webp)
*Large particles with hide-behind effect targeting cursor*

![Normal FlowField](Image%20Showcase/Website/Normal-FlowField-White-2-scaled.jpeg.webp)
*White particles in flowfield mode*

For more visual examples, visit the [project showcase website](https://roosh.no/particle-system/).

## Keyboard Controls

### Basic Controls
- **Q** - Quit the program
- **Space** - Fast forward mode (hold to speed up particle generation for creating artworks)
- **S** - Spread particles across screen and redraw background
- **R** - Reset flowfield and auto-target position
- **O** - Toggle overlay interface on/off

### Particle Behavior
- **F** - Set particles to Flowfield behavior
- **T** - Set particles to Target behavior (follow mouse)
- **N** - Set particles to None behavior (free floating)
- **B** - Smart iterative toggle: None → Target → Flowfield → None
- **A** - Toggle auto-targeting (particles move to random positions automatically)

### Visual Effects
- **M** - Toggle color mode on/off
- **Z** - Toggle particle trails on/off
- **X** - Toggle trail fade effect on/off
- **C** - Toggle custom cursor display
- **c** - Redraw background
- **V** - Toggle debug visualization (show flowfield vectors and targets)
- **D** - Toggle webcam usage for color sampling

### Flowfield Controls
- **F** (capital) - Toggle flowfield animation over time
- **R** (capital) - Toggle between smooth noise and random scattered flowfields

### Particle Management
- **+** - Add one particle at mouse position
- **-** - Remove one particle
- **Mouse Wheel** - Add/remove particles (scroll up/down)
- **Right Click** - Add particle at mouse position
- **Left Click** - Push particles away from cursor

### Visual Parameter Adjustment
- **Arrow Keys** - Adjust particle size and alpha:
  - **Up Arrow** - Increase particle size
  - **Down Arrow** - Decrease particle size  
  - **Left Arrow** - Decrease alpha (transparency)
  - **Right Arrow** - Increase alpha (transparency)
- **Shift + Up/Down** - Quick size adjustment (±20)

### Screenshot
- **Space** (with webcam enabled) - Start 5-second countdown for automatic screenshot

## Installation & Setup

1. Download and install [Processing](https://processing.org/download/)
2. Clone this repository or download the files
3. Open `Gjenskinn.pde` in Processing
4. Click the "Run" button to start the particle system

## Requirements

- Processing 3.0 or higher
- Optional: Webcam for color sampling functionality

## File Structure

- `Gjenskinn.pde` - Main sketch file
- `ParticleController.pde` - Manages particle system and user interactions
- `Particle.pde` - Individual particle behavior and physics
- `FlowField.pde` - Vector field generation and management
- `Shader.pde` - Visual rendering and effects
- `ColorFade.pde` - Color cycling system
- `Overlay.pde` - GUI interface system
- `Input.pde` - Input device handling (sliders, buttons)
- `Value.pde` - Value management system

## Usage Tips

1. **Start with Flowfield mode (F)** for organic, flowing patterns
2. **Use Target mode (T)** for interactive cursor-following effects
3. **Adjust particle size with arrow keys** to create different visual densities
4. **Enable trails (Z)** for more dramatic visual effects
5. **Use fast forward (Space)** when creating final artworks to generate more particles quickly
6. **Try different color modes (M)** for varied visual styles
7. **Experiment with webcam integration (D)** for unique color sampling

## Creating Artworks

The system is designed for creating digital artworks:

1. Adjust parameters using keyboard shortcuts or the GUI overlay (O)
2. Use fast forward mode (Space) to generate particles quickly
3. Take screenshots using the space key with webcam enabled
4. Experiment with different behaviors and visual effects
5. The system automatically saves screenshots to your desktop

## License

This project is open source and available under the MIT License.

## Credits

Created by Henrik Reusch. Visit the [project showcase](https://roosh.no/particle-system/) to see more examples of the visual possibilities this system offers.
