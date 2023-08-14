#:____________________________________________________
#  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:____________________________________________________
import std/os
import std/strformat

#___________________
# Package
packageName   = "glFB"
version       = "0.2.0"
author        = "sOkam"
description   = "gl*FB | Tiny Framebuffer with OpenGL"
license       = "MIT"

#___________________
# Build requirements
requires "nim >= 2.0.0"
requires "https://github.com/heysokam/nstd#head"
requires "https://github.com/heysokam/nmath#head"
requires "https://github.com/heysokam/nglfw#head"
requires "opengl"
requires "pixie"

#___________________
# Folders
srcDir        = "src"
binDir        = "bin"
let testsDir  = "tests"

#___________________
# Binaries
backend       = "c"
bin           = @[packageName]

#________________________________________
# Helpers
#___________________
const vlevel = when defined(debug): 2 else: 1
let nimcr = &"nim c -r --verbosity:{vlevel} --outdir:{binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command
proc runFile (file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command
proc runTest (file :string) :void=  file.runFile(testsDir, "--hints:off")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder

#________________________________________
# Build tasks
#___________________
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{packageName}.nimble"
#___________________
task tests, "Internal:  Builds and runs all tests in the testsDir folder.":
  for file in testsDir.listFiles():
    if file.lastPathPart.startsWith('t'):
      try: runFile file
      except: echo &" └─ Failed to run one of the tests from  {file}"

