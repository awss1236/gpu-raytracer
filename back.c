#include "glad/glad.h"
#include <GLFW/glfw3.h>
#include "back.h"
#include <stdio.h>
#include <stdlib.h>

const float fov = PI / 3; //Don't forget to attribute this to that homie
const float near = 0.0001;
const float far  = 2000;
int width = 800, height = 800;
float x = 0, y = 0, z = 0, pitch = 0, yaw = 0, mspeed = 0.1;
int mx=0, my=0, mz=0, mp=0, mya=0;

float aspectratio = 1;

void windowresizecallback(GLFWwindow *win, int w, int h) {
  UNUSED(win);
  width = w; height = h;
  aspectratio = (float)w/h;
}

const char* readfile(char* path){
  FILE* f = fopen(path, "rb");
  fseek(f, 0, SEEK_END);
  size_t len = ftell(f);
  fseek(f, 0, SEEK_SET);
  
  char* c = (char*)malloc(len + 1);
  fread((void*)c, len, 1, f);
  *(c+len)='\0';
  fclose(f);
  return (const char*) c;
}

GLFWwindow *window;
void initglfw(){
  glfwInit();
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  window = glfwCreateWindow(width, height, "sex", NULL, NULL);

  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(window, windowresizecallback);
  gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);

  glViewport(0, 0, width, height);
  glEnable(GL_DEPTH_TEST);
}

uint32_t createshader(char* vpath, char* fpath){
  const char *vsrc = readfile(vpath);
  const char *fsrc = readfile(fpath);

  uint32_t vshader = glCreateShader(GL_VERTEX_SHADER),
               fshader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(vshader, 1, &vsrc, NULL);
  glShaderSource(fshader, 1, &fsrc, NULL);
  glCompileShader(vshader);
  int succ;
  char log[512];
  glGetShaderiv(vshader, GL_COMPILE_STATUS, &succ);
  if (!succ) {
    glGetShaderInfoLog(vshader, 512, NULL, log);
    printf("vertex shader fuckup: %s\n", log);
  }
  glCompileShader(fshader);
  glGetShaderiv(fshader, GL_COMPILE_STATUS, &succ);
  if (!succ) {
    glGetShaderInfoLog(fshader, 512, NULL, log);
    printf("fragment shader fuckup: %s\n", log);
  }

  uint32_t vfshader;
  vfshader = glCreateProgram();
  glAttachShader(vfshader, vshader);
  glAttachShader(vfshader, fshader);
  glLinkProgram(vfshader);

  return vfshader;
}

void keypressedcallback(GLFWwindow* w, int k, int s, int a, int m){
  UNUSED(w);
  UNUSED(s);
  UNUSED(a);
  UNUSED(m);
  if(k == GLFW_KEY_U){
    if(a == GLFW_PRESS){
      mspeed *= 1.968;
    }
  }
  if(k == GLFW_KEY_I){
    if(a == GLFW_PRESS){
      mspeed /= 1.968;
    }
  }
  if(k == GLFW_KEY_A){
    if(a == GLFW_PRESS){
      mx =-1;
    }else if(a == GLFW_RELEASE){
      mx = 0;
    }
  }
  if(k == GLFW_KEY_D){
    if(a == GLFW_PRESS){
      mx = 1;
    }else if(a == GLFW_RELEASE){
      mx = 0;
    }
  }
  if(k == GLFW_KEY_SPACE){
    if(a == GLFW_PRESS){
      my = 1;
    }else if(a == GLFW_RELEASE){
      my = 0;
    }
  }
  if(k == GLFW_KEY_V){
    if(a == GLFW_PRESS){
      my =-1;
    }else if(a == GLFW_RELEASE){
      my = 0;
    }
  }
  if(k == GLFW_KEY_W){
    if(a == GLFW_PRESS){
      mz =-1;
    }else if(a == GLFW_RELEASE){
      mz = 0;
    }
  }
  if(k == GLFW_KEY_S){
    if(a == GLFW_PRESS){
      mz = 1;
    }else if(a == GLFW_RELEASE){
      mz = 0;
    }
  }
  if(k == GLFW_KEY_LEFT){
    if(a == GLFW_PRESS){
      mya = 1;
    }else if(a == GLFW_RELEASE){
      mya = 0;
    }
  }
  if(k == GLFW_KEY_RIGHT){
    if(a == GLFW_PRESS){
      mya =-1;
    }else if(a == GLFW_RELEASE){
      mya = 0;
    }
  }
  if(k == GLFW_KEY_UP){
    if(a == GLFW_PRESS){
      mp = 1;
    }else if(a == GLFW_RELEASE){
      mp = 0;
    }
  }
  if(k == GLFW_KEY_DOWN){
    if(a == GLFW_PRESS){
      mp =-1;
    }else if(a == GLFW_RELEASE){
      mp = 0;
    }
  }
}

const float cube[] = {
-0.5, -0.5, -0.5, 0, 0, // 0
-0.5, -0.5,  0.5, 1, 0, // 1
-0.5,  0.5, -0.5, 0, 1, // 2
-0.5,  0.5, -0.5, 0, 1, // 2
-0.5, -0.5,  0.5, 1, 0, // 1
-0.5,  0.5,  0.5, 1, 1, // 3

 0.5, -0.5, -0.5, 0, 0, // 4
 0.5, -0.5,  0.5, 1, 0, // 5
 0.5,  0.5, -0.5, 0, 1, // 6
 0.5,  0.5, -0.5, 0, 1, // 6
 0.5, -0.5,  0.5, 1, 0, // 5
 0.5,  0.5,  0.5, 1, 1, // 7

-0.5, -0.5, -0.5, 0, 0, // 0
 0.5, -0.5, -0.5, 1, 0, // 4
-0.5, -0.5,  0.5, 0, 1, // 1
-0.5, -0.5,  0.5, 0, 1, // 1
 0.5, -0.5, -0.5, 1, 0, // 4
 0.5, -0.5,  0.5, 1, 1, // 5

-0.5,  0.5, -0.5, 0, 0, // 2
 0.5,  0.5, -0.5, 1, 0, // 6
-0.5,  0.5,  0.5, 0, 1, // 3
-0.5,  0.5,  0.5, 0, 1, // 3
 0.5,  0.5, -0.5, 1, 0, // 6
 0.5,  0.5,  0.5, 1, 1, // 7

-0.5, -0.5, -0.5, 0, 0, // 0
 0.5, -0.5, -0.5, 1, 0, // 4
-0.5,  0.5, -0.5, 0, 1, // 2
-0.5,  0.5, -0.5, 0, 1, // 2
 0.5, -0.5, -0.5, 1, 0, // 4
 0.5,  0.5, -0.5, 1, 1, // 6

-0.5, -0.5,  0.5, 0, 0, // 1
-0.5,  0.5,  0.5, 1, 0, // 3
 0.5, -0.5,  0.5, 0, 1, // 5
 0.5, -0.5,  0.5, 0, 1, // 5
-0.5,  0.5,  0.5, 1, 0, // 3
 0.5,  0.5,  0.5, 1, 1, // 7
};
