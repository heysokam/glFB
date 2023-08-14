//:____________________________________________________
//  glFB  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
//:____________________________________________________
#version 330 core
uniform sampler2D scrPixels;
in vec2 vUV;
out vec4 fColor;
void main() { fColor = texture(scrPixels, vUV); }
