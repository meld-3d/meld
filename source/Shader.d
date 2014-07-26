/*#include "stdafx.h"
#include "Shader.h"
#include "Texture.h"
#include <fstream>
#include <sstream>
#include <stdexcept>

using namespace std;

GLuint s_currentShader = (GLuint)-1;
std::vector<ShaderPtr> Shader::m_shaders;

Shader::Shader(const char* vertexShaderfile, const char* pixelShaderFile) :
	m_vertexShaderFile(vertexShaderfile),
	m_pixelShaderFile(pixelShaderFile)
{
	HR(m_program = glCreateProgram());
	m_pixelShader = 0;
	m_vertexShader = 0;
}

Shader::~Shader()
{
}

std::string Shader::LoadFile( const char* fileName )
{
	std::ifstream file(fileName);
	if(!file.is_open())
	{
		PrintError("Failed to open:");
		PrintError(fileName);
		throw new std::runtime_error("Failed to open");
	}

	std::stringstream fileData;
	fileData << file.rdbuf();
	file.close();

	return fileData.str();
}

void Shader::Preprocess(string& shader)
{
	static const string searchStr = "pragma include ";
	size_t found = shader.find(searchStr);

	while (found != string::npos)
	{
		size_t endLine = shader.find('\n', found);
		if (endLine != string::npos)
		{
			found += searchStr.size();
			std::string fileName = shader.substr(found, endLine - found);
			std::string contents = LoadFile(fileName.c_str());
			shader.insert(endLine + 1, contents);
		}
		found = shader.find("pragma include ", found);
	}
}

bool Shader::LoadAndCompile( const char* shaderFile, Type::Enum type )
{
	//Open the file
	std::string shaderSource = LoadFile(shaderFile);
	Preprocess(shaderSource);
	const char* source = shaderSource.c_str();

	//Create and load the shader
	GLuint shader = 0;
	switch (type)
	{
	default:
	case Type::Vertex:
		if (!m_vertexShader)
		{
			HR(m_vertexShader = glCreateShader(GL_VERTEX_SHADER));
		}
		shader = m_vertexShader;
		break;
	case Type::Pixel:
		if (!m_pixelShader)
		{
			HR(m_pixelShader = glCreateShader(GL_FRAGMENT_SHADER));
		}
		shader = m_pixelShader;
		break;
	}

	//Attach source and compile
	int len = shaderSource.length();
	HR(glShaderSource(shader, 1, (const GLchar**)&source, &len));
	HR(glCompileShader(shader));

	//Did we compile ok?
	GLint compiled;
	HR(glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled));
	if (compiled)
	{
		HR(glAttachShader(m_program, shader));

		HR(glBindAttribLocation(m_program, 0, "inVertex"));
		HR(glBindAttribLocation(m_program, 1, "inNormal"));
		HR(glBindAttribLocation(m_program, 2, "inTex"));

		return true;
	}
	else
	{
		PrintError("Shader Compilation Failed!");
		PrintError(shaderFile);
		PrintLog(shader);
        throw new std::runtime_error("Shader compilation failed");
	}
}

void Shader::PrintLog(GLint shader)
{
	GLint logLength;
	GLsizei actualLogLength = 0;
	HR(glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength));
	if (logLength > 1)
	{
		PrintError("Compile Log:");
		GLchar* compilerLog = new GLchar[logLength];
		HR(glGetShaderInfoLog(shader, logLength, &actualLogLength, compilerLog));//(&shader, logLength, &actualLogLength, compilerLog));

		PrintError(compilerLog);

		delete[] compilerLog;
	}
}

void Shader::PrintProgramLog(GLint program)
{
    GLint logLength;
    GLsizei actualLogLength = 0;
    HR(glGetShaderiv(program, GL_INFO_LOG_LENGTH, &logLength));
    if (logLength > 0)
    {
        PrintError("Link Log:");
        GLchar* compilerLog = new GLchar[logLength];
        HR(glGetProgramInfoLog(program, logLength, &actualLogLength, compilerLog));
        
        PrintError(compilerLog);
        delete[] compilerLog;
    }
}

bool Shader::Link()
{
	HR(glLinkProgram(m_program));

	//Did we link ok?
	GLint linked;
	HR(glGetProgramiv(m_program, GL_LINK_STATUS, &linked));
	if (linked)
	{
		return true;
	}
	else
	{
		PrintError("Failed to link shader!");
		PrintProgramLog(m_program);
		return false;
	}
}

void Shader::Bind()
{
	if (s_currentShader != m_program)
	{
		s_currentShader = m_program;
		HR(glUseProgram(m_program));
	}
}

bool Shader::Load()
{
	if (LoadAndCompile(m_vertexShaderFile, Type::Vertex) && LoadAndCompile(m_pixelShaderFile, Type::Pixel) && Link())
	{
		Bind();
		//Reset textures
		for (std::map<std::string, std::pair<size_t, TexturePtr> >::iterator iter = m_textures.begin(); iter != m_textures.end(); ++iter)
		{
			GLint loc = glGetUniformLocation(m_program, iter->first.c_str());
			GLint tu = (GLint)iter->second.first;
			HR(glUniform1i(loc, tu));
		}

		return true;
	}
	else
	{
		return false;
	}
}

void Shader::SetParameter( const char* paramName, glm::mat4x4& matrix )
{
	HR(glUniformMatrix4fv(glGetUniformLocation(m_program, paramName), 1, GL_FALSE, glm::value_ptr(matrix)));
}

void Shader::SetParameter( const char* paramName, glm::vec4& vector )
{
	HR(glUniform4fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector)));
}

void Shader::SetParameter( const char* paramName, glm::vec3& vector )
{
	HR(glUniform3fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector)));
}

void Shader::SetParameter( const char* paramName, glm::vec2& vector )
{
	HR(glUniform2fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector)));
}

void Shader::SetParameter( const char* paramName, TexturePtr texture )
{
	Bind();

	if (texture.valid())
	{
		std::map<std::string, std::pair<size_t, TexturePtr> >::iterator find = m_textures.find(paramName);
		size_t texUnit;
		if (find == m_textures.end())
		{
			texUnit = m_textures.size()*2;
			m_textures.insert(std::make_pair(paramName,std::make_pair(texUnit, texture)));

			GLint loc = glGetUniformLocation(m_program, paramName);
			GLint tu = texUnit;
			HR(glUniform1i(loc, tu));
		}
		else
		{
			texUnit = find->second.first;
			find->second.second = texture;
		}

		HR(glActiveTexture(GL_TEXTURE0 + texUnit));
		HR(glBindTexture(GL_TEXTURE_2D, texture->m_texture));
	}
}

void Shader::SetParameter( const char* paramName, GLuint value )
{
	HR(glUniform1i(glGetUniformLocation(m_program, paramName), value));
}

void Shader::SetParameter( const char* paramName, float value )
{
	HR(glUniform1f(glGetUniformLocation(m_program, paramName), value));
}*/
