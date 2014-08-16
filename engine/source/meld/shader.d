module meld.shader;

import derelict.opengl3.gl3;
import std.string;
import std.file;
import std.stdio;
import std.ascii : newline;
import meld.maths;
import meld.texture;
import std.typecons;
import std.conv;

class Shader
{
private:
	enum ShaderType
	{
		None,
		Vertex,
		Pixel
	}

	struct TextureUnit
	{
		this(GLint textureUnit, Texture texture)
		{
			this.textureUnit = textureUnit;
			this.texture = texture;
		}

		GLint textureUnit;
		Texture texture;
	};

	GLuint m_program, m_pixelShader = 0, m_vertexShader = 0;
	static TextureUnit[string] m_textures;
	static GLuint s_currentShader = 0;

public:
	static Shader[string] m_loadedShaders;

	static Shader Find(string glslFile)
	{
		Shader* existing = glslFile in m_loadedShaders;
		if (existing !is null)
			return *existing;

		Shader newShader = new Shader(glslFile);
		m_loadedShaders[glslFile] = newShader;
		return newShader;
	}

package:
	this(string glslFile)
	{
		import meld.fileWatcher : FileWatcher;
		FileWatcher.Watch(glslFile, ()
		{
			writeln("Reloading " ~ glslFile);
			Destroy();
			Load(glslFile);
		});
		Load(glslFile);
	}

	~this()
	{
		Destroy();
	}

private:
	void Destroy()
	{
		glDeleteShader(m_vertexShader);
		glDeleteShader(m_pixelShader);
		glDeleteProgram(m_program);
	}

	void LoadAndCompile( string shaderSource, GLuint shader )
	{
		//Attach source and compile
		int len = cast(int)shaderSource.length;
		const char* source = shaderSource.toStringz();
		glShaderSource(shader, 1, cast(const GLchar**)&source, &len);
		glCompileShader(shader);

		//Did we compile ok?
		GLint compiled;
		glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
		if (!compiled)
			throw new Exception("Shader compilation failed!" ~ newline ~ GetLog(&glGetShaderInfoLog, shader));
		
		glAttachShader(m_program, shader);
		glBindAttribLocation(m_program, 0, "inVertex");
		glBindAttribLocation(m_program, 1, "inNormal");
		glBindAttribLocation(m_program, 2, "inTex");
	}

	static string GetLog(T)(T method, GLint object)
	{
		GLint logLength;
		GLsizei actualLogLength = 0;
		glGetShaderiv(object, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength <= 0)
			return "";

		GLchar[] compilerLog = new GLchar[logLength];
		(*method)(object, logLength, &actualLogLength, cast(char*)compilerLog);

		return to!string(compilerLog);
	}

	void Link()
	{
		glLinkProgram(m_program);

		//Did we link ok?
		GLint linked;
		glGetProgramiv(m_program, GL_LINK_STATUS, &linked);
		if (!linked)
			throw new Exception("Failed to link shader: " ~ GetLog(&glGetProgramInfoLog, m_program));
	}

	void Load(string glslFile)
	{
		auto file = File(glslFile);

		ShaderType mode = ShaderType.None;
		char[] vertexContents, pixelContents;

		foreach (char[] line; file.byLine())
		{
			if (line.startsWith("#pragma vertex"))
				mode = ShaderType.Vertex;
			else if (line.startsWith("#pragma fragment"))
				mode = ShaderType.Pixel;
			else if (mode == ShaderType.Vertex)
				vertexContents ~= line ~ newline;
			else if (mode == ShaderType.Pixel)
				pixelContents ~= line ~ newline;
		}

 		m_program = glCreateProgram();

		LoadAndCompile(cast(string)vertexContents, glCreateShader(GL_VERTEX_SHADER));
		LoadAndCompile(cast(string)pixelContents, glCreateShader(GL_FRAGMENT_SHADER));
		Link();
		Bind();

		//Reset textures
		foreach (string paramName; m_textures.byKey)
		{
			GLint loc = glGetUniformLocation(m_program, paramName.toStringz);
			GLint tu = m_textures[paramName].textureUnit;
			glUniform1i(loc, tu);
		}
	}

package:
	bool Bind()
	{
		if (s_currentShader != m_program)
		{
			s_currentShader = m_program;
			glUseProgram(m_program);
			return true;
		}
		return false;
	}

	void SetParameter( string paramName, mat4 matrix )
	{
		glUniformMatrix4fv(glGetUniformLocation(m_program, paramName.toStringz), 1, GL_TRUE, cast(float*)&matrix);
	}

	void SetParameter( string paramName, vec4 vector )
	{
		glUniform4fv(glGetUniformLocation(m_program, paramName.toStringz), 1, cast(float*)&vector);
	}

	void SetParameter( string paramName, vec3 vector )
	{
		glUniform3fv(glGetUniformLocation(m_program, paramName.toStringz), 1, cast(float*)&vector);
	}

	void SetParameter( string paramName, vec2 vector )
	{
		glUniform2fv(glGetUniformLocation(m_program, paramName.toStringz), 1, cast(float*)&vector);
	}

	void SetParameter( string paramName, Texture texture )
	{
		if (texture.m_texture != 0)
		{
			TextureUnit* textureParam = paramName in m_textures;

			if (textureParam == null)
			{
				m_textures[paramName] = TextureUnit(cast(GLint)m_textures.length * 2, texture);
				textureParam = &m_textures[paramName];

				GLint loc = glGetUniformLocation(m_program, paramName.toStringz);
				glUniform1i(loc, textureParam.textureUnit);
			}
			else
				textureParam.texture = texture;

			glActiveTexture(GL_TEXTURE0 + textureParam.textureUnit);
			glBindTexture(GL_TEXTURE_2D, textureParam.texture.m_texture);
		}
	}

	void SetParameter( string paramName, GLuint value )
	{
		glUniform1i(glGetUniformLocation(m_program, paramName.toStringz), value);
	}

	void SetParameter( string paramName, float value )
	{
		glUniform1f(glGetUniformLocation(m_program, paramName.toStringz), value);
	}
}

