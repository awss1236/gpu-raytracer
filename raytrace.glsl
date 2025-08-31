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

float lambda;

const float PI = 3.1415926535897932384626433832795;

float random(){
  // this one leads to "blotchy" rendering fsr so i left it there
  //seed = fract(seed*seed*32.324+sin(seed*321.123)*1.8574-seed*1.341);
  //seed = fract(sin(seed*PI));
  //return seed;
  seed = fract(sin(dot(vec2(seed, time), vec2(12.9898, 78.233))) * 43758.5453);
  return seed;
  /*seed = fract(seed * .1031);
  seed *= seed + 33.33;
  seed *= seed + time;
  return fract(seed);*/
}

vec3 random_vec3(){// FUCK STATISTICS UNINTUITIVE PIECE OF SHIT
  float r1 = random(), r2 = random();

  float sintheta = 2*sqrt(r1*(1 - r1));//*2*PI;
  float phi = 2*PI*r2;

  return vec3(sintheta*cos(phi), sintheta*sin(phi), 2*r1 - 1); // this is not uniform somehow

  /*float r1 = random(), r2 = random(); 
  float x = 2*cos(2*PI*r1)*sqrt(r2*(1-r2));
  float y = 2*sin(2*PI*r1)*sqrt(r2*(1-r2));
  float z = 2*r2 - 1;

  return vec3(x, y, z);*/
}

vec3 random_in_hemisphere(vec3 h){
  vec3 o = random_vec3();
  if(dot(o, h) < 0){
    return -o;
  }
  return o;
}

float g(const float x, const float a, const float b, const float c){
  float d = x - a;
  d *= (x < a) ? b : c;
  return exp(-0.5 * d * d);
}

vec3 wl2xyz_CIE1931(const float w){
  float x = 1.056 * g(w, 599.8, 0.0264, 0.0323) + 0.362 * g(w, 442.0, 0.0624, 0.0374) - 0.065 * g(w, 501.1, 0.049, 0.0382);
  float y = 0.821 * g(w, 568.8, 0.0213, 0.0247) + 0.286 * g(w, 530.9, 0.0613, 0.0322);
  float z = 1.217 * g(w, 437.0, 0.0845, 0.0278) + 0.681 * g(w, 459.0, 0.0385, 0.0725);
  return vec3(x,y,z);
}

const mat3 XYZ_WGRGB =
  mat3( 1.4628067, -0.1840623, -0.2743606,
       -0.5217933,  1.4472381,  0.0677227,
       0.0349342, -0.0968930,  1.2884099);

vec3 wl_to_rgb(float w){
  return wl2xyz_CIE1931(w) * XYZ_WGRGB;
}

hit hit_plane(vec3 ro, vec3 rd, vec3 n, float d){
  hit h;
  h.d = -1.;

  float ln = dot(rd, n);
  if(ln > -0.001){
    h.back = true;
    return h;
  }

  h.n = n;
  h.d = (d-dot(ro, n)) / ln;

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

  h = hit_sphere(ro, rd, vec3(-0.8, 0, 1), .2);
  h.r = 1;
  h.albedo = vec3(0);
  h.emit = vec3(10);

  nh = hit_sphere(ro, rd, vec3(0, 0, 1), .3);
  nh.r = 1.5 + 50 / (lambda - 350);
  nh.albedo = vec3(1);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 1, 0), -1); // bot
  nh.r = 1;
  nh.albedo = vec3(0);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0,-1, 0), -1); // top
  nh.r = 1;
  nh.albedo = vec3(0);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 0,-1),-2); // back
  nh.r = 1;
  nh.albedo = vec3(1);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(0, 0, 1), 0); // front
  nh.r = 1;
  nh.albedo = vec3(0);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(1, 0, 0), -1); // left
  nh.r = 1;
  nh.albedo = vec3(0);
  nh.emit = vec3(0);
  if(nh.d > 0 && (nh.d < h.d || h.d < 0)){
    h = nh;
  }

  nh = hit_plane(ro, rd, vec3(-1, 0, 0), -1); // right
  nh.r = 1;
  nh.albedo = vec3(1);
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
  for(int i=0;i<3;i++){
    hit h = hit_scene(ro, rd);
    /*float fogdist = log(random())/log(.01);

    if(h.d< 0 || h.d > fogdist){ // foggy
      ro = ro + fogdist*rd;
      rd = normalize(1*rd + 4*random_vec3() + 0*vec3(-1, 0, 0)); // this needs a little more thought i'd say
      alb *= 0.9;
      continue;
    }*/
    if(h.d < 0){
      return vec3(5, 0, 5);
    }

    ro = ro + h.d*rd;
    if(h.r<=1){
      vec3 rinh = normalize(h.n + random_vec3());
      //vec3 rinh = random_in_hemisphere(h.n);
      rd = random() < h.r ? rinh : reflect(rd, h.n);
      //return vec3(rd.z);//(1+h.n)/2;
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
    if(length(alb) < .01){
      break;
    }
  }

  return c;
}

void main(){
  seed = time;
  random();
  lambda = random()*(700 - 380) + 380; // maybe change that 700 to 780 for a less blueish look but i kinda like it -\_(
  seed += _uv.x*1200 + _uv.y;
  random();
  //seed += _uv.y;
  //random();
  //seed += fract(time*13.7123) + 124.34;
  //random();
  vec2 uv = _uv * 2. - 1.;
  //uv = uv * vec2(ar, 1);
  vec3 ro = vec3(0, 0, -1);
  vec3 rd = normalize(vec3(uv, 0) - ro);

  //FragColor = vec4(get_color(ro, rd)*wl_to_rgb(lambda), 1);
  FragColor = vec4(0);
  for(int i=0;i<5;i++)
    FragColor += vec4(get_color(ro, rd)*wl_to_rgb(lambda), 1);
  FragColor /= 5;
  /*FragColor = vec4(random_vec3(), 1);
  if(_uv.x>.5)
    FragColor = vec4(vec3(sin(random()*2*PI)), 1);*/
}
