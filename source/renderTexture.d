/*#include "glwt.h"
#include "RenderTexture.h"
#include "Texture.h"

int RenderTexture::RestoreWidth = 0, RenderTexture::RestoreHeight = 0;

RenderTexture::RenderTexture( int width, int height ) :
	m_width(width), m_height(height), m_texture(TexturePtr(new Texture()))
{
	//Create the framebuffer object
    GL::GenFramebuffers(1, &m_frameBuffer);
    GL::BindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);
	
	//Create and attach a depth buffer
    GL::GenRenderbuffers(1, &m_depthBuffer);
    GL::BindRenderbuffer(GL_RENDERBUFFER, m_depthBuffer);
    GL::RenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);
    GL::FramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthBuffer);

	//Create and attach render texture
    GL::GenTextures(1, &m_texture->m_texture);
    GL::BindTexture(GL_TEXTURE_2D, m_texture->m_texture);
    GL::TexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    GL::FramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_texture->m_texture, 0);
	GL::TexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	GL::TexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	GL::TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	GL::TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	//Ensure the framebuffer generated correctly!
	GL::CheckFramebufferStatus();

	GL::BindFramebuffer(GL_FRAMEBUFFER, 0);
}

RenderTexture::~RenderTexture()
{
    GL::DeleteFramebuffers(1, &m_frameBuffer);
    GL::DeleteRenderbuffers(1, &m_depthBuffer);
}

void RenderTexture::Bind()
{
    GL::BindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);
    GL::Viewport(0, 0, m_width, m_height);
}

void RenderTexture::Complete()
{
    GL::BindFramebuffer(GL_FRAMEBUFFER, 0);
    GL::Viewport(0, 0, RestoreWidth, RestoreHeight);
}

TexturePtr RenderTexture::GetTexture()
{
	return m_texture;
}
*/