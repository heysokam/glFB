#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# External dependencies
import pkg/pixie
# ndk dependencies
import nstd/address
import nstd/iter
import nmath
from nglfw as glfw import nil
# glFB dependencies
from ./input as i import nil
from ./gl import nil

#_______________________________________
# types.nim
#___________________
type InitError * = object of CatchableError
#___________________
type Window * = ref object
  ct     *:glfw.Window
  size   *:UVec2
  title  *:string
#___________________
type Screen * = ref object
  win  *:Window
  pix  *:pixie.Image


#_______________________________________
# window.nim
#___________________
# Constructor
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
#__________________
# Behavior
proc update  *(w :Window) :void=  discard
proc close   *(w :Window) :bool=  glfw.windowShouldClose(w.ct)
proc term    *(w :Window) :void=  glfw.destroyWindow(w.ct); glfw.terminate()
proc present *(w :Window) :void=  glfw.swapBuffers(w.ct)
#__________________
# Helpers
func ratio *(w :Window) :float32=  w.size.x.float32/w.size.y.float32
  ## Returns the window size ratio as a float32
func getSize *(w :var Window) :UVec2=  glfw.getWindowSize(w.ct, result.x.iaddr, result.y.iaddr); w.size = result
  ## Returns a Vector2 containing the most current window size.
  ## Also updates the stored value at `window.size`

#_______________________________________
# screen.nim
#___________________
proc new *(_:typedesc[Screen];
    pixels       : pixie.Image;
    title        : string                  = "glFB | Window";
    resizable    : bool                    = true;
    resize       : glfw.FrameBufferSizeFun = nil;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = true;
    error        : glfw.ErrorFun           = nil;
  ) :Screen=
  new result
  # Initialize the pixel buffer
  result.pix = pixels
  # Initialize the window
  result.win = Window.new(
    size         = uvec2(result.pix.width.uint32,result.pix.height.uint32),
    title        = title,
    resizable    = resizable,
    resize       = resize,
    key          = key,
    mousePos     = mousePos,
    mouseBtn     = mouseBtn,
    mouseScroll  = mouseScroll,
    mouseCapture = mouseCapture,
    error        = error,
    ) # << Window.new( ... )
  # Initialize OpenGL
  gl.init()
#___________________
proc new *(_:typedesc[Screen];
    W,H          : SomeInteger;
    pixels       : seq[ColorRGBX];
    title        : string                  = "glFB | Window";
    resizable    : bool                    = true;
    resize       : glfw.FrameBufferSizeFun = nil;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = true;
    error        : glfw.ErrorFun           = nil;
  ) :Screen=
  result = Screen.new(
    pixels       = newImage(W,H),
    title        = title,
    resizable    = resizable,
    resize       = resize,
    key          = key,
    mousePos     = mousePos,
    mouseBtn     = mouseBtn,
    mouseScroll  = mouseScroll,
    mouseCapture = mouseCapture,
    error        = error,
    ) # << Screen.new( ... )
  result.pix.data = pixels
#___________________
proc new *(_:typedesc[Screen];
    W,H          : SomeInteger;
    title        : string                  = "glFB | Window";
    resizable    : bool                    = true;
    resize       : glfw.FrameBufferSizeFun = nil;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = true;
    error        : glfw.ErrorFun           = nil;
  ) :Screen=
  Screen.new(
    pixels       = newImage(W,H),
    title        = title,
    resizable    = resizable,
    resize       = resize,
    key          = key,
    mousePos     = mousePos,
    mouseBtn     = mouseBtn,
    mouseScroll  = mouseScroll,
    mouseCapture = mouseCapture,
    error        = error,
    ) # << Screen.new( ... )



#___________________
proc update *(scr :Screen) :void=
  i.update()
  scr.win.update()
  # Draw red color screen.
  gl.clearColor(1, 0, 0, 1)
  gl.clear(gl.ColorBit)
  # Swap buffers (will display the red color)
  scr.win.present()
#___________________
proc close *(scr :Screen) :bool=  scr.win.close()
proc term  *(scr :Screen) :void=  scr.win.term()
#___________________
# Screen Pixels access
func data *(scr :Screen) :seq[ColorRGBX]=  scr.pix.data
  ## Alias for accessing the Screen's pixel data
func `data=` *(scr :var Screen; data :seq[ColorRGBX]) :void=  scr.pix.data = data
  ## Alias for assigning new pixel data for the Screen
func `[]` *(scr :Screen; x,y :Natural) :ColorRGBX=  scr.pix.data[scr.pix.width * y + x]
  ## Returns the Screen pixel at coordinates (X,Y)
func `[]=` *(scr :var Screen; x,y :Natural; pix :ColorRGBX) =  scr.pix.data[scr.pix.width * y + x] = pix
  ## Assigns the Screen pixel at coordinates (X,Y) to the given ColorRGBX value
iterator pixels *(scr :var Screen) :var ColorRGBX=
  ## Iterate through all pixels of the screen, and yield each pixel as modifiable.
  for pix in iter.twoD(scr.pix.data, scr.pix.width, scr.pix.height): yield pix


#_______________________________________
template test {.dirty.}=
  let x = scr.pix.width-1
  let y = scr.pix.height-1
  # Test 1
  let size = (scr.pix.width * scr.pix.height) - 1
  let one = (scr.pix.width) * y + x
  echo size, " == ", one, "  :  ", size == one
  # Test 2
  let two = (scr.pix.height) * x + y
  echo size, " == ", two, "  :  ", size == two

  scr[x,y] = rgbx(1,1,1,1)
  echo scr[x,y]


#_______________________________________
# Entry Point
#___________________
when isMainModule:
  # Initialize the Screen
  var scr = Screen.new(960,540)
  test()
  # Run while the Screen has not been marked for closing
  while not scr.close():
    scr.update()
  # Terminate everything after
  scr.term()

