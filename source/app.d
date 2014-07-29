import std.stdio;
import std.conv;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import Mesh;
import Camera;
import Shader;

import std.c.stdio : fputs, fputc, stderr;

extern(C) nothrow void glfwPrintError(int error, const(char)* description) {
  fputs(description, stderr);
  fputc('\n', stderr);
}

void main()
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

	GLFWwindow* window = glfwCreateWindow(640, 480, "Hello World", null, null);

	glfwMakeContextCurrent(window);

	DerelictGL3.reload();

	writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
	writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
	writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
	writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));

	Mesh mesh = Mesh.Mesh.CreatePlane(10.0f, 10.0f);
	Camera camera = new Camera(640, 480);
	Shader shader = new Shader("data/flat.glsl");
	shader.SetParameter("Texture", new Texture("data/background.jpg"));
	shader.Bind();

	while (!glfwWindowShouldClose(window))
	{
		glClearColor(0.0, 0.2, 0.8, 1.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		mesh.Draw();

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwDestroyWindow(window);
	glfwTerminate();
}
