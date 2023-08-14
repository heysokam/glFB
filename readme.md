# gl*FB | Tiny Framebuffer with OpenGL
This library provides a simple way to draw a pixel buffer into the screen.  
A framebuffer is a memory buffer containing data representing all the pixels in a complete video frame.  
The user of the library is fully responsible for how the contents of the pixel buffer are generated.  

### HowTo
Add this repository to your nimble file with `requires "https://github.com/heysokam/glFB#head"`
Then, in your code file:
```nim
import glFB
# ... your code here ... 
```
#### API Examples
Simple API:  
```nim
var scr = Screen.new(960,540)                         # Initialize the Screen object
while not scr.close():                                # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
  scr.update()                                        # Update the screen contents in the GPU
scr.term()                                            # Terminate everything after
```

Post-Processing shader example:  
```nim
var scr = Screen.new(960,540)                         # Initialize the Screen
scr.addPost(DbgFrag)                                  # Add the Debug Post-Processing effect to the list
while not scr.close():                                # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
  scr.update()                                        # Draw the contents (also applies all Post-Processing shaders)
scr.term()                                            # Terminate everything after
```

Post-Processing shader removal:  
```nim
var shd = scr.addPost( SomeShaderCodeString )  # Returns the (implicitly discarded) handle of the shader
scr.rmvPost( shd )                             # Remove the shader from the list with its handle id
```

Implicit Defaults during Screen Creation with `Screen.new( ... )`:  
```nim
    title        : string                  = "glFB | Window";
    resizable    : bool                    = false;
    resize       : glfw.FrameBufferSizeFun = w.resize;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = false;
    error        : glfw.ErrorFun           = nil;
```

Fully verbose example
```nim
from chroma import rgbx
proc renderPixels(scr :var Screen) :seq[ColorRGBX]=
  for pix in scr.pixels: pix = rgbx(255,255,255,255)

var scr = Screen.new(              # Initialize the Screen object, using the (W,H) variant
  W            = 960,              # (must be explicit) Window and pixelbuffer initial width
  H            = 540,              # (must be explicit) Window and pixelbuffer initial height
  title        = "glFB | Window",  # Title of the window
  resizable    = false,            # Whether the window is allowed to be resized or not
  resize       = w.resize,         # GLFW framebuffer resize callback.  aka: glFB/window  proc resize() ...
  key          = i.key,            # GLFW Input Keyboard callback.      aka: glFB/input   proc key() ...
  mousePos     = nil,              # GLFW Input Mouse Position callback.
  mouseBtn     = nil,              # GLFW Input Mouse Button callback.
  mouseScroll  = nil,              # GLFW Input Mouse ScrollWheel callback.
  mouseCapture = false,            # Whether to capture the mouse on window launch or not
  error        = nil,
  ) # << Screen.new( ... )
while not scr.close():             # Run while the Screen has not been marked for closing
  scr.renderPixels()               # Generate the pixels on the CPU, with the verbose example custom function
  scr.update()                     # Update the screen contents in the GPU
scr.term()                         # Terminate everything after
```

### Notes:
#### No acceleration
The GPU is exclusively used for accessing the data, and transfering it into the screen.  
The only GPU-based processing this library does is applying the list of (optional) Post-Processing effects.  
This library applies no GPU acceleration anywhere else, which makes it suitable for purely CPU-driven renderers.  

