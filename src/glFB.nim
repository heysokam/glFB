#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
from nglfw as glfw import nil
from ./gl import nil

#_______________________________________
# types.nim
#___________________
type InitError * = object of CatchableError

#_______________________________________
# Entry Point
#___________________
# Init GLFW
doAssert glfw.init(), "Failed to Initialize GLFW"

# Open window.
var window = glfw.createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
# Connect the GL context.
glfw.makeContextCurrent(window)
# This must be called to make any GL function work
gl.init()

# Run while window is open.
while not glfw.windowShouldClose(window):
  # Check for input events.
  glfw.pollEvents()
  # Draw red color screen.
  gl.clearColor(1, 0, 0, 1)
  gl.clear(gl.ColorBit)

  # Swap buffers (this will display the red color)
  glfw.swapBuffers(window)

  # If you get ESC key quit.
  if glfw.getKey(window, glfw.KeyEscape) == 1:
    glfw.setWindowShouldClose(window, true)

glfw.destroyWindow(window) # Destroy the window.
glfw.terminate()           # Exit GLFW.
