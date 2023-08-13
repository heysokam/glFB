#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
from nglfw as glfw import nil


proc key *(win :glfw.Window; key, code, action, mods :cint) :void {.cdecl.}=
  ## GLFW Keyboard Input Callback
  if (key == glfw.KeyEscape and action == glfw.Press):
    glfw.setWindowShouldClose(win, true)

