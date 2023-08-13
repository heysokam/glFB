#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
import std/strformat

#___________________
# Package
packageName   = "glFB"
version       = "0.0.0"
author        = "sOkam"
description   = "Tiny Framebuffer | OpenGL"
license       = "MIT"

#___________________
# Build requirements
requires "nim >= 2.0.0"
requires "https://github.com/heysokam/nstd#head"
requires "https://github.com/heysokam/nmath#head"
requires "https://github.com/heysokam/nglfw#head"
requires "opengl"

#___________________
# Folders
srcDir        = "src"
binDir        = "bin"

#___________________
# Binaries
backend       = "c"
bin           = @[packageName]

#________________________________________
# Build tasks
#___________________
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{packageName}.nimble"

