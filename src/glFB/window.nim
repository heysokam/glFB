#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# ndk dependencies
import nstd/address
import nmath
from nglfw as glfw import nil
# glFB dependencies
import ./input as i
from   ./gl import nil

#___________________
type Window * = ref object
  ct     *:glfw.Window
  size   *:UVec2
  title  *:string

#_______________________________________
# Callbacks
#___________________
proc resize *(window :Window; W,H :cint) :void {.cdecl.}=
  gl.viewport(0,0, W,H)


#_______________________________________
# Constructor
#___________________
proc new *(_:typedesc[Window];
    size         : UVec2;
    title        : string                  = "glFB | Window";
    resizable    : bool                    = true;
    resize       : glfw.FrameBufferSizeFun = nil;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = false;
    error        : glfw.ErrorFun           = nil;
  ) :Window=
  # Init GLFW
  doAssert glfw.init(), "Failed to Initialize GLFW"
  # Set OpenGL version to load
  glfw.windowHint(glfw.ContextVersionMajor, gl.GLVersionMajor)
  glfw.windowHint(glfw.ContextVersionMinor, gl.GLVersionMinor)
  glfw.windowHint(glfw.OpenglProfile, glfw.OpenglCoreProfile)
  glfw.windowHint(glfw.OpenglForwardCompat, gl.GLForwardCompat.cint)
  # Set window properties
  glfw.windowHint(glfw.Resizable, if resizable: glfw.True else: glfw.False)
  # Create the window
  new result
  result.size  = size
  result.title = title
  result.ct    = glfw.createWindow(result.size.x.cint, result.size.y.cint, result.title.cstring, nil, nil)
  doAssert result.ct != nil, "Failed to create GLFW window"
  # Set Callbacks
  discard glfw.setFramebufferSizeCallback(result.ct, resize)  # Viewport size/resize callback
  discard glfw.setKeyCallback(result.ct, key)
  discard glfw.setCursorPosCallback(result.ct, mousePos)
  discard glfw.setMouseButtonCallback(result.ct, mouseBtn)
  discard glfw.setScrollCallback(result.ct, mouseScroll)
  # Set Input mode
  if mouseCapture: glfw.setInputMode(result.ct, glfw.Cursor, glfw.CursorDisabled)
  # Connect to the OpenGL context.
  glfw.makeContextCurrent(result.ct)


#_______________________________________
# Behavior
#__________________
proc update  *(w :Window) :void=  discard
proc close   *(w :Window) :bool=  glfw.windowShouldClose(w.ct)
proc term    *(w :Window) :void=  glfw.destroyWindow(w.ct); glfw.terminate()
proc present *(w :Window) :void=  glfw.swapBuffers(w.ct)


#_______________________________________
# Helpers
#___________________
func ratio *(w :Window) :float32=  w.size.x.float32/w.size.y.float32
  ## Returns the window size ratio as a float32
func getSize *(w :var Window) :UVec2=  glfw.getWindowSize(w.ct, result.x.iaddr, result.y.iaddr); w.size = result
  ## Returns a Vector2 containing the most current window size.
  ## Also updates the stored value at `window.size`

