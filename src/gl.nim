#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# Simplified OpenGL API syntax  |
#_______________________________|
import opengl

# OpenGL Configuration
const GLVersionMajor  *{.intdefine.}=  3
const GLVersionMinor  *{.intdefine.}=  3
const GLForwardCompat *{.booldefine.}= true  ## true: Removes deprecated functions. Required for Mac, but we use it for all.

# Constants
let ColorBit   * = GL_COLOR_BUFFER_BIT
# Procs
let clearColor * = glClearColor
let clear      * = glClear

# New Names
template init * = opengl.loadExtensions()
  ## Alias for gl.loadExtensions()

