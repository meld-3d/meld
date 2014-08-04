/*import meld;

void main()
{
	Window window = new Window(640, 480, "Hello, world!");

	Mesh mesh = Mesh.CreateCube();
	Camera camera = new Camera(640, 480);
	Shader shader = new Shader("data/specular.glsl");
	shader.SetParameter("world", mat4.identity);
	shader.Bind();

	double currentTime = window.Time();
	double accumulator = 0.0;
	double dt = 1.0 / 60.0;

	while (!window.IsRunning())
	{
		double newTime = window.Time();
		double frameTime = newTime - currentTime;
		currentTime = newTime;

		accumulator += frameTime;

		while (accumulator >= dt)
		{
			writefln("Ding: %f", dt);

			if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
				camera.Move(dt, 0.0f);
			if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
				camera.Move(-dt, 0.0f);
			if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
				camera.Move(0.0f, dt);
			if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
				camera.Move(0.0f, -dt);

			if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
				camera.Look(dt*2.0, 0.0f);
			if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS)
				camera.Look(-dt*2.0, 0.0f);
			if (glfwGetKey(window, GLFW_KEY_R) == GLFW_PRESS)
				camera.Look(0.0f, dt);
			if (glfwGetKey(window, GLFW_KEY_F) == GLFW_PRESS)
				camera.Look(0.0f, -dt);

			accumulator -= dt;
		}

		glClearColor(0.0, 0.2, 0.8, 1.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		shader.SetParameter("viewProj", camera.viewProj);

		shader.SetParameter("world", mat4.translate(vec3(2.0f, 0.0f, 20.0f)));
		mesh.Draw();

		shader.SetParameter("world", mat4.translate(vec3(-2.0f, 0.0f, 20.0f)));
		mesh.Draw();

		window.Swap();

		double timeLeft = dt - frameTime;
		if (timeLeft > 0.0)
			Thread.sleep(dur!("msecs")( cast(long)(timeLeft * 1000.0) ));
	}

	
}
*/