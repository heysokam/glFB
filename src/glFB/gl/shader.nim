#:___________________________________________________
#  ngl  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:___________________________________________________
# std dependencies
import std/paths
import std/strutils
# ndk dependencies
import nstd/address
# Module dependencies
from ./api as gl import nil


#____________________
type OpenGLObj *{.inheritable.}= object
  id *:uint32
#____________________
type ShaderBase * = ref object of OpenGLObj
  file *:paths.Path  ## File path where this shader is read from
  src  *:string      ## Source code of the shader
type ShaderVert * = ShaderBase
type ShaderFrag * = ShaderBase
type ShaderProg * = ref object of OpenGLObj

#__________________________________________________
# Compilation Error check
#_____________________________
proc chk (shader :ShaderVert | ShaderFrag) :void=
  ## Checks if the Shader was compiled correctly
  var compiled :int32
  gl.getShaderiv(shader.id, gl.CompileStatus, compiled.addr);
  if not compiled.bool:
    var logLength :int32
    var msg = newString(1024)
    gl.getShaderInfoLog(shader.id, 1024, logLength.addr, msg.cstring);
    echo "::ERR Shader didn't compile correctly:"
    echo msg.join
#__________________________________________________
proc chk (prog :ShaderProg) :void=
  ## Checks if the ShaderProg is valid and was linked correctly
  var ok :int32
  gl.getProgramiv(prog.id, gl.LinkStatus, ok.addr);
  if not ok.bool:
    var logLength :int32
    var msg = newString(1024)
    gl.getProgramInfoLog(prog.id, 1024, logLength.addr, msg.cstring)
    echo "::ERR Shader Program wasn't linked correctly:"
    echo msg.join
  gl.validateProgram(prog.id)
  gl.getProgramiv(prog.id, gl.ValidateStatus, ok.addr);
  if not ok.bool:
    var logLength :int32
    var msg = newString(1024)
    gl.getProgramInfoLog(prog.id, 1024, logLength.addr, msg.cstring)
    echo "::ERR Shader Program is invalid:"
    echo msg.join

#__________________________________________________
# Vertex Shader
#_____________________________
proc newShaderVert *(code :string) :ShaderVert=
  ## Creates and compiles a new ShaderVert from the given source code string.
  new result
  result.id   = gl.createShader(gl.VertexShader)
  result.src  = code
  let tmp     = result.src.cstring
  let length  = result.src.len.int32
  gl.shaderSource(result.id, 1, tmp.caddr, length.caddr)
  gl.compileShader(result.id)
  result.chk()
#_____________________________
proc newShaderVert *(file :paths.Path) :ShaderVert=  newShaderVert(file.string.readFile)
  ## Creates and compiles a new ShaderVert from the given source code file.

#__________________________________________________
# Fragment Shader
#_____________________________
proc newShaderFrag *(code :string) :ShaderFrag=
  ## Creates and compiles a new ShaderFrag from the given source code string.
  new result
  result.id   = gl.createShader(gl.FragmentShader)
  result.src  = code
  let tmp     = result.src.cstring
  let length  = result.src.len.int32
  gl.shaderSource(result.id, 1, tmp.caddr, length.caddr)
  gl.compileShader(result.id)
  result.chk()
#_____________________________
proc newShaderFrag *(file :paths.Path) :ShaderFrag=  newShaderFrag(file.string.readFile)
  ## Creates and compiles a new ShaderFrag from the given source code file.

#__________________________________________________
# Shader Program
#_____________________________
proc newShaderProg *() :ShaderProg=  ShaderProg(id:0)
  ## Creates a new object, with all values set to 0 or empty
#__________________________________________________
proc newShaderProg *(vert :ShaderVert; frag :ShaderFrag) :ShaderProg=
  ## Creates and compiles a new ShaderProg from the given vert and frag objects.
  new result
  # Join fragment and vertex shader into a shader program
  result.id = gl.createProgram()
  gl.attachShader(result.id, vert.id)
  gl.attachShader(result.id, frag.id)
  gl.linkProgram(result.id)
  result.chk()
  # Delete shaders. Linked to the program, not needed anymore
  gl.deleteShader(vert.id)
  gl.deleteShader(frag.id)
#__________________________________________________
proc newShaderProg *(frag :ShaderFrag) :ShaderProg=
  ## Creates and compiles a new ShaderProg from the given vert and frag objects.
  new result
  # Join fragment and vertex shader into a shader program
  result.id = gl.createProgram()
  gl.attachShader(result.id, frag.id)
  gl.linkProgram(result.id)
  result.chk()
  # Delete shaders. Linked to the program, not needed anymore
  gl.deleteShader(frag.id)
#__________________________________________________
proc newShaderProg *(frag :paths.Path | string) :ShaderProg=  frag.newShaderFrag.newShaderProg
  ## Creates a new ShaderProgram from the given fragment shader.
  ## Interprets strings as glsl-code, and Paths are read with readFile to access their code.
#__________________________________________________
proc newShaderProg *(vertCode, fragCode :string) :ShaderProg=
  ## Creates and compiles a new ShaderProg from the given vert+frag source code strings.
  new result
  var vert = vertCode.newShaderVert
  var frag = fragCode.newShaderFrag
  result = newShaderProg(vert, frag)
#__________________________________________________
proc newShaderProg *(vertFile, fragFile :paths.Path) :ShaderProg=
  ## Creates and compiles a new ShaderProg from the given vert+frag source code files.
  new result
  var vert = vertFile.newShaderVert
  var frag = fragFile.newShaderFrag
  result   = newShaderProg(vert, frag)
#__________________________________________________
proc get *(shd :ShaderProg; uName :string) :cint=
  ## Gets the location number for the given uniform name
  # TODO: Use binding instead of location
  result = gl.getUniformLocation(shd.id, uName.cstring)
  # if result == -1: log &"ERR : Couldn't get the location of uniform {uName}\tat shader.id = {shd.id}"
#__________________________________________________
proc enable  *(prog :ShaderProg) :void=  gl.useProgram(prog.id)     ## Marks the shader program for use in OpenGL.
proc disable *(prog :ShaderProg) :void=  gl.useProgram(0)           ## Clears any currently bound Program.
proc term    *(prog :ShaderProg) :void=  gl.deleteProgram(prog.id)  ## Deletes the target program from OpenGL.

