#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# std dependencies
import std/unittest
# lib dependencies
import glFB as fb
import glFB/gl/shader
import glFB/screen{.all.}

# Post-Processing tests
from chroma import rgbx

var scr = Screen.new(960,540)                         # Initialize the Screen
scr.addPost(DbgFrag)                                  # Add the Debug Post-Processing effect to the list
while not scr.close():                                # Run while the Screen has not been marked for closing
  for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
  scr.update()                                        # Draw the contents
scr.term()                                            # Terminate everything after

