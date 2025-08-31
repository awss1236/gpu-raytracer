#version 330 core

out vec4 FragColor;

in vec2 _uv;

uniform sampler2D tex;

void main(){ // i shall do some shit here
  //float exposure = 1;
  vec3 col = texture(tex, _uv).xyz;

  vec3 new = col / (col + vec3(1)); // vec3(1) - exp(-col*exposure);

  new = pow(new, vec3(1/2.2));

  FragColor = vec4(new, 1);
}
