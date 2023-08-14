#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# std dependencies
import std/os
import std/paths
# External dependencies
import pkg/pixie
# ndk dependencies
import nstd/iter
import nmath
from nglfw as glfw import nil
# glFB dependencies
import ./errors
import ./window{.all.}
from ./input as i import nil
from ./gl import nil


#___________________
type Triangle = object
  shd  :gl.ShaderProg
  vao  :uint32  ## OpenGL VAO handle
  tex  :uint32  ## OpenGL Texture handle
#___________________
type Screen * = ref object
  win   *:Window             ## Window Object
  tri    :Triangle           ## Fullscreen Triangle data
  pix   *:pixie.Image        ## Pixels Data
  post   :seq[gl.ShaderProg] ## Post-Processing shaders

#_______________________________________
const thisDir  = currentSourcePath().parentDir()
const shdDir   = thisDir/"shd"
# Read Triangle data at compile time
const TriVert  = staticRead( shdDir/"tri.vert" )
const TriFrag  = staticRead( shdDir/"tri.frag" )
# Read debug shader at compile time
const DbgFrag  = staticRead( shdDir/"debug.frag" )


#_______________________________________
# Screen Pixels access
#___________________
# Individual pixels
func `[]=` *(scr :var Screen; x,y :Natural; pix :ColorRGBX) =  scr.pix.data[scr.pix.width * y + x] = pix
  ## Assigns the Screen pixel at coordinates (X,Y) to the given ColorRGBX value
func `[]` *(scr :Screen; x,y :Natural) :ColorRGBX=
  ## Returns the Screen pixel at coordinates (X,Y)
  if (scr.pix.width * y + x) > ( (scr.pix.width-1) * (scr.pix.height-1) ): # If (x,y) > (width-1,height-1)
    raise newException(PixelIOError, "Tried to access a pixel that's out of bounds of the framebuffer.")
  result = scr.pix.data[scr.pix.width * y + x]
#___________________
iterator pixels *(scr :var Screen) :var ColorRGBX=
  ## Iterate through all pixels of the screen, and yield each pixel as modifiable.
  for pix in iter.twoD(scr.pix.data, scr.pix.width, scr.pix.height): yield pix
#___________________
# All pixels at once
func data *(scr :Screen) :seq[ColorRGBX]=  scr.pix.data
  ## Alias for accessing the Screen's pixel data
func `data=` *(scr :var Screen; data :seq[ColorRGBX]) :void=
  ## Alias for assigning new pixel data for the Screen
  if data.len != scr.pix.data.len: raise newException(PixelIOError, "Tried to assign pixel data with a buffer with incorrect length.")
  scr.pix.data = data

#_______________________________________
# Post-Processing Management
#___________________
proc addPost *(scr :var Screen; frag :paths.Path | string) :uint32 {.discardable.}=
  ## Adds the given fragment shader to the Post-Processing effects list of the screen
  ## Interprets strings as glsl-code, and Paths are read with readFile to access their code.
  ## Returns the id handle of the shader, which...
  ## - ... can be used to remove them at a later time using rmvPost(id).
  ## - ... Is automatically discarded when not assigned anywhere.
  scr.post.add gl.newShaderProg(TriVert, frag)
  result = scr.post[^1].id
proc rmvPost *(scr :var Screen; id :uint32) :void=
  ## Removes the given shader id from the Post-Processing effects list.
  ## Does nothing if the id does not exist in the list.
  for idx,shd in scr.post:
    if shd.id == id: scr.post.delete(idx)

#_______________________________________
# Pixel buffer upload
#___________________
proc uploadInit (scr :var Screen) :void=
  ## Uploads the pixels data of the screen for the first time into OpenGL, and initializes its format.
  ## Should only be called once at init.
  gl.bindTexture(gl.Tex2D, scr.tri.tex)
  gl.texImage2D(
    target         = gl.Tex2D,
    level          = 0,
    internalformat = gl.Rgba8,
    width          = scr.pix.width,
    height         = scr.pix.height,
    border         = 0,
    format         = gl.Rgba,
    typ            = gl.UnsignedByte,
    pixels         = scr.pix.data,
    ) # << gl.texImage2D( ... )
  # Clean-up OpenGL state
  gl.bindTexture(gl.Tex2D, 0)
#___________________
proc upload (scr :var Screen) :void=
  ## Uploads the current pixel buffer into the GPU
  gl.bindTexture(gl.Tex2D, scr.tri.tex)
  gl.texImage2D(   #TODO: Fix the bug in the texSubImage2D function and remove this call
    target         = gl.Tex2D,
    level          = 0,
    internalformat = gl.Rgba8,
    width          = scr.pix.width,
    height         = scr.pix.height,
    border         = 0,
    format         = gl.Rgba,
    typ            = gl.UnsignedByte,
    pixels         = scr.pix.data,
    ) # << gl.texImage2D( ... )
  # gl.texSubImage2D(  # TODO: This method is more efficient, but crashes currently
  #   target  = gl.Tex2D,
  #   level   = 0,
  #   xoffset = 0,
  #   yoffset = 0,
  #   width   = scr.pix.width,
  #   height  = scr.pix.height,
  #   format  = gl.Rgba,
  #   typ     = gl.UnsignedByte,
  #   pixels  = scr.pix.data,
  #   ) # << gl.texSubImage2D( ... )
  # Clean-up OpenGL state
  gl.bindTexture(gl.Tex2D, 0)


