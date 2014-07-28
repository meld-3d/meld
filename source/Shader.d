import derelict.opengl3.gl3;
import std.string;

class Shader
{
private:
	enum ShaderType
	{
		Vertex,
		Pixel
	}

	Gluint m_program, m_pixelShader = 0, m_vertexShader = 0;

public:
	this(string vertexShaderFile, string pixelShaderFile)
	{
 		m_program = glCreateProgram();
	}

private:
	bool LoadAndCompile( const char* shaderFile, ShaderType shaderType )
	{
		//Open the file
		std::string shaderSource = LoadFile(shaderFile);
		const char* source = shaderSource.c_str();

		//Create and load the shader
		GLuint shader = 0;
		switch (shaderType)
		{
		default:
		case ShaderType.Vertex:
			if (!m_vertexShader)
			{
				m_vertexShader = glCreateShader(GL_VERTEX_SHADER);
			}
			shader = m_vertexShader;
			break;
		case ShaderType.Pixel:
			if (!m_pixelShader)
			{
				m_pixelShader = glCreateShader(GL_FRAGMENT_SHADER);
			}
			shader = m_pixelShader;
			break;
		}

		//Attach source and compile
		int len = shaderSource.length();
		glShaderSource(shader, 1, (const GLchar**)&source, &len);
		glCompileShader(shader);

		//Did we compile ok?
		GLint compiled;
		glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
		if (compiled)
		{
			glAttachShader(m_program, shader);

			glBindAttribLocation(m_program, 0, "inVertex");
			glBindAttribLocation(m_program, 1, "inNormal");
			glBindAttribLocation(m_program, 2, "inTex");

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

	void PrintLog(GLint shader)
	{
		GLint logLength;
		GLsizei actualLogLength = 0;
		HR(glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength));
		if (logLength > 1)
		{
			PrintError("Compile Log:");
			GLchar* compilerLog = new GLchar[logLength];
			glGetShaderInfoLog(shader, logLength, &actualLogLength, compilerLog);

			PrintError(compilerLog);

			delete[] compilerLog;
		}
	}

	void PrintProgramLog(GLint program)
	{
	    GLint logLength;
	    GLsizei actualLogLength = 0;
	    glGetShaderiv(program, GL_INFO_LOG_LENGTH, &logLength);
	    if (logLength > 0)
	    {
	        PrintError("Link Log:");
	        GLchar* compilerLog = new GLchar[logLength];
	        HR(glGetProgramInfoLog(program, logLength, &actualLogLength, compilerLog));
	        
	        PrintError(compilerLog);
	        delete[] compilerLog;
	    }
	}

	bool Link()
	{
		glLinkProgram(m_program);

		//Did we link ok?
		GLint linked;
		glGetProgramiv(m_program, GL_LINK_STATUS, &linked);
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

public:
	void Bind()
	{
		if (s_currentShader != m_program)
		{
			s_currentShader = m_program;
			glUseProgram(m_program);
		}
	}

	bool Load()
	{
		if (LoadAndCompile(m_vertexShaderFile, ShaderType.Vertex) && LoadAndCompile(m_pixelShaderFile, ShaderType.Pixel) && Link())
		{
			Bind();
			//Reset textures
			/*for (std::map<std::string, std::pair<size_t, TexturePtr> >::iterator iter = m_textures.begin(); iter != m_textures.end(); ++iter)
			{
				GLint loc = glGetUniformLocation(m_program, iter->first.c_str());
				GLint tu = (GLint)iter->second.first;
				HR(glUniform1i(loc, tu));
			}*/

			return true;
		}
		else
		{
			return false;
		}
	}

	void SetParameter( string paramName, ref mat4 matrix )
	{
		glUniformMatrix4fv(glGetUniformLocation(m_program, paramName), 1, GL_FALSE, glm::value_ptr(matrix));
	}

	void SetParameter( string paramName, ref vec4 vector )
	{
		glUniform4fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector));
	}

	void SetParameter( string paramName, ref vec3 vector )
	{
		glUniform3fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector));
	}

	void SetParameter( string paramName, ref vec2 vector )
	{
		glUniform2fv(glGetUniformLocation(m_program, paramName), 1, glm::value_ptr(vector));
	}

	/*void Shader::SetParameter( string paramName, TexturePtr texture )
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
	}*/

	void SetParameter( string paramName, GLuint value )
	{
		glUniform1i(glGetUniformLocation(m_program, paramName), value);
	}

	void SetParameter( string paramName, float value )
	{
		glUniform1f(glGetUniformLocation(m_program, paramName), value);
	}
}

