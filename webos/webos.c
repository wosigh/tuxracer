#include "tuxracer.h"

void glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) {
  GLfloat v[8] = {
    x1,y1,
    x2,y1,
    x2,y2,
    x1,y2
  };

  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(2, GL_FLOAT, 0, v);
  glDrawArrays(GL_TRIANGLES, 0, 4);
}
