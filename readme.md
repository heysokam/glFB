# gl*FB | Tiny Framebuffer with OpenGL
This library provides a simple way to draw a pixel buffer into the screen.  
A framebuffer is a memory buffer containing data representing all the pixels in a complete video frame.  
The user of the library is fully responsible for how the contents of the pixel buffer are generated.  

## HowTo
Add this repository to your nimble file with `requires "https://github.com/heysokam/glFB#head"`  
Then, in your code file:  
```nim
import glFB
# ... your code here ... 
```
### API Examples
#### Simple API
```nim
var scr = Screen.new(960,540)           # Initialize the Screen object
while not scr.close():                  # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = myPixel  # Generate the pixels on the CPU
  scr.update()                          # Update the screen contents in the GPU
scr.term()                              # Terminate everything after
```

Pixel access ergonomics:
```nim
# Individual pixels
let pix    = scr[10,10]          # Returns a copy of the pixel at coordinates [X,Y]
for pixel in scr.pixels:         # Access all pixels individually one by one
  pixel = rgbx(0,0,0,0)          # Each item is modifiable, like mitems
scr[10,10] = rgbx(0,0,0,0)       # Directly modify a single pixel at [X,Y]

# All pixels at once
let data   = scr.data            # Alias for accessing the entire Screen's pixel data
scr.data   = SomeSeqOfColorRGBX  # Alias for pixel buffer data asignation all at once (size must match)

# Note: Coordinate (0,0) is at topleft of the screen
```

#### Advanced Usage
Screen construction:  
```nim
# Constructor function options:  
# 1. Creates pixel buffer with all values set to (0,0,0,0)
  var scr = Screen.new( Width, Height )
# 2. Creates a pixel buffer with the contents and size of the input pixie.Image
  var scr = Screen.new( SomePixieImageObject )
# 3. Creates the required pixie image internally, using the given separate pixel buffer inputs
  var scr = Screen.new( Width, Height, SomeSeqOfColorRGBX )

# Implicit Defaults during Screen Creation with `Screen.new( ... )`:  
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

Post-Processing shader example (Simple API):  
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

Fully verbose example:  
```nim
import glFB

#_______________________________________
# Our dummy CPU renderer
from chroma import rgbx
proc renderPixels(scr :var Screen) :void=
  for pix in scr.pixels: pix = rgbx(255,255,255,255)
#_______________________________________


#_______________________________________
# Our verbose glFB Framebuffer application
#_____________________________
# Input functions for GLFW
from nglfw as glfw import nil
proc myResizeFunction        (window :glfw.Window; width, height :cint) {.cdecl.} = discard
proc myKeyboardFunction      (window :glfw.Window; key, scancode, action, modifiers :cint) {.cdecl.} = discard
proc myMousePositionFunction (window :glfw.Window; x, y :cdouble) {.cdecl.} = discard
proc myMouseButtonFunction   (window :glfw.Window; button, action, modifiers :cint) {.cdecl.} = discard
proc myMouseScrollFunction   (window :glfw.Window; xoffset, yoffset :cdouble) {.cdecl.} = discard

# Create the Screen object
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

# Generate a custom Post-Processing shader
var shd = scr.addPost( SomeShaderCodeString )  # Store the handle. Will be removed later in the example, using a condition

# Do something explicit with glfw on the window
# Could be anything supported by glfw, you have full access to the window context
glfw.setWindowShouldClose(scr.win.ct, true)

# Update loop
while not scr.close():                # Run while the Screen has not been marked for closing
  scr.renderPixels()                  # Generate the pixels on the CPU, with the verbose example custom function
  if myCondition: scr.rmvPost( shd )  # Remove the post-process effect. Drawing will no longer trigger it
  scr.update()                        # Update the screen contents in the GPU

# Terminate after we are done
scr.term()                            # Terminate everything after
```

## Notes:
### No acceleration
The GPU is exclusively used for accessing the data, and transfering it into the screen.  
The only GPU-based processing this library does is applying the list of (optional) Post-Processing effects.  
This library applies no GPU acceleration anywhere else, which makes it suitable for purely CPU-driven renderers.  
### Coordinates
Coordinate (0,0) is topleft of the screen.  
OpenGL wants 0,0 to be bottomleft, but glFB changes this in the FST vertex shader, so that the buffer is drawn correctly.  

