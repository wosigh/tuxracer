/* 
 * Tux Racer 
 * Copyright (C) 1999-2001 Jasmin F. Patry
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#include "tuxracer.h"
#include "course_load.h"
#include "course_render.h"
#include "textures.h"
#include "phys_sim.h"
#include "hier_util.h"
#include "gl_util.h"
#include "render_util.h"
#include "fog.h"
#include "course_quad.h"
#include "viewfrustum.h"
#include "track_marks.h"
#include "multiplayer.h"

#include <sys/mman.h>
#include <fcntl.h>

/* 
 *  Constants 
 */

/* How long to make the flat part at the bottom of the course, as a
 fraction of the total length of the course */
#define FLAT_SEGMENT_FRACTION 0.2

/* Aspect ratio of background texture */
#define BACKGROUND_TEXTURE_ASPECT 3.0


/*
 * Statics 
 */

static const int kFlagType = 1;
static const int kStartType = 4;

/* The course normal vectors */
static vector_t *nmls = (void*)-1;

static size_t nmls_len = 0;
static int nmls_fd = -1;

/* Should we activate clipping when drawing the course? */
static bool_t clip_course = False;

/* If clipping is active, it will be based on a camera located here */
static point_t eye_pt;

static tree_t* treeLocsOrderedByZ=NULL;
static int first_tree_to_check=0;

static item_t* itemLocs = NULL;
static int numItems = 0;

/* Macros for converting indices in height map to world coordinates */
#define XCD(x) (  (scalar_t)(x) / (nx-1.) * courseWidth )
#define ZCD(y) ( -(scalar_t)(y) / (ny-1.) * courseLength )

#define NORMAL(x, y) ( nmls[ (x) + nx * (y) ] )


/*
 * Function definitions
 */

void set_course_clipping( bool_t state ) { clip_course = state; }
void set_course_eye_point( point_t pt ) { eye_pt = pt; }

vector_t* get_course_normals() { return nmls; } 

