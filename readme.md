# gl*FB | Tiny Framebuffer with OpenGL
This library provides a simple way to draw a pixel buffer into the screen.  
A framebuffer is a memory buffer containing data representing all the pixels in a complete video frame.  
The user of the library is fully responsible for how the contents of the pixel buffer are generated.  

### HowTo
```nim
import glFB as fb

# Simple API
var scr = Screen.new(960,540)    # Initialize the Screen object
while not scr.close():           # Run while the Screen has not been marked for closing
  for pix in scr.pixels:         # Generate the pixels on the CPU
    pix = rgbx(255,255,255,255)
  scr.update()                   # Update the screen contents in the GPU
scr.term()                       # Terminate everything after
```

### Notes:
#### No acceleration
The GPU is exclusively used for accessing the data, and transfering it into the screen.  
This library applies no GPU acceleration at all, which makes it suitable for pure CPU-driven renderers.  

