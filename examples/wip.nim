#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# std dependencies
import std/unittest
# External dependencies
from chroma import rgbx
# lib dependencies
import glFB as fb


iterator XY *(scr :Screen) :(int,int)=
  ## Iterate through the size of the screen, and return the X,Y coordinates of the current item.
  for row in 0..<scr.pix.height:
    for col in 0..<scr.pix.width:
      yield (row,col)
#_______________________________________
# CPU renderer
#___________________
proc draw (scr :var Screen) :void=
  for row in 0..<scr.pix.height:
    for col in 0..<scr.pix.width:
      let id = scr.pix.width * row + col
      scr.pix.data[id].r = uint8( 255.float32 * (row.float32/scr.pix.width.float32) )
      scr.pix.data[id].g = uint8( 255.float32 * (col.float32/scr.pix.height.float32) )
      scr.pix.data[id].b = 0
      scr.pix.data[id].a = 255
  # for x,y in scr.XY:
  #   scr[x,y].r = 255
  #   scr[x,y].g = 255
  #   scr[x,y].b = 255
  #   scr[x,y].a = 255

const map =
  "0000222222220000" &
  "1              0" &
  "1      11111   0" &
  "1     0        0" &
  "0     0  1110000" &
  "0     3        0" &
  "0   10000      0" &
  "0   0   11100  0" &
  "0   0   0      0" &
  "0   0   1  00000" &
  "0       1      0" &
  "2       1      0" &
  "0       0      0" &
  "0 0000000      0" &
  "0              0" &
  "0002222222200000"
#_______________________________________
# Entry Point
#___________________
var scr = Screen.new(960,540)
while not scr.close():
  scr.draw()
  scr.update()
scr.term()

