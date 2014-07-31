import std.stdio;
import std.conv;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import Mesh;
import Camera;
import Shader;

import std.c.stdio : fputs, fputc, stderr;
import Maths;

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

	Mesh mesh = Mesh.Mesh.CreateCube();
	Camera camera = new Camera(640, 480);
	Shader shader = new Shader("data/specular.glsl");
	shader.SetParameter("world", mat4.identity);
	shader.Bind();

	//Enable culling and depth
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	glEnable(GL_DEPTH_TEST);

	while (!glfwWindowShouldClose(window))
	{
		glClearColor(0.0, 0.2, 0.8, 1.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
			camera.Move(0.1f, 0.0f);
		if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
			camera.Move(-0.1f, 0.0f);
		if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
			camera.Move(0.0f, 0.1f);
		if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
			camera.Move(0.0f, -0.1f);

		if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
			camera.Look(0.1f, 0.0f);
		if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS)
			camera.Look(-0.1f, 0.0f);
		if (glfwGetKey(window, GLFW_KEY_R) == GLFW_PRESS)
			camera.Look(0.0f, 0.1f);
		if (glfwGetKey(window, GLFW_KEY_F) == GLFW_PRESS)
			camera.Look(0.0f, -0.1f);

		shader.SetParameter("viewProj", camera.viewProj);

		shader.SetParameter("world", mat4.translate(vec3(2.0f, 0.0f, 0.0f)));
		mesh.Draw();

		shader.SetParameter("world", mat4.translate(vec3(-2.0f, 0.0f, 0.0f)));
		mesh.Draw();

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwDestroyWindow(window);
	glfwTerminate();
}
