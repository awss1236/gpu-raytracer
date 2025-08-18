#version 330 core

out vec4 FragColor;

in vec2 _uv;

uniform float ar;
uniform float time;

struct hit{
  float d;
  vec3 n;
  float r;
  bool back;
  vec3 albedo;
};

float seed = 0;

const float PI = 3.1415926535897932384626433832795;

float random(){
  seed = fract(cos(seed*234.41+23.43*seed*seed)*134.51-seed);
  return seed;
}

vec3 random_vec3(){
  float phi = random()*PI;
  float theta = random()*2*PI;

  return vec3(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi));
}

vec3 random_in_hemisphere(vec3 h){
  vec3 o = random_vec3();
  if(dot(o, h) < 0){
    return -o;
  }
  return o;
}

hit hit_sphere(vec3 ro, vec3 rd, vec3 c, float r){
  vec3 co = ro - c;
  
  float x = dot(rd, co);
  float del = x*x - dot(co, co) + r*r;

  hit h;
  h.d = -1.;
  
  if(del < 0){
    return h;
  }

  float d = -x-sqrt(del);
  vec3 p = ro+d*rd;
  h.d = d;
  h.n = normalize(p - c);
  
  h.back = false;
  if(length(co) < r){
    h.back = true;
  }

  return h;
}

hit hit_scene(vec3 ro, vec3 rd){
  hit h;
  hit nh;
  
  h = hit_sphere(ro, rd, vec3(0, .5, 3), 1);
  h.r = 0;
  h.albedo = vec3(.8);//0.9, 0.6, 0.2);

  nh = hit_sphere(ro, rd, vec3(0, -5, 3), 4.5);
  nh.r = 0;
  nh.albedo = vec3(0.2, 0.8, 0.4);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_sphere(ro, rd, vec3(-.5, -.2, 1.5), 0.3);
  nh.r = 1.5;
  nh.albedo = vec3(.9);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }
  
  return h;
}

vec3 sky_color(float y){
  y = y*.5+.5;
  return mix(vec3(0.8), vec3(0.2, 0.5, 0.9), y*y);
}

vec3 get_direct_color(vec3 ro, vec3 rd){
  hit h = hit_scene(ro, rd);
  if(h.d<0){
      return sky_color(rd.y);
  }
  return vec3(0);
}

vec3 get_color(vec3 ro, vec3 rd){
  vec3 c = vec3(1);
  for(int i=0;i<10;i++){
    hit h = hit_scene(ro, rd);
    if(h.d<0){
      c *= sky_color(rd.y);
      return c;
    }

    ro = ro + h.d*rd;
    if(h.r<=1){
      vec3 rinh = random_in_hemisphere(h.n);
      rd = random() <= h.r ? rinh : reflect(rd, h.n);
    }else{
      if(h.back){
        ro += h.n * 0.01;
      }else{
        ro -= h.n * 0.01;
      }
      rd = refract(rd, h.back?-h.n:h.n, h.back?h.r:1/h.r);
      if(rd == vec3(0))
        return vec3(0);
    }

    c *= h.albedo;
  }

  return c*get_direct_color(ro, rd);
}

void main(){
  seed = _uv.x+_uv.y*13.4*_uv.x;
  random();
  seed += time;
  random();
  vec2 uv = _uv * 2. - 1.;
  //uv = uv * vec2(ar, 1);
  vec3 ro = vec3(0, 0, -1);
  vec3 rd = normalize(vec3(uv, 0) - ro);

  FragColor = vec4(0);
  for(int i=0;i<10;i++)
    FragColor += vec4(get_color(ro, rd), 1);
  FragColor /= 10;
}
