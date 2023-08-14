#:___________________________________________________
#  ngl  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:___________________________________________________
# Simplified Nim OpenGL API  |
#____________________________|
import ./gl/cfg    ; export cfg
import ./gl/api    ; export api
import ./gl/shader ; export shader

import pixie, opengl
proc texImage2D *(target :GLenum; level :SomeInteger; internalformat :GLenum; width, height, border :SomeInteger; format, typ :GLenum; pixels :seq[ColorRGBX] | seq[ColorRGBA]) :void=
  glTexImage2D(target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, border.GLint, format, typ, cast[pointer](pixels[0].addr))
proc texSubImage2D *(target :GLenum; level, xoffset, yoffset, width, height :SomeInteger; format, typ :GLenum; pixels :seq[ColorRGBX] | seq[ColorRGBA]) :void=
  glTexSubImage2D(target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, format, typ, cast[pointer](pixels[0].addr))

