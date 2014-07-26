/*#include "Texture.h"
#include "stb_image.h"
#include <stdexcept>

Texture::Texture() :
	m_texture(0)
{
	HR(glGenTextures(1, &m_texture));
}

Texture::~Texture()
{
	if (m_texture)
	{
		HR(glDeleteTextures(1, &m_texture));
	}
}

void Texture::Create( int width, int height, void* pixels )
{
	HR(glBindTexture(GL_TEXTURE_2D, m_texture));
	HR(glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels ));
	HR(glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST ));
	HR(glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST ));
	HR(glBindTexture(GL_TEXTURE_2D, 0));
}

struct color
{
	char r, g, b, a;
};

TexturePtr Texture::CreateFromShader( TextureShaderCallback shader, int width, int height )
{
	TexturePtr texture = TexturePtr(new Texture());
	
	int numPixels = width * height;
	float widthf = static_cast<float>(width);
	float heightf = static_cast<float>(height);
	color* pixels = new color[numPixels];
	float r, g, b;
	for (int i = 0; i<numPixels; ++i)
	{
		float x = static_cast<float>(i%width)/widthf;
		float y = static_cast<float>(i/width)/heightf;
		
		shader(r, g, b, x, y);

		color col =
		{
			(char)(r*255.0f), (char)(g*255.0f), (char)(b*255.0f), (char)255
		};
		pixels[i] = col;
	}

	texture->Create(width, height, pixels);

	delete[] pixels;
	return texture;
}

TexturePtr Texture::Load( const char* filename )
{
	int w,h,n;
	unsigned char *data = stbi_load(filename, &w, &h, &n, 4);
	
	if (data != NULL)
	{
		TexturePtr ptr(new Texture());
		ptr->Create(w, h, data);
		return ptr;
	}
	else
	{
		return TexturePtr();
	}
}*/
