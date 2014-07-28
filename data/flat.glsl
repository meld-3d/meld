#pragma vertex
#version 330

in vec3 inVertex;
in vec2 inTex;
out vec2 Tex;

void main(void)
{
	Tex = inTex;
	gl_Position = vec4(inVertex.xzy, 1.0f);
}

#pragma fragment
#version 330

out vec4 FragColor;
in vec2 Tex;
uniform float bloom;

void main(void)
{
	FragColor = vec4(Tex.x, Tex.y, 0.0f, 1.0f);
}
