#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
import ./glFB/screen ; export screen

#_______________________________________
# Entry Point
#___________________
when isMainModule:
  from chroma import rgbx
  # Initialize the Screen
  var scr = Screen.new(960,540)
  # Run while the Screen has not been marked for closing
  while not scr.close():
    # Generate the pixels on the CPU
    for pix in scr.pixels:  pix = rgbx(255,255,255,255)
    # Draw the contents
    scr.update()
  # Terminate everything after
  scr.term()

