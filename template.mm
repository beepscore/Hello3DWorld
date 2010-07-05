/*
 *  template.mm
 *  template
 *
 *  Created by SIO2 Interactive on 8/22/08.
 *  Copyright 2008 SIO2 Interactive. All rights reserved.
 *
 */

#include "template.h"

// beepscore
// #include "../src/sio2/sio2.h"
#include "sio2.h"

float spin_factor = 0.0;
vec2 start;


void templateLoading ( void )
{
	unsigned int i = 0;
	
	sio2ResourceCreateDictionary( sio2->_SIO2resource );
	
	sio2ResourceOpen( sio2->_SIO2resource, 
					 "Hello3DWorld.sio2", 1);
	
	while( i != sio2->_SIO2resource->gi.number_entry )
	{
		sio2ResourceExtract( sio2->_SIO2resource, NULL );
		++i;
	}
	
	sio2ResourceClose( sio2->_SIO2resource );
	sio2ResourceBindAllImages( sio2->_SIO2resource );
	sio2ResourceBindAllMaterials( sio2->_SIO2resource );
	sio2ResourceBindAllMatrix( sio2->_SIO2resource );
	sio2ResourceGenId( sio2->_SIO2resource );
	sio2ResetState();
	
	sio2->_SIO2window->_SIO2windowrender = templateRender;
	
	sio2->_SIO2camera = sio2ResourceGetCamera( sio2->_SIO2resource, 
                                              "camera/Camera");
    
	sio2Perspective( sio2->_SIO2camera->fov,
                    sio2->_SIO2window->scl->x / sio2->_SIO2window->scl->y,
                    sio2->_SIO2camera->cstart,
                    sio2->_SIO2camera->cend );
}


void templateRender( void )
{
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
    
	glClear( GL_DEPTH_BUFFER_BIT );
	
	if( sio2->_SIO2camera )
	{
		static vec4 ambient_color = { 0.1f, 0.1f, 0.1f, 1.0f };
		static SIO2object *earth = sio2ResourceGetObject( sio2->_SIO2resource,
                                                         "object/Sphere" );	
        
		if( earth )
		{
			//earth->_SIO2transform->rot->z += 15.0f*sio2->_SIO2window->d_time;
			earth->_SIO2transform->rot->z += (spin_factor * sio2->_SIO2window->d_time);
            
            
			sio2TransformBindMatrix( earth->_SIO2transform );
		}
		
		
		if( spin_factor > 0.0f )
		{ spin_factor -= 1.0f; }
		
		else if(spin_factor < 0.0f )
		{ spin_factor += 1.0f; }
        
		sio2LampSetAmbient( &ambient_color );
        
		sio2LampEnableLight();
        
		sio2CameraRender( sio2->_SIO2camera );
        
		sio2ResourceRender( sio2->_SIO2resource, 
                           sio2->_SIO2window, 
                           sio2->_SIO2camera, 
                           SIO2_RENDER_SOLID_OBJECT | SIO2_RENDER_LAMP);
        
	}
}


void templateShutdown( void )
{
	// Clean up
	sio2ResourceUnloadAll( sio2->_SIO2resource );

	sio2->_SIO2resource = sio2ResourceFree( sio2->_SIO2resource );

	sio2->_SIO2window = sio2WindowFree( sio2->_SIO2window );
	
	sio2 = sio2Shutdown();
	
	printf("\nSIO2: shutdown...\n" );
}


void templateScreenTap( void *_ptr, unsigned char _state )
{
	if( _state == SIO2_WINDOW_TAP_DOWN )
    {
		start.x = sio2->_SIO2window->touch[ 0 ]->x;
		start.y = sio2->_SIO2window->touch[ 0 ]->y;
	}    
}


void templateScreenTouchMove( void *_ptr )
{
	if( sio2->_SIO2window->n_touch )
	{
		// spin_factor = 2*(sio2->_SIO2window->touch[ 0 ]->x - start.x);
		spin_factor = (sio2->_SIO2window->touch[ 0 ]->x - start.x);
	}
}


void templateScreenAccelerometer( void *_ptr )
{


}

