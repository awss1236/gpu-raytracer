#version 330 core

layout (location=0) in vec2 aPos;

out vec2 _uv;

void main(){
  _uv = aPos*.5 + .5;
  gl_Position = /*proj * viewrot * view */ vec4(aPos, 0.5, 1);
}
