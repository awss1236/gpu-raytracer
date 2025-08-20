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
  vec3 emit;
};

float seed = 0;

const float PI = 3.1415926535897932384626433832795;

float random(){
  // this one leads to "blotchy" rendering fsr so i left it there
  seed = fract(seed*seed*32.324+sin(seed*321.123)*1.8574);
  return seed;
  seed = fract(seed * .1031);
  seed *= seed + 33.33;
  seed *= seed + seed;
  return fract(seed);
}

vec3 random_vec3(){
  //float phi = random()*PI;
  //float theta = acos(1-2*random());//*2*PI;

  //return vec3(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi)); // this is not uniform somehow

  float r1 = random(), r2 = random(); // FUCK STATISTICS UNINTUITIVE PIECE OF SHIT
  float x = 2*cos(2*PI*r1)*sqrt(r2*(1-r2));
  float y = 2*sin(2*PI*r1)*sqrt(r2*(1-r2));
  float z = 2*r2 - 1;

  return vec3(x, y, z);
}

vec3 random_in_hemisphere(vec3 h){
  vec3 o = random_vec3();
  if(dot(o, h) < 0){
    return -o;
  }
  return o;
}

hit hit_plane(vec3 ro, vec3 rd, vec3 n, float d){
  hit h;
  h.d = -1.;

  float ln = dot(rd, n);
  if(ln == 0){
    return h;
  }

  h.n = n;
  if(dot(ro, n) < d){
    return h;
    h.back = true;
  }

  h.d = dot(n*d - ro, n) / ln;

  return h;
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
  
  h = hit_sphere(ro, rd, vec3(0, -.8, 1), .2);
  h.r = 1;
  h.albedo = vec3(1);
  h.emit = vec3(0);

  nh = hit_sphere(ro, rd, vec3(.3, -.2, .5), .5);
  nh.r = 1;
  nh.albedo = vec3(1);
  nh.emit = vec3(1);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 1, 0), -1); // bot
  nh.r = .9;
  nh.albedo = vec3(1);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0,-1, 0), -1); // top
  nh.r = .9;
  nh.albedo = vec3(.9);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 0,-1),-2); // back
  nh.r = .0;
  nh.albedo = vec3(.9);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 0, 1), 0); // front
  nh.r = .9;
  nh.albedo = vec3(.9);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(1, 0, 0), -1); // left
  nh.r = 1;
  nh.albedo = vec3(.9, .5, .2);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(-1, 0, 0), -1); // right
  nh.r = 1;
  nh.albedo = vec3(.3, .9, .4);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }
/*
  nh = hit_sphere(ro, rd, vec3(0, -5, 3), 4.5);
  nh.r = .2;
  nh.albedo = vec3(.9);//0.2, 0.8, 0.4);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_sphere(ro, rd, vec3(-.5, -.2, 1.5), .8);
  nh.r = 1.5;
  nh.albedo = vec3(.9);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_sphere(ro, rd, vec3(1.5, -.2, 2.5), .3);
  nh.r = .9;
  nh.albedo = vec3(.9, 0, 0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }
*/
  return h;
}

vec3 sky_color(float y){ // fuck the sky unrealistic p o s
  y = y*.5+.5;
  return mix(vec3(0.8), vec3(0.2, 0.5, 0.9), y*y);
  //return vec3(0);
}

vec3 get_direct_color(vec3 ro, vec3 rd){
  hit h = hit_scene(ro, rd);
  if(h.d<0){
      return sky_color(rd.y);
  }
  return vec3(0);
}

vec3 get_color(vec3 ro, vec3 rd){
  vec3 alb = vec3(1);
  vec3 c = vec3(0);
  for(int i=0;i<10;i++){
    hit h = hit_scene(ro, rd);
    if(h.d<0){
      //c = sky_color(rd.y);
      return c;
    }

    ro = ro + h.d*rd;
    if(h.r<=1){
      vec3 rinh = normalize(h.n + random_vec3());
      //vec3 rinh = random_in_hemisphere(h.n);
      rd = random() <= h.r ? rinh : reflect(rd, h.n);
    }else{
      if(h.back){
        ro += h.n * 0.01;
      }else{
        ro -= h.n * 0.01;
      }

      vec3 refr = refract(rd, h.back?-h.n:h.n, h.back?h.r/1.03:1.03/h.r);

      if(length(refr) < .8){
        rd = reflect(rd, h.n);
      }else{
        rd = refr;
      }
    }

    c += h.emit * alb;
    alb *= h.albedo;
  }

  return c;
}

void main(){
  seed = _uv.x*800+_uv.y;
  random();
  seed += fract(time*13.7123);
  random();
  vec2 uv = _uv * 2. - 1.;
  //uv = uv * vec2(ar, 1);
  vec3 ro = vec3(0, 0, -1);
  vec3 rd = normalize(vec3(uv, 0) - ro);

  FragColor = vec4(get_color(ro, rd), 1);
  /*FragColor = vec4(random_vec3(), 1);
  if(_uv.x>.5)
    FragColor = vec4(vec3(random()*2 - 1), 1);*/
}
