# gl*FB | Tiny Framebuffer with OpenGL
This library provides a simple way to draw a pixel buffer into the screen.  
A framebuffer is a memory buffer containing data representing all the pixels in a complete video frame.  
The user of the library is fully responsible for how the contents of the pixel buffer are generated.  

### HowTo
```nim
import glFB

# Simple API
var scr = Screen.new(960,540)                         # Initialize the Screen object
while not scr.close():                                # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
  scr.update()                                        # Update the screen contents in the GPU
scr.term()                                            # Terminate everything after
```
```nim
# Post-Processing shader example
var scr = Screen.new(960,540)                         # Initialize the Screen
scr.addPost(DbgFrag)                                  # Add the Debug Post-Processing effect to the list
while not scr.close():                                # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
  scr.update()                                        # Draw the contents (also applies all Post-Processing shaders)
scr.term()                                            # Terminate everything after
```

### Notes:
#### No acceleration
The GPU is exclusively used for accessing the data, and transfering it into the screen.  
The only GPU-based processing this library does is applying the list of (optional) Post-Processing effects.  
This library applies no GPU acceleration anywhere else, which makes it suitable for purely CPU-driven renderers.  

