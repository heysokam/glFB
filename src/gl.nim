#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# Simplified OpenGL API syntax  |
#_______________________________|
import opengl

template init * = opengl.loadExtensions()
  ## Alias for gl.loadExtensions()

let clearColor * = glClearColor
let clear      * = glClear
let ColorBit   * = GL_COLOR_BUFFER_BIT