void calc_normals(const char *course)
{
    scalar_t *elevation;
    scalar_t courseWidth, courseLength;
    int nx, ny;
    int x,y;
    point_t p0, p1, p2;
    vector_t n, nml, v1, v2;
    char buff[BUFF_LEN];
	
    sprintf( buff, "%s/courses/%s/normal.data", getparam_data_dir(), course );
	
    get_course_dimensions( &courseWidth, &courseLength );
    get_course_divisions( &nx, &ny );
	
    if(nmls != (void*)-1 && nmls_fd != -1) 
    {
        munmap(nmls, nmls_len);
        close(nmls_fd);
    }
#if 0
    else {
        free(nmls);
    }
#endif
	
    struct stat buf;
    int exists = (stat(buff, &buf) == 0);
	
    if(exists) {
        nmls_fd = open(buff, O_RDONLY);
        if ( nmls_fd == -1) {
            handle_system_error( 1, "can't open file failed" );
        }
		
        TRDebugLog("mapping to memory normal.data\n");
        nmls_len = sizeof(vector_t)*nx*ny;
        nmls = mmap(NULL, nmls_len, PROT_READ, MAP_SHARED,nmls_fd, 0);
        if ( nmls == (void *)-1 ) {
            handle_system_error( 1, "read mmap failed" );
        }
    }
    else {
        nmls_len = sizeof(vector_t)*nx*ny;
		
#if TARGET_IPHONE_SIMULATOR
        nmls_fd = open(buff, O_RDWR | O_CREAT | O_TRUNC, 0644);
        if ( nmls_fd == -1) {
            handle_system_error( 1, "can't open file failed" );
        }
		
		
        int result = lseek(nmls_fd, nmls_len-1, SEEK_SET);
        if (result == -1) {
            handle_system_error( 1, "can't write file failed" );
        }
        
        result = write(nmls_fd, "", 1);
        if (result != 1) {
            handle_system_error( 1, "can't write file failed" );
        }
		
        nmls = mmap(NULL, nmls_len, PROT_READ | PROT_WRITE, MAP_SHARED, nmls_fd, 0);
        if ( nmls == (void *)-1 ) {
            handle_system_error( 1, "write mmap failed" );
        }
		
        TRDebugLog("Writing to normal.data\n");
#else
# ifdef TR_DEBUG_MODE
        abort(); // This shouldn't be reached on simulator. Crash to indicate.
# endif
        nmls = malloc(nmls_len);
#endif
        
        elevation = get_course_elev_data();
		
        for ( y=0; y<ny; y++) {
            for ( x=0; x<nx; x++) {
                nml = make_vector( 0., 0., 0. );
                
                p0 = make_point( XCD(x), ELEV(x,y), ZCD(y) );
                
                /* The terrain is meshed as follows:
                 ...
                 +-+-+-+-+            x<---+
                 |\|/|\|/|                 |
                 ...+-+-+-+-+...              V
                 |/|\|/|\|                 y
                 +-+-+-+-+
                 ...
                 
                 So there are two types of vertices: those surrounded by
                 four triangles (x+y is odd), and those surrounded by
                 eight (x+y is even).
                 */
                
#define POINT(x,y) make_point( XCD(x), ELEV(x,y), ZCD(y) )
                
                if ( (x + y) % 2 == 0 ) {
                    if ( x > 0 && y > 0 ) {
                        p1 = POINT(x,  y-1);
                        p2 = POINT(x-1,y-1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                        
                        p1 = POINT(x-1,y-1);
                        p2 = POINT(x-1,y  );
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x > 0 && y < ny-1 ) {
                        p1 = POINT(x-1,y  );
                        p2 = POINT(x-1,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                        
                        p1 = POINT(x-1,y+1);
                        p2 = POINT(x  ,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x < nx-1 && y > 0 ) {
                        p1 = POINT(x+1,y  );
                        p2 = POINT(x+1,y-1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                        
                        p1 = POINT(x+1,y-1);
                        p2 = POINT(x  ,y-1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x < nx-1 && y < ny-1 ) {
                        p1 = POINT(x+1,y  );
                        p2 = POINT(x+1,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v1, v2 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                        
                        p1 = POINT(x+1,y+1);
                        p2 = POINT(x  ,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v1, v2 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                        
                    } 
                } else {
                    /* x + y is odd */
                    if ( x > 0 && y > 0 ) {
                        p1 = POINT(x,  y-1);
                        p2 = POINT(x-1,y  );
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x > 0 && y < ny-1 ) {
                        p1 = POINT(x-1,y  );
                        p2 = POINT(x  ,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x < nx-1 && y > 0 ) {
                        p1 = POINT(x+1,y  );
                        p2 = POINT(x  ,y-1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v2, v1 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                    if ( x < nx-1 && y < ny-1 ) {
                        p1 = POINT(x+1,y  );
                        p2 = POINT(x  ,y+1);
                        v1 = subtract_points( p1, p0 );
                        v2 = subtract_points( p2, p0 );
                        n = cross_product( v1, v2 );
                        
                        check_assertion( n.y > 0, "course normal points down" );
                        
                        normalize_vector( &n );
                        nml = add_vectors( nml, n );
                    } 
                }
                
                normalize_vector( &nml );
                NORMAL(x,y) = nml;
                continue;
            } 
#undef POINT
        }
#if TARGET_IPHONE_SIMULATOR
        munmap(nmls, nmls_len);
        close(nmls_fd);
		
        nmls_fd = open(buff, O_RDONLY);
        if (nmls_fd == -1) {
            handle_system_error( 1, "can't remount normal.data" );
        }
		
        TRDebugLog("remounting to memory normal.data\n");
        nmls_len = sizeof(vector_t)*nx*ny;
        nmls = mmap(NULL, nmls_len, PROT_READ, MAP_SHARED, nmls_fd, 0);
        if ( nmls == (void *)-1 ) {
            handle_system_error( 1, "remount mmap failed" );
        }
#endif
    }
} 

void setup_course_tex_gen()
{
    static GLfloat xplane[4] = { 1.0 / TEX_SCALE, 0.0, 0.0, 0.0 };
    static GLfloat zplane[4] = { 0.0, 0.0, 1.0 / TEX_SCALE, 0.0 };
    
    glTexGenfv( GL_S, GL_OBJECT_PLANE, xplane );
    glTexGenfv( GL_T, GL_OBJECT_PLANE, zplane );
}

#define DRAW_POINT \
glNormal3f( nml.x, nml.y, nml.z ); \
glVertex3f( pt.x, pt.y, pt.z ); 

void render_course()
{
    int nx, ny;
    
    get_course_divisions(&nx, &ny);
    set_gl_options( COURSE );
    
    setup_course_tex_gen();
    
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
    set_material( white, black, 1.0 );
    
    update_course_quadtree( eye_pt, getparam_course_detail_level() );
    
    render_course_quadtree( );
    
    draw_track_marks();
}

void draw_sky(point_t pos)
{
    GLuint texture_id[6];
    
    set_gl_options( SKY );
    
    if (!(get_texture_binding( "sky_front", &texture_id[0] ) && 
          get_texture_binding( "sky_top", &texture_id[1] ) && 
          get_texture_binding( "sky_bottom", &texture_id[2] ) && 
          get_texture_binding( "sky_left", &texture_id[3] ) && 
          get_texture_binding( "sky_right", &texture_id[4] ) && 
          get_texture_binding( "sky_back", &texture_id[5] ) ) ) {
        return;
    } 
    
    glColor4f( 1.0, 1.0, 1.0, 1.0 );
    
    glPushMatrix();
    
    glTranslatef(pos.x, pos.y, pos.z);
    
#ifdef __APPLE__
#undef glEnableClientState
#undef glDisableClientState
#undef glVertexPointer
#undef glTexCoordPointer
#undef glDrawArrays
#undef glDrawElements
    
    static const GLfloat vertices []=
    {
        -1, -1, -1, //0
        1, -1, -1, //1
        1,  1, -1, //2
        -1,  1, -1, //3
        -1, -1, -1, //0
        1,  1, -1, //2
        
        -1,  1, -1,
        1,  1, -1,
        1,  1,  1,
        -1,  1,  1,
        -1,  1, -1,
        1,  1,  1,
        
        -1, -1,  1,
        1, -1,  1,
        1, -1, -1,
        -1, -1, -1,
        -1, -1,  1,
        1, -1, -1,
        
        -1, -1,  1,
        -1, -1, -1,
        -1,  1, -1,
        -1,  1,  1,
        -1, -1,  1,
        -1,  1, -1,
        
        1, -1, -1,
        1, -1,  1,
        1,  1,  1,
        1,  1, -1,
        1, -1, -1,
        1,  1,  1,
        
        1, -1,  1,
        -1, -1,  1,
        -1,  1,  1,
        1,  1,  1,
        1, -1,  1,
        -1,  1,  1,
    };
    
    static const GLfloat texCoords []=
    {
        // Work around an iphone FPU/GL? bug
        // that makes the plane and texture non contiguous.
        // this removes an artifacts visible in the sky
#define ZERO 0.01
#define ONE 0.99
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
        
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
        
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
        
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
        
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
        
        ZERO, ZERO ,
        ONE, ZERO ,
        ONE, ONE ,
        ZERO, ONE ,
        ZERO, ZERO ,
        ONE, ONE ,
    };
    
    
    glEnableClientState (GL_VERTEX_ARRAY);
    glEnableClientState (GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glVertexPointer (3, GL_FLOAT , 0, vertices);	
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    int i = 0;
    
    for(i =0; i < 6; i++) {
        glBindTexture( GL_TEXTURE_2D, texture_id[i] );
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
        glDrawArrays(GL_TRIANGLES, i*6, 6);
    }
    
#else
    
    glBindTexture( GL_TEXTURE_2D, texture_id[0] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f( -1, -1, -1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f(  1, -1, -1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f(  1,  1, -1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f( -1,  1, -1);
    glEnd();
    
    glBindTexture( GL_TEXTURE_2D, texture_id[1] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f( -1,  1, -1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f(  1,  1, -1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f(  1,  1,  1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f( -1,  1,  1);
    glEnd();
    
    glBindTexture( GL_TEXTURE_2D, texture_id[2] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f( -1, -1,  1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f(  1, -1,  1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f(  1, -1, -1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f( -1, -1, -1);
    glEnd();
    
    glBindTexture( GL_TEXTURE_2D, texture_id[3] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f( -1, -1,  1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f( -1, -1, -1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f( -1,  1, -1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f( -1,  1,  1);
    glEnd();
    
    glBindTexture( GL_TEXTURE_2D, texture_id[4] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f(  1, -1, -1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f(  1, -1,  1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f(  1,  1,  1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f(  1,  1, -1);
    glEnd();
    
    glBindTexture( GL_TEXTURE_2D, texture_id[5] );
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
    
    glBegin(GL_QUADS);
    glTexCoord2f( 0.0, 0.0 );
    glVertex3f(  1, -1,  1);
    glTexCoord2f( 1.0, 0.0 );
    glVertex3f( -1, -1,  1);
    glTexCoord2f( 1.0, 1.0 );
    glVertex3f( -1,  1,  1);
    glTexCoord2f( 0.0, 1.0 );
    glVertex3f(  1,  1,  1);
    glEnd();
#endif
    glPopMatrix();
    
}
/* fonction utilisateur de comparaison fournie a qsort() */
static int compare_func (void const *a, void const *b)
{
    tree_t const *treeA = a;
    tree_t const *treeB = b;
    
    point_t locA,locB;
    int ret = 0;
    
    locA = (*treeA).ray.pt;
    locB = (*treeB).ray.pt;
    
    scalar_t diff = fabs(locA.z) - fabs(locB.z);
    
    if (diff > 0)
    {
        ret = 1;
    }
    else if (diff < 0)
    {
        ret = -1;
    }
    
    return ret;
}

int order_trees_by_z (tree_t* treeLocs,int num_trees)
{
    qsort (treeLocs, num_trees, sizeof(tree_t), compare_func);
    return 0;
}

void draw_trees() 
{
    tree_t    *treeLocs;
    int       numTrees;
    scalar_t  treeRadius;
    scalar_t  treeHeight;
    int       i;
    GLuint    texture_id = 0;
    vector_t  normal;
    scalar_t  fwd_clip_limit, bwd_clip_limit, fwd_tree_detail_limit;
    
    int tree_type = -1;
    char *tree_name = 0;
    
    
    scalar_t  itemRadius;
    scalar_t  itemHeight;
    int       item_type = -1;
    char *    item_name = 0;
    item_type_t *item_types;
    
    treeLocs = treeLocsOrderedByZ;
    numTrees = get_num_trees();
    item_types = get_item_types();
    
    fwd_clip_limit = getparam_forward_clip_distance();
    bwd_clip_limit = getparam_backward_clip_distance();
    fwd_tree_detail_limit = getparam_tree_detail_distance();
    
    set_gl_options( TREES );
    
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
    set_material( white, black, 1.0 );
    
#ifdef __APPLE__
#undef glVertexPointer
#undef glTexCoordPointer
#undef glEnableClientState
#undef glDisableClientState
#undef glDrawArrays
    static const GLfloat verticesTree []=
    {
        -1.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0,
        -1.0, 1.0, 0.0,
        -1.0, 0.0, 0.0,
        1.0, 1.0, 0.0,
        
        0.0, 0.0, -1.0,
        0.0, 0.0,  1.0,
        0.0, 1.0,  1.0,
        0.0, 1.0, -1.0,
        0.0, 0.0, -1.0,
        0.0, 1.0,  1.0,
        
    };
    static const GLfloat texCoordsTree []=
    {
        0.0, 0.0 ,
        1.0, 0.0 ,
        1.0, 1.0 ,
        0.0, 1.0 ,
        0.0, 0.0 ,
        1.0, 1.0 ,
        
        0.0, 0.0 ,
        1.0, 0.0 ,
        1.0, 1.0 ,
        0.0, 1.0 ,
        0.0, 0.0 ,
        1.0, 1.0 ,
        
    };
    glVertexPointer (3, GL_FLOAT , 0, verticesTree);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoordsTree);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
#endif
    
    for (i = first_tree_to_check; i< numTrees; i++ ) {
        if ( clip_course ) {
            if ( eye_pt.z - treeLocs[i].ray.pt.z > fwd_clip_limit ) 
                //printf("break :  eye_pt.z - treeLocs[i].ray.pt.z = %f > fwd_clip_limit = %f\n",eye_pt.z - treeLocs[i].ray.pt.z,fwd_clip_limit);
                break;
            if ( treeLocs[i].ray.pt.z - eye_pt.z > bwd_clip_limit ){
                first_tree_to_check = i;
                //printf("continue : treeLocs[i].ray.pt.z - eye_pt.z = %f > bwd_clip_limit = %f\n",treeLocs[i].ray.pt.z - eye_pt.z,bwd_clip_limit);
                continue;
            }
            //printf("condition 1 : eye_pt.z - treeLocs[i].ray.pt.z = %f > fwd_clip_limit = %f\n",eye_pt.z - treeLocs[i].ray.pt.z,fwd_clip_limit);
			// printf("condition 2 : treeLocs[i].ray.pt.z - eye_pt.z = %f > bwd_clip_limit = %f\n",treeLocs[i].ray.pt.z - eye_pt.z,bwd_clip_limit);
        }
        /* verify that the correct texture is bound */
        if (treeLocs[i].tree_type != tree_type) {
            tree_type = treeLocs[i].tree_type;
            tree_name = get_tree_name(tree_type);
            if (!get_texture_binding( tree_name, &texture_id ) ) {
                texture_id = 0;
            }
            glBindTexture( GL_TEXTURE_2D, texture_id );
        }
        
        glPushMatrix();
        glTranslatef( treeLocs[i].ray.pt.x, treeLocs[i].ray.pt.y, 
                     treeLocs[i].ray.pt.z );
        
        treeRadius = treeLocs[i].diam/2.;
        treeHeight = treeLocs[i].height;
        
        normal = subtract_points( eye_pt, treeLocs[i].ray.pt );
        normalize_vector( &normal );
        
        glNormal3f( normal.x, normal.y, normal.z );
        
#ifdef __APPLE__
        glScalef(treeRadius, treeHeight, treeRadius);
        
        bool drawTwoPlanes = false;
        if ( !clip_course ||
            eye_pt.z - treeLocs[i].ray.pt.z < fwd_tree_detail_limit )
            drawTwoPlanes = true;
        
        glDrawArrays(GL_TRIANGLES, 0, 6 + drawTwoPlanes ? 6 : 0);
        
#else
        glBegin( GL_QUADS );
        glTexCoord2f( 0., 0. );
        glVertex3f( -treeRadius, 0.0, 0.0 );
        glTexCoord2f( 1., 0. );
        glVertex3f( treeRadius, 0.0, 0.0 );
        glTexCoord2f( 1., 1. );
        glVertex3f( treeRadius, treeHeight, 0.0 );
        glTexCoord2f( 0., 1. );
        glVertex3f( -treeRadius, treeHeight, 0.0 );
        
        if ( !clip_course ||
            eye_pt.z - treeLocs[i].ray.pt.z < fwd_tree_detail_limit )
        {
            glTexCoord2f( 0., 0. );
            glVertex3f( 0.0, 0.0, -treeRadius );
            glTexCoord2f( 1., 0. );
            glVertex3f( 0.0, 0.0, treeRadius );
            glTexCoord2f( 1., 1. );
            glVertex3f( 0.0, treeHeight, treeRadius );
            glTexCoord2f( 0., 1. );
            glVertex3f( 0.0, treeHeight, -treeRadius );
        }
        
        glEnd();
        
#endif
        
        glPopMatrix();
    } 
    
	
	
	
#ifdef __APPLE__
	static const GLfloat verticesItem []=
	{
		-1.0, 0.0,  1.0,
		1.0, 0.0, -1.0,
		1.0, 1.0, -1.0,
		-1.0, 1.0,  1.0,
		-1.0, 0.0,  1.0,
		1.0, 1.0, -1.0,
	};
	
	static const GLfloat texCoordsItem []=
	{
		0.0, 0.0 ,
		1.0, 0.0 ,
		1.0, 1.0 ,
		0.0, 1.0 ,
		0.0, 0.0 ,
		1.0, 1.0 ,
	};
	glVertexPointer (3, GL_FLOAT , 0, verticesItem);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordsItem);
#endif
	texture_id = 0;
	for (i = 0; i< numItems; i++ ) {
#ifdef __APPLE__
		if (g_game.is_speed_only_mode || !g_game.practicing) {
			if ( itemLocs[i].collectable == 1) {
				/* In speed mode or in tutorial we don't want to draw fishes*/
				continue;
			}
		}
#endif
		if ( itemLocs[i].collectable == 0 || itemLocs[i].drawable == False) {
			/* already collected or not to be drawn*/
			continue;
		}
		if ( clip_course ) {
			if ( eye_pt.z - itemLocs[i].ray.pt.z > fwd_clip_limit ) 
				continue;
			
			if ( itemLocs[i].ray.pt.z - eye_pt.z > bwd_clip_limit )
				continue;
		}
		
		/*  load texture id if needed */
		if (!itemLocs[i].sponsor_binded)
		{
			itemLocs[i].sponsor_binded = True;

			if(itemLocs[i].item_type == kFlagType)
			{
				int r = rand() % 2;
				item_name = r ? "flag_furlan" : "flag_zag";		/*un drapeau sur 2 portera le logo zag ou furlan, au hasard*/			
			}
			else {
				item_name = get_item_name(itemLocs[i].item_type);
			}
			if (!get_texture_binding( item_name, &itemLocs[i].tid ) ) {
				itemLocs[i].tid = 0;
			}
		}

		/* verify that the correct texture is bound */
		if (itemLocs[i].tid != texture_id) {
			glBindTexture( GL_TEXTURE_2D, itemLocs[i].tid );
			texture_id = itemLocs[i].tid;
		}
				
		glPushMatrix();
		{
			glTranslatef( itemLocs[i].ray.pt.x, itemLocs[i].ray.pt.y, 
						 itemLocs[i].ray.pt.z );
			
			itemRadius = itemLocs[i].diam/2.;
			itemHeight = itemLocs[i].height;
			
			if ( item_types[item_type].use_normal ) {
				normal = item_types[item_type].normal;
			} else {
				normal = subtract_points( eye_pt, itemLocs[i].ray.pt );
				normalize_vector( &normal );
			}
			
			if (normal.y == 1.0) {
				continue;
			}
			
			glNormal3f( normal.x, normal.y, normal.z );
			
			normal.y = 0.0;
			normalize_vector( &normal );
			
#ifdef __APPLE__
			glScalef(itemRadius*normal.z, itemHeight, itemRadius*normal.x);
			glDrawArrays(GL_TRIANGLES, 0, 6);
#else
			
			glBegin( GL_QUADS );
			{
				glTexCoord2f( 0., 0. );
				glVertex3f( -itemRadius*normal.z, 
						   0.0, 
						   itemRadius*normal.x );
				glTexCoord2f( 1., 0. );
				glVertex3f( itemRadius*normal.z, 
						   0.0, 
						   -itemRadius*normal.x );
				glTexCoord2f( 1., 1. );
				glVertex3f( itemRadius*normal.z, 
						   itemHeight, 
						   -itemRadius*normal.x );
				glTexCoord2f( 0., 1. );
				glVertex3f( -itemRadius*normal.z, 
						   itemHeight, 
						   itemRadius*normal.x );
			}
			glEnd();
#endif
		}
		glPopMatrix();
	} 
	
#ifdef __APPLE__
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
#endif
} 

/*! 
 Draws a fog plane at the far clipping plane to mask out clipping of terrain.
 
 \return  none
 \author  jfpatry
 \date    Created:  2000-08-31
 \date    Modified: 2000-08-31
 */
void draw_fog_plane()
{
	plane_t left_edge_plane, right_edge_plane;
	plane_t left_clip_plane, right_clip_plane;
	plane_t far_clip_plane;
	plane_t bottom_clip_plane;
	plane_t bottom_plane, top_plane;
	
	scalar_t course_width, course_length;
	scalar_t course_angle, slope;
	
	point_t left_pt, right_pt, pt;
	point_t top_left_pt, top_right_pt;
	point_t bottom_left_pt, bottom_right_pt;
	vector_t left_vec, right_vec;
	scalar_t height;
	
	GLfloat *fog_colour;
	
	if ( is_fog_on() == False ) {
		return;
	}
	
	set_gl_options( FOG_PLANE );
	
	get_course_dimensions( &course_width, &course_length );
	course_angle = get_course_angle();
	slope = tan( ANGLES_TO_RADIANS( course_angle ) );
	
	left_edge_plane = make_plane( 1.0, 0.0, 0.0, 0.0 );
	
	right_edge_plane = make_plane( -1.0, 0.0, 0.0, course_width );
	
	far_clip_plane = get_far_clip_plane();
	left_clip_plane = get_left_clip_plane();
	right_clip_plane = get_right_clip_plane();
	bottom_clip_plane = get_bottom_clip_plane();
	
	
	/* Find the bottom plane */
	bottom_plane.nml = make_vector( 0.0, 1, -slope );
	height = get_terrain_base_height( 0 );
	
	/* Unoptimized version
	 pt = make_point( 0, height, 0 );
	 bottom_plane.d = -( pt.x * bottom_plane.nml.x +
	 pt.y * bottom_plane.nml.y +
	 pt.z * bottom_plane.nml.z );
	 */
	bottom_plane.d = -height * bottom_plane.nml.y;
	
	/* Find the top plane */
	top_plane.nml = bottom_plane.nml;
	height = get_terrain_max_height( 0 );
	top_plane.d = -height * top_plane.nml.y;
	
	
	if(get_player_data(local_player())->view.mode == TUXEYE)
	{
		bottom_clip_plane.nml = make_vector( 0.0, 1, -slope );
		height = get_terrain_base_height( 0 ) - 40;
		bottom_clip_plane.d = -height * bottom_clip_plane.nml.y;
	}
	
	/* Now find the bottom left and right points of the fog plane */
	if ( !intersect_planes( bottom_plane, far_clip_plane, left_clip_plane, &left_pt ) )
		return;
	
	if ( !intersect_planes( bottom_plane, far_clip_plane, right_clip_plane, &right_pt ) )
		return;
	
	if ( !intersect_planes( top_plane, far_clip_plane, left_clip_plane, &top_left_pt ) )
		return;
	
	if ( !intersect_planes( top_plane, far_clip_plane, right_clip_plane, &top_right_pt ) )
		return;
	
	if ( !intersect_planes( bottom_clip_plane, far_clip_plane, left_clip_plane, &bottom_left_pt ) )
		return;
	
	if ( !intersect_planes( bottom_clip_plane, far_clip_plane, right_clip_plane, &bottom_right_pt ) )
		return;
	
	left_vec = subtract_points( top_left_pt, left_pt );
	right_vec = subtract_points( top_right_pt, right_pt );
	
	
	/* Now draw the fog plane */
	
	set_gl_options( FOG_PLANE );
	
	fog_colour = get_fog_colour();
	
	glColor4fv( fog_colour );
	
#ifdef __APPLE__DISABLED__
#undef glEnableClientState
#undef glDisableClientState
#undef glVertexPointer
#undef glColorPointer
#undef glDrawArrays
	
	point_t pt1,pt2,pt3,pt4;
	
	pt1 = move_point( top_left_pt, left_vec );
	pt2 = move_point( top_right_pt, right_vec );
	pt3 = move_point( top_left_pt, scale_vector( 3.0, left_vec ) );
	pt4 = move_point( top_right_pt, scale_vector( 3.0, right_vec ) );
	
	const GLfloat verticesFog []=
	{
		bottom_left_pt.x, bottom_left_pt.y, bottom_left_pt.z,
		bottom_right_pt.x, bottom_right_pt.y, bottom_right_pt.z,
		left_pt.x, left_pt.y, left_pt.z,
		right_pt.x, right_pt.y, right_pt.z,
		
		top_left_pt.x, top_left_pt.y, top_left_pt.z,
		top_right_pt.x, top_right_pt.y, top_right_pt.z,
		
		pt1.x, pt1.y, pt1.z,
		pt2.x, pt2.y, pt2.z,
		pt3.x, pt3.y, pt3.z,
		pt4.x, pt4.y, pt4.z	
	};
	
	const GLfloat colorsFog []=
	{
		fog_colour[0], fog_colour[1], fog_colour[2], fog_colour[3],
		fog_colour[0], fog_colour[1], fog_colour[2], fog_colour[3],
		fog_colour[0], fog_colour[1], fog_colour[2], fog_colour[3],
		fog_colour[0], fog_colour[1], fog_colour[2], fog_colour[3],
		fog_colour[0], fog_colour[1], fog_colour[2], 0.9 ,
		fog_colour[0], fog_colour[1], fog_colour[2], 0.9 ,
		fog_colour[0], fog_colour[1], fog_colour[2], 0.3 ,
		fog_colour[0], fog_colour[1], fog_colour[2], 0.3 ,
		fog_colour[0], fog_colour[1], fog_colour[2], 0.0 ,
		fog_colour[0], fog_colour[1], fog_colour[2], 0.0 ,	
	};
	
	glEnableClientState (GL_VERTEX_ARRAY);
	//   glEnableClientState (GL_COLOR_ARRAY);
	//  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer (3, GL_FLOAT , 0, verticesFog);	
	glColorPointer(4, GL_FLOAT, 0, colorsFog);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 10);
	//glDisableClientState(GL_COLOR_ARRAY_POINTER);
	
#else
	glBegin( GL_QUAD_STRIP );
	
	glVertex3f( bottom_left_pt.x, bottom_left_pt.y, bottom_left_pt.z );
	glVertex3f( bottom_right_pt.x, bottom_right_pt.y, bottom_right_pt.z );
	glVertex3f( left_pt.x, left_pt.y, left_pt.z );
	glVertex3f( right_pt.x, right_pt.y, right_pt.z );
	
	glColor4f( fog_colour[0], fog_colour[1], fog_colour[2], 0.9 );
	glVertex3f( top_left_pt.x, top_left_pt.y, top_left_pt.z );
	glVertex3f( top_right_pt.x, top_right_pt.y, top_right_pt.z );
	
	glColor4f( fog_colour[0], fog_colour[1], fog_colour[2], 0.3 );
	pt = move_point( top_left_pt, left_vec );
	glVertex3f( pt.x, pt.y, pt.z );
	pt = move_point( top_right_pt, right_vec );
	glVertex3f( pt.x, pt.y, pt.z );
	
	glColor4f( fog_colour[0], fog_colour[1], fog_colour[2], 0.0 );
	pt = move_point( top_left_pt, scale_vector( 3.0, left_vec ) );
	glVertex3f( pt.x, pt.y, pt.z );
	pt = move_point( top_right_pt, scale_vector( 3.0, right_vec ) );
	glVertex3f( pt.x, pt.y, pt.z );
	
	glEnd();
	
#endif
}

void course_render_init() {
	
	free(treeLocsOrderedByZ);
	
	tree_t* treeLocs = get_tree_locs();
	int numTrees = get_num_trees();
	treeLocsOrderedByZ = (tree_t*)malloc(sizeof(tree_t)*numTrees);
	memcpy(treeLocsOrderedByZ,treeLocs,sizeof(tree_t)*numTrees);
	order_trees_by_z(treeLocsOrderedByZ,numTrees);
	first_tree_to_check=0;
	itemLocs = get_item_locs();
	numItems = get_num_items();
	int i;
	for (i=0;i<numItems;i++) {
		if (itemLocs[i].item_type == kStartType) {
			char* name = get_item_name(itemLocs[i].item_type);
			TRDebugLog("item name : %s, itemType = %d coord x = %f et coord y = %f\n",name, itemLocs[i].item_type,itemLocs[i].ray.pt.x,itemLocs[i].ray.pt.y);	
		}	
	}
}
