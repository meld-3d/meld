meld
====

A tiny game engine for D with as few dependencies as possible.

Windows compilation requires dmc, dmd and dub. OSX compilation requires gcc, dmd and dub. You will also need to have the glwt library available. To create a new project:

	dub init helloworld
	
Add meld to the project dependencies:

	{
		"name": "hello world",
		"description": "HELLO, world!",
		"copyright": "Copyright © 2014, Alex Parker",
		"authors": ["Alex Parker"],
		"dependencies": {
			"meld": {
				"version": "~master"
			}
		}
	}
	
Import and initialise meld in your main loop:

	import meld;

	void main()
	{
		Window window = new Window("Hello, world!", 640, 480);
		
		while (window.IsRunning())
		{
			window.Swap();
		}
	}
