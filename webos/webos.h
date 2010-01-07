void glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);

static inline void glColor3f(GLfloat r, GLfloat g, GLfloat b)
{
    glColor4f(r, g, b, 1.0);
}
	
static inline void glColor3dv(const double *v)	
{
	glColor3f((float)v[0], (float)v[1], (float)v[2]);
}

static inline void glColor4fv(GLfloat *v)
{
	glColor4f((float)v[0], (float)v[1], (float)v[2], (float)v[3]);
}

static inline void glColor4dv(const double *v)
{
	glColor4f((float)v[0], (float)v[1], (float)v[2], (float)v[3]);
}

//FIXME : Not sure
static inline void glFogi( GLenum pname, GLint param ) 
{
	glFogf(pname,(GLfloat) param);
}
	
static inline void glRecti(GLint x1, GLint y1, GLint x2, GLint y2)
{
	glRectf(x1, y1, x2, y2);
}

#define GL_CLAMP GL_CLAMP_TO_EDGE
