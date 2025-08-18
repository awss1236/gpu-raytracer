#version 330 core

out vec4 FragColor;

in vec2 _uv;

uniform int n;

uniform sampler2D src;
uniform sampler2D dst;

void main(){
  vec4 sp = texture(src, _uv);
  vec4 dp = texture(dst, _uv);
  FragColor = (dp*n + sp)/(n+1);
}