#_______________________________________
# Per-Frame update
#___________________
proc update *(scr :var Screen) :void=
  ## Runs the update process of the screen. Must be called each frame.
  i.update()
  scr.win.update()
  # Upload the pixel data to the GPU
  scr.upload()
  # Draw red color screen
  gl.clearColor(1, 0, 0, 1)
  gl.clear(gl.ColorBit)
  # Set the state to draw the Fullscreen Triangle
  gl.useProgram(scr.tri.shd.id)
  gl.bindTexture(gl.Tex2D, scr.tri.tex)
  gl.bindVertexArray(scr.tri.vao)
  gl.drawArrays(mode = gl.Triangles, first=0, count=3)
  for shd in scr.post:
    gl.useProgram(shd.id)
    gl.drawArrays(mode = gl.Triangles, first=0, count=3)
  gl.bindVertexArray(0)
  gl.bindTexture(gl.Tex2D, 0)
  gl.useProgram(0)
  # Swap buffers (will display the red color)
  scr.win.present()
#___________________
proc close *(scr :Screen) :bool=  scr.win.close()
proc term  *(scr :Screen) :void=  scr.win.term()

#_______________________________________
# Constructors
#___________________
proc new (_:typedesc[Triangle];
    vert    : string = TriVert;
    frag    : string = TriFrag;
    pixels  : pixie.Image;
    # mesh = TriMesh;
  ) :Triangle=
  # Compile+Link the shader
  result.shd = gl.newShaderProg(vert, frag)
  # Generate the VAO
  gl.genVertexArrays(1, result.vao.addr)
  gl.bindVertexArray(result.vao)
  gl.bindVertexArray(0)
  # Generate the Pixels texture
  # Initialize the texture handle
  gl.genTextures(1, result.tex.addr)
  gl.bindTexture(gl.Tex2D, result.tex)
  # Configure texture Wrapping
  gl.texParameteri(gl.Tex2D, gl.WrapS, gl.Repeat)
  gl.texParameteri(gl.Tex2D, gl.WrapT, gl.Repeat)
  # Configure texture Filtering
  gl.texParameteri(gl.Tex2D, gl.FilterMin, gl.Nearest)
  gl.texParameteri(gl.Tex2D, gl.FilterMag, gl.Nearest)
  # Clean-up OpenGL state
  gl.bindTexture(gl.Tex2D, 0)
#___________________
proc new *(_:typedesc[Screen];
    pixels       : pixie.Image;
    title        : string                  = "glFB | Window";
    resizable    : bool                    = false;
    resize       : glfw.FrameBufferSizeFun = resize;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = false;
    error        : glfw.ErrorFun           = nil;
    vsync        : bool                    = false;
  ) :Screen=
  new result
  # Initialize the pixel buffer
  result.pix = pixels
  # Initialize the window
  result.win = Window.new(
    size         = uvec2(result.pix.width.uint32, result.pix.height.uint32),
    title        = title,
    resizable    = resizable,
    resize       = resize,
    key          = key,
    mousePos     = mousePos,
    mouseBtn     = mouseBtn,
    mouseScroll  = mouseScroll,
    mouseCapture = mouseCapture,
    error        = error,
    vsync        = vsync,
    ) # << Window.new( ... )
  # Initialize OpenGL
  gl.init()
  gl.viewport(0,0, result.win.size.x.cint, result.win.size.y.cint)
  # Initialize the triangle
  result.tri = Triangle.new(TriVert, TriFrag, result.pix)
  # Upload the first state of the pixel data to the GPU
  result.uploadInit()
#___________________
proc new *(_:typedesc[Screen];
    W,H          : Natural;
    pixels       : seq[ColorRGBX];
    title        : string                  = "glFB | Window";
    resizable    : bool                    = false;
    resize       : glfw.FrameBufferSizeFun = resize;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = false;
    error        : glfw.ErrorFun           = nil;
    vsync        : bool                    = false;
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
    vsync        = vsync,
    ) # << Screen.new( ... )
  result.pix.data = pixels
#___________________
proc new *(_:typedesc[Screen];
    W,H          : Natural;
    title        : string                  = "glFB | Window";
    resizable    : bool                    = false;
    resize       : glfw.FrameBufferSizeFun = resize;
    key          : glfw.KeyFun             = i.key;
    mousePos     : glfw.CursorPosFun       = nil;
    mouseBtn     : glfw.MouseButtonFun     = nil;
    mouseScroll  : glfw.ScrollFun          = nil;
    mouseCapture : bool                    = false;
    error        : glfw.ErrorFun           = nil;
    vsync        : bool                    = false;
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
    vsync        = vsync,
    ) # << Screen.new( ... )

