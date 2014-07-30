#pragma vertex
#version 330

in vec3 inVertex;
in vec3 inNormal;

out vec3 Normal;
out vec3 WorldPos;

uniform mat4 world;
uniform mat4 viewProj;

void main(void)
{
	Normal = inNormal;
	gl_Position = viewProj * world * vec4(inVertex, 1.0);
}

#pragma fragment
#version 330

out vec4 FragColor;
in vec3 Normal;
in vec3 WorldPos;

uniform vec3 camPos;
uniform vec3 ambientColor, lightColor;
uniform float specAmount;

void main(void)
{
	/*vec3 normal = normalize(Normal);
	vec3 camView = normalize(camPos - WorldPos);
	float diffuse = clamp(normal.x, 0.0f, 1.0f);
	vec3 h = normalize(vec3(1.0f, 0.0f, 0.0f) + camView);
	float spec = max(pow(dot(h, normal), specAmount), 0.0f);*/

	float light = dot(Normal, normalize(vec3(0.5,0.5,0.5)));
	FragColor = vec4(light, light, light, 1.0);//vec4(ambientColor + diffuse * lightColor + vec3(spec, spec, spec), 1.0f);
}
