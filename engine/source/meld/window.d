module meld.window;

import std.stdio;
import std.conv;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import core.thread;
import meld;
import std.string;

import meld.fileWatcher;

import std.c.stdio : fputs, fputc, stderr;

extern(C) nothrow void glfwPrintError(int error, const(char)* description) {
  fputs(description, stderr);
  fputc('\n', stderr);
}

class Window
{
package:
	static GLFWwindow* m_window;

public:
	this(string name, int width, int height)
	{
		DerelictGL3.load();
		DerelictGLFW3.load();

		glfwSetErrorCallback(&glfwPrintError);
		if (!glfwInit())
		{
			glfwTerminate();
			throw new Exception("Failed to create gl context");
		}

		glfwWindowHint(GLFW_SAMPLES, 4);
		glfwWindowHint(GLFW_RESIZABLE, GL_TRUE);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

		m_window = glfwCreateWindow(width, height, name.toStringz, null, null);

		glfwMakeContextCurrent(m_window);

		DerelictGL3.reload();

		writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
		writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
		writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
		writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));

		//Enable culling and depth
		glEnable(GL_CULL_FACE);
		glCullFace(GL_FRONT);
		glEnable(GL_DEPTH_TEST);
	}

	bool IsRunning()
	{
		if (glfwWindowShouldClose(m_window))
		{
			glfwDestroyWindow(m_window);
			glfwTerminate();
			return false;
		}

		return true;
	}

	void Swap()
	{
		glfwSwapBuffers(m_window);
		glfwPollEvents();

		FileWatcher.Update();
	}

	double Time()
	{
		return glfwGetTime();
	}
}