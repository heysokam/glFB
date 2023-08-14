#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
# std dependencies
# import std/unittest
# lib dependencies
# import glFB as fb

#_______________________________________
template test {.dirty.}=
  let x = scr.pix.width-1
  let y = scr.pix.height-1
  # Test 1
  let size = (scr.pix.width * scr.pix.height) - 1
  let one = (scr.pix.width) * y + x
  echo size, " == ", one, "  :  ", size == one
  # Test 2
  let two = (scr.pix.height) * x + y
  echo size, " == ", two, "  :  ", size == two

  scr[x,y] = rgbx(1,1,1,1)
  echo scr[x,y]

