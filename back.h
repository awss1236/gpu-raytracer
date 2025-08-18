#ifndef back_h
#define back_h
#include <GLFW/glfw3.h>
#include <stdint.h>


#define PI 3.1415

#define UNUSED(x) (void)x

extern const float fov ;
extern const float near;
extern const float far ;

extern int width;
extern int height;

extern float x, y, z, pitch, yaw, mspeed;
extern int mx, my, mz, mp, mya;

extern float aspectratio;
extern GLFWwindow* window;

extern const float cube[5*3*2*6];

const char* readfile(char* path);
void initglfw();
uint32_t createshader(char* vpath, char* fpath);
void keypressedcallback(GLFWwindow* w, int k, int s, int a, int m);
#endif
