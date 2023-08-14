#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
import ./glFB/screen ; export screen

#_______________________________________
# Entry Point for the debug example
#___________________
when isMainModule:
  from chroma import rgbx

  var scr = Screen.new(960,540)                         # Initialize the Screen
  while not scr.close():                                # Run while the Screen has not been marked for closing
    for pix in scr.pixels: pix = rgbx(255,255,255,255)  # Generate the pixels on the CPU
    scr.update()                                        # Draw the contents
  scr.term()                                            # Terminate everything after

