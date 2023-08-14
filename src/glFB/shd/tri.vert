//:____________________________________________________
//  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
//:____________________________________________________
// Hardcoded Fullscreen triangle in NDC coordinates |
// UVs flipped vertically, so that 0,0 is topleft   |
//__________________________________________________|
#version 330 core
out vec2 vUV;
void main() { 
  vec2 vertices[3] = vec2[3](
    vec2(-1,-1),
    vec2( 3,-1),
    vec2(-1, 3));
  gl_Position = vec4(vertices[gl_VertexID],0,1);
  vUV   = 0.5 * gl_Position.xy + vec2(0.5);

  // vUV.flipVertical(), so that (0,0) is at topleft (OpenGL wants 0,0 at bottomleft)
  // TODO: Flip the triangle vertices instead, and figure out backface drawing
  vUV.y = 1-vUV.y;
}
