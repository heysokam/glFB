#:___________________________________________________
#  ngl  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:___________________________________________________
# Aliased OpenGL API  |
#_____________________|
import opengl

# Types
const FloatType             * = cGL_FLOAT
type Float                  * = GL_FLOAT
type Bool                   * = GLboolean
type Int                    * = GLint

# Draw & Clear
const ColorBit              * = GL_COLOR_BUFFER_BIT
const StaticDraw            * = GL_STATIC_DRAW
const Triangles             * = GL_TRIANGLES
const Rgba                  * = GL_RGBA
const Rgba8                 * = GL_RGBA8
const UnsignedByte          * = GL_UNSIGNED_BYTE
let viewport                * = glViewport
let clearColor              * = glClearColor
let clear                   * = glClear
let drawArrays              * = glDrawArrays

# Shaders
const CompileStatus         * = GL_COMPILE_STATUS
const LinkStatus            * = GL_LINK_STATUS
const ValidateStatus        * = GL_VALIDATE_STATUS
const FragmentShader        * = GL_FRAGMENT_SHADER
const VertexShader          * = GL_VERTEX_SHADER
let createShader            * = glCreateShader
let getShaderiv             * = glGetShaderiv
let getProgramiv            * = glGetProgramiv
let getShaderInfoLog        * = glGetShaderInfoLog
let getProgramInfoLog       * = glGetProgramInfoLog
let validateProgram         * = glValidateProgram
let shaderSource            * = glShaderSource
let compileShader           * = glCompileShader
let attachShader            * = glAttachShader
let deleteShader            * = glDeleteShader
let linkProgram             * = glLinkProgram
let createProgram           * = glCreateProgram
let useProgram              * = glUseProgram
let deleteProgram           * = glDeleteProgram
let getUniformLocation      * = glGetUniformLocation

# Textures
const Repeat                * = GL_REPEAT
const Nearest               * = GL_NEAREST
const WrapS                 * = GL_TEXTURE_WRAP_S
const WrapT                 * = GL_TEXTURE_WRAP_T
const FilterMin             * = GL_TEXTURE_MIN_FILTER
const FilterMag             * = GL_TEXTURE_MAG_FILTER
const Tex2D             * = GL_TEXTURE_2D
let genTextures             * = glGenTextures
let bindTexture             * = glBindTexture
let texParameteri           * = glTexParameteri

# Attributes (vao)
const ArrayBuffer           * = GL_ARRAY_BUFFER
let genVertexArrays         * = glGenVertexArrays
let bindVertexArray         * = glBindVertexArray
let vertexAttribPointer     * = glVertexAttribPointer
let enableVertexAttribArray * = glEnableVertexAttribArray

# Buffers
# vbo
let genBuffers              * = glGenBuffers
let bindBuffer              * = glBindBuffer
let bufferData              * = glBufferData

# Template Aliases
template init * = opengl.loadExtensions()
  ## Alias for gl.loadExtensions()

