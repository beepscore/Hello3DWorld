
/*
 *  template.mm
 *  template
 *
 *  Created by SIO2 Interactive on 8/22/08.
 *  Copyright 2008 SIO2 Interactive. All rights reserved.
 *
 */

#include "template.h"

// #include "../src/sio2/sio2.h"
#include "sio2.h"

float spin_factor = 0.0;
unsigned char message = 0;
unsigned char tap_select = 0;

SIO2font *_SIO2font_default = NULL;
SIO2object *selection = NULL;

vec2 t;

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
	
	SIO2image		*_SIO2image		= NULL;
	SIO2material	*_SIO2material	= NULL;
	SIO2stream		*_SIO2stream	= NULL;
	
	_SIO2stream = sio2StreamOpen( "default16x16.tga", 1 );
	
	if( _SIO2stream )
	{
		_SIO2image = sio2ImageInit( "default16x16.tga" );
		
		{
			sio2ImageLoad(	_SIO2image, _SIO2stream );
			sio2ImageGenId( _SIO2image, NULL, 0.0f );
		}
		_SIO2stream = sio2StreamClose( _SIO2stream );
		
		_SIO2material = sio2MaterialInit( "default16x16" );
        
		{
			_SIO2material->blend = SIO2_MATERIAL_COLOR;
			_SIO2material->_SIO2image[ SIO2_MATERIAL_CHANNEL0 ] = _SIO2image;
		}
        
		_SIO2font_default = sio2FontInit( "default16x16" );
        
		_SIO2font_default->_SIO2material = _SIO2material;
		_SIO2font_default->n_char		= 16;
		_SIO2font_default->size			= 16.0f;
		_SIO2font_default->space		= 8.0f;
		sio2FontBuild( _SIO2font_default );
	}
    
	sio2->_SIO2camera = sio2ResourceGetCamera( sio2->_SIO2resource, 
                                              "camera/Camera");
    
	sio2Perspective( sio2->_SIO2camera->fov,
                    sio2->_SIO2window->scl->x / sio2->_SIO2window->scl->y,
                    sio2->_SIO2camera->cstart,
                    sio2->_SIO2camera->cend );
	
	sio2->_SIO2window->_SIO2windowrender = templateRender;
}


void templateRender( void )
{
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
	
	static SIO2object *earth = sio2ResourceGetObject( sio2->_SIO2resource,
                                                     "object/Sphere" );	
	
	if( earth )
	{
		earth->_SIO2transform->rot->z += (spin_factor * 0.05f );
		sio2TransformBindMatrix( earth->_SIO2transform );
	}
    
    
	if( spin_factor > 0.0f )
	{ spin_factor -= 1.0f; }
    
	else if(spin_factor < 0.0f )
	{ spin_factor += 1.0f; }
    
	sio2LampEnableLight();
    
	sio2CameraRender( sio2->_SIO2camera );
	sio2ResourceRender( sio2->_SIO2resource, 
                       sio2->_SIO2window, 
                       sio2->_SIO2camera, 		   
					   SIO2_RENDER_SOLID_OBJECT | SIO2_RENDER_LAMP);
    
	sio2LampResetLight();
    
	if(tap_select){
		tap_select = 0;
		sio2MaterialReset();
		
		t.x = sio2->_SIO2window->touch[ 0 ]->x;
		t.y = sio2->_SIO2window->scl->y -sio2->_SIO2window->touch[ 0 ]->y;
		
		selection = sio2ResourceSelect3D( sio2->_SIO2resource, 
										 sio2->_SIO2camera, 
										 sio2->_SIO2window, 
										 &t);
		if(selection){
			if(strcmp( selection->name, "object/Sphere" ) == 0)
			{
				message = 2;
			}else{
				message = 1;
			}
		}else{
			message = 1;
		}
	}

    
    // font rendering code
	sio2WindowEnter2D( sio2->_SIO2window, 0.0f, 1.0f );
    // ????: c allows extra braces?
	{			
		_SIO2font_default->_SIO2transform->loc->x = 100.0f;
		_SIO2font_default->_SIO2transform->loc->y = 420.0f;
		switch( message )
		{
			case 1:
			{
                // set material color to white
                _SIO2font_default->_SIO2material->diffuse->x = 1.0f;
				_SIO2font_default->_SIO2material->diffuse->y = 1.0f;
				_SIO2font_default->_SIO2material->diffuse->z = 1.0f;
				_SIO2font_default->_SIO2material->diffuse->w = 1.0f;
                
				sio2FontPrint( _SIO2font_default, SIO2_TRANSFORM_MATRIX_APPLY, "Hello 3D Space!" );
				
				break;
			}
                
			case 2:
			{
                // set material color to green
				_SIO2font_default->_SIO2material->diffuse->x = 0.5f;
				_SIO2font_default->_SIO2material->diffuse->y = 1.0f;
				_SIO2font_default->_SIO2material->diffuse->z = 0.0f;
				_SIO2font_default->_SIO2material->diffuse->w = 1.0f;
                
				sio2FontPrint( _SIO2font_default, SIO2_TRANSFORM_MATRIX_APPLY, "Hello 3D World!" );
                
				break;
			}
		}
		sio2MaterialReset();
		sio2FontReset();
		if( sio2->_SIO2window->n_touch )
		{
			_SIO2font_default->_SIO2transform->loc->y = 24.0f;
			_SIO2font_default->_SIO2transform->loc->x = 80.0f;
			_SIO2font_default->_SIO2material->diffuse->x = 1.0f;
			_SIO2font_default->_SIO2material->diffuse->y = 0.2f;
			_SIO2font_default->_SIO2material->diffuse->z = 0.0f;
			_SIO2font_default->_SIO2material->diffuse->w = 1.0f;
			
			unsigned int j = 0;
			while( j != sio2->_SIO2window->n_touch )
			{
				sio2FontPrint( _SIO2font_default,
							  SIO2_TRANSFORM_MATRIX_APPLY,
							  "Touch #%d X:%.0f Y:%.0f",
							  j,
							  sio2->_SIO2window->touch[ j ]->x,
							  sio2->_SIO2window->touch[ j ]->y );
				printf("r:%f g:%f b:%f\n", 				
					   _SIO2font_default->_SIO2material->diffuse->x ,
					   _SIO2font_default->_SIO2material->diffuse->y ,
					   _SIO2font_default->_SIO2material->diffuse->z );
				
				_SIO2font_default->_SIO2transform->loc->y += 20.0f;
				++j;
			}
            
			sio2MaterialReset();
		}
		sio2FontReset();
	}
	sio2WindowLeave2D();
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


vec2 start;

void templateScreenTap( void *_ptr, unsigned char _state )
{
    
	if( _state == SIO2_WINDOW_TAP_DOWN ){
		start.x = sio2->_SIO2window->touch[ 0 ]->x;
		start.y = sio2->_SIO2window->touch[ 0 ]->y;
		if( sio2->_SIO2window->n_tap == 2)
		{
			tap_select = 1;
		}
	}
}

void templateScreenTouchMove( void *_ptr )
{
	if( sio2->_SIO2window->n_touch )
	{
		spin_factor = sio2->_SIO2window->touch[ 0 ]->x - start.x;
	}
    
}

void templateScreenAccelerometer( void *_ptr )
{    
    
}
