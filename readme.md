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
    title        : string                  = "glFB | Window";  # Title of the window
    resizable    : bool                    = false;            # Whether the window is allowed to be resized or not
    resize       : glfw.FrameBufferSizeFun = w.resize;         # GLFW framebuffer resize callback.  aka: glFB/window  proc resize() ...
    key          : glfw.KeyFun             = i.key;            # GLFW Input Keyboard callback.      aka: glFB/input   proc key() ...
    mousePos     : glfw.CursorPosFun       = nil;              # GLFW Input Mouse Position callback.
    mouseBtn     : glfw.MouseButtonFun     = nil;              # GLFW Input Mouse Button callback.
    mouseScroll  : glfw.ScrollFun          = nil;              # GLFW Input Mouse ScrollWheel callback.
    mouseCapture : bool                    = false;            # Whether to capture the mouse on window launch or not
    error        : glfw.ErrorFun           = nil;
```

Screen construction options:  
```nim
# Creates pixel buffer with all values set to (0,0,0,0)
var scr = Screen.new( Width, Height )

# Creates a pixel buffer with the contents and size of the input pixie.Image
var scr = Screen.new( SomePixieImageObject )

# Creates the required pixie image internally, using the given separate pixel buffer inputs
var scr = Screen.new( Width, Height, SomeSeqOfColorRGBX )
```

Fully verbose example:  
```nim
from chroma import rgbx
proc renderPixels(scr :var Screen) :void=
  for pix in scr.pixels: pix = rgbx(255,255,255,255)

var scr = Screen.new(              # Initialize the Screen object, using the (W,H) variant
  W            = 960,              # (must be explicit) Window and pixelbuffer initial width
  H            = 540,              # (must be explicit) Window and pixelbuffer initial height
  title        = "glFB | Window",
  resizable    = true,             # Change window to resizable (default false)
  resize       = myResizeFunction,
  key          = myKeyboardFunction,
  mousePos     = myMousePositionFunction,
  mouseBtn     = myMouseButtonFunction,
  mouseScroll  = myMouseScrollFunction,
  mouseCapture = true,             # Change default to capture the mouse (default false)
  error        = myErrorCallback,
  ) # << Screen.new( ... )

# Do something explicit with glfw on the window
# Could be anything supported by glfw, you have full access to the window context
from nglfw as glfw import nil
glfw.setWindowShouldClose(scr.win.ct, true)

# Update loop
while not scr.close():             # Run while the Screen has not been marked for closing
  scr.renderPixels()               # Generate the pixels on the CPU, with the verbose example custom function
  scr.update()                     # Update the screen contents in the GPU

# Terminate after we are done
scr.term()                         # Terminate everything after
```

### Notes:
#### No acceleration
The GPU is exclusively used for accessing the data, and transfering it into the screen.  
The only GPU-based processing this library does is applying the list of (optional) Post-Processing effects.  
This library applies no GPU acceleration anywhere else, which makes it suitable for purely CPU-driven renderers.  

