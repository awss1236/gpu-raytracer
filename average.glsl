#version 330 core

out vec4 FragColor;

in vec2 _uv;

uniform int n;

uniform sampler2D src;
uniform sampler2D dst;

//const float PI = 3.1415926535897932384626433832795;

void main(){
  vec4 sp = texture(src, _uv);
  vec4 dp = texture(dst, _uv);

  if(dp.x != dp.x){
    dp.x = 0;
  }
  if(dp.y != dp.y){
    dp.y = 0;
  }
  if(dp.z != dp.z){
    dp.z = 0;
  }

  FragColor = dp*n/(n+1) + sp/(n+1);
  //FragColor = (dp*500 + sp)/501;
}
