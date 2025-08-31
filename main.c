#include "glad/glad.h"
#include <GLFW/glfw3.h>
#include "back.h"
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

const int texsize = 1200;

uint32_t createfb(uint32_t* tex){
  uint32_t fb;
  glGenFramebuffers(1, &fb);
  glBindFramebuffer(GL_FRAMEBUFFER, fb);

  glGenTextures(1, tex);

  glBindTexture(GL_TEXTURE_2D, *tex);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, texsize, texsize, 0, GL_RGB, GL_FLOAT, 0);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, *tex, 0);

  GLenum drawbuffers[1] = {GL_COLOR_ATTACHMENT0};
  glDrawBuffers(1, drawbuffers);
  
  return fb;
}

int main() {
  srand(time(NULL));
  initglfw();
  glfwSetKeyCallback(window, keypressedcallback);
  glDisable(GL_DEPTH_TEST);

  uint32_t nextex;
  uint32_t nexfb = createfb(&nextex);
  uint32_t avgtex;
  uint32_t avgfb = createfb(&avgtex);
  glBindFramebuffer(GL_FRAMEBUFFER, avgfb);
  glViewport(0, 0, texsize, texsize);
  glClearColor(0, 0, 0, 1);
  glClear(GL_COLOR_BUFFER_BIT);

  uint32_t curtex;
  glGenTextures(1, &curtex);

  glBindTexture(GL_TEXTURE_2D, curtex);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, texsize, texsize, 0, GL_RGB, GL_FLOAT, 0);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  uint32_t vao;
  glGenVertexArrays(1, &vao);
  glBindVertexArray(vao);
  uint32_t vbo;
  glGenBuffers(1, &vbo);

  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 6 * 2, (float[12]){
      -1, -1,
      -1,  1,
       1, -1,
       1, -1,
      -1,  1,
       1,  1
      }, GL_STATIC_DRAW);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);

  uint32_t rendershader = createshader("pass.glsl", "raytrace.glsl");
  uint32_t ar = glGetUniformLocation(rendershader, "ar");
  uint32_t rtime = glGetUniformLocation(rendershader, "time");

  uint32_t avgshader = createshader("pass.glsl", "average.glsl");
  uint32_t avn = glGetUniformLocation(avgshader, "n");
  uint32_t avs = glGetUniformLocation(avgshader, "src");
  uint32_t avd = glGetUniformLocation(avgshader, "dst");

  uint32_t dispshader = createshader("pass.glsl", "passtex.glsl");
  uint32_t dispi = glGetUniformLocation(dispshader, "tex");

  uint32_t n = 0;
  double t1, t2;
  double frametime = 0;
  float timeoff = rand() / (float)RAND_MAX;
  while (!glfwWindowShouldClose(window)) {
    t1 = glfwGetTime();
    // render new frame
    glBindFramebuffer(GL_FRAMEBUFFER, nexfb);
    glViewport(0, 0, texsize, texsize);
    glClearColor(0.8, 0.4, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(rendershader);
    glUniform1f(ar, aspectratio);
    glUniform1f(rtime, (float)t1 + timeoff);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // create new avg frame from curren avg and next frame
    glBindFramebuffer(GL_FRAMEBUFFER, avgfb);
    glViewport(0, 0, texsize, texsize);
    glClearColor(0.8, 0.4, 0.8, 1);
    glUseProgram(avgshader);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, nextex);
    glBindTexture(GL_TEXTURE0, nextex);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, curtex);
    glBindTexture(GL_TEXTURE1, curtex);

    glUniform1i(avn, n);
    glUniform1i(avs, 0);
    glUniform1i(avd, 1);
    
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    // copy new avg to current
    glBindTexture(GL_TEXTURE_2D, curtex);
    glReadBuffer(GL_COLOR_ATTACHMENT0);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, 0, 0, texsize, texsize, 0);
    
    // display current
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, width, height);
    glClear(GL_COLOR_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, curtex);
    glBindTexture(GL_TEXTURE0, curtex);
    glUniform1i(dispi, 0);

    glUseProgram(dispshader);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    glfwSwapBuffers(window);
    glfwPollEvents();
    x += (-mz*cos(pitch)*sin(yaw) - mx*cos(yaw)) * mspeed;
    y += (mz*-sin(pitch) + my) * mspeed;
    z += (mz*cos(pitch)*cos(yaw) - mx*sin(yaw)) * mspeed;
    pitch += mp * 0.01;
    yaw += mya * 0.01;
    n += 1;

    t2 = glfwGetTime();
    frametime += t2 - t1;
    if(n%500 == 0){
      frametime /= 500;
      printf("%lf\n", 1/frametime);
      frametime = 0;
    }
  }
  return 0;
}
