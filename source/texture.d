module meld.texture;

import derelict.opengl3.gl3;
import std.string;
import stb_image;

class Texture
{
	GLuint m_texture = 0;

	this(int width, int height, void* pixels)
	{
		glGenTextures(1, &m_texture);
		glBindTexture(GL_TEXTURE_2D, m_texture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	this(string imageFile)
	{
		int w, h, n;
		stbi_uc* data = stbi_load(imageFile.toStringz, &w, &h, &n, 4);
		this(w, h, data);
	}

	~this()
	{
		if (m_texture != 0)
			glDeleteTextures(1, &m_texture);
	}
}
