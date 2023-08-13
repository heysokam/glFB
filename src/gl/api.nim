#:___________________________________________________
#  ngl  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:___________________________________________________
# Aliased OpenGL API  |
#_____________________|
import opengl

# Constants
let ColorBit   * = GL_COLOR_BUFFER_BIT

# Clear
let clearColor  * = glClearColor
let clear       * = glClear

# Shaders
const CompileStatus    * = GL_COMPILE_STATUS
const LinkStatus       * = GL_LINK_STATUS
const ValidateStatus   * = GL_VALIDATE_STATUS
const FragmentShader   * = GL_FRAGMENT_SHADER
const VertexShader     * = GL_VERTEX_SHADER
let createShader       * = glCreateShader
let getShaderiv        * = glGetShaderiv
let getProgramiv       * = glGetProgramiv
let getShaderInfoLog   * = glGetShaderInfoLog
let getProgramInfoLog  * = glGetProgramInfoLog
let validateProgram    * = glValidateProgram
let shaderSource       * = glShaderSource
let compileShader      * = glCompileShader
let attachShader       * = glAttachShader
let deleteShader       * = glDeleteShader
let linkProgram        * = glLinkProgram
let createProgram      * = glCreateProgram
let useProgram         * = glUseProgram
let deleteProgram      * = glDeleteProgram
let getUniformLocation * = glGetUniformLocation


# Template Aliases
template init * = opengl.loadExtensions()
  ## Alias for gl.loadExtensions()

