import Maths;
import std.math;
import std.stdio;
import std.conv;

class Camera
{
private:
	vec2 m_rot = vec2(0.0f, 0.0f);
	vec3 m_pos = vec3(0.0f, -2.0f, 10.0f), m_fwd = vec3(0.0f, 0.0f, 1.0f);
	mat4 m_viewProj, m_proj;
	bool m_dirty = true;

public:
	@property mat4 viewProj()
	{
		//Only recalculate view*proj if it changed.
		if (m_dirty)
		{
			mat4 view = 
				mat4.translate(-m_pos) *
				mat4.axisangle(vec3(0.0f, 1.0f, 0.0f), -m_rot.y) *
				mat4.axisangle(vec3(1.0f, 0.0f, 0.0f), -m_rot.x); 
				
			//m_fwd = cast(vec3)(view * vec4(0.0f, 0.0f, 1.0f, 1.0f)) - m_pos;
			//writeln(to!string(m_fwd));
			//m_fwd = vec3(0.0f, 0.0f, 1.0f) * view;//vec3(sin(m_rot.x) * cos(m_rot.y), sin(m_rot.y), cos(m_rot.x) * cos(m_rot.y));

			m_viewProj = view * mat4.proj(deg2rad(45.0f), 640.0f/480.0f, 0.1f, 5000.0f);
			m_dirty = false;
		}

		return m_viewProj;
	}

	@property vec3 pos() { return m_pos; }
	@property void pos(vec3 pos) { m_pos = pos; m_dirty = true; }

	this(int width, int height)
	{
		Resize(width, height);
	}

	void Move(float side, float forward)
	{
		if (side != 0.0f || forward != 0.0f)
		{
			m_pos = m_pos + (m_fwd * forward);
			vec3 sideV = m_fwd.cross(vec3(0.0f, 1.0f, 0.0f));
			m_pos = m_pos + (sideV * side);

			m_dirty = true;
		}
	}

	void Look(float side, float up)
	{
		if (side != 0.0f || up != 0.0f)
		{
			m_rot.y += side;
			m_rot.x += up;

			m_dirty = true;
		}
	}
	
	void Resize(int width, int height)
	{
		float aspect = cast(float)width / cast(float)height;
		m_proj = mat4.proj(45.0f, aspect, 0.1f, 5000.0f);
		m_dirty = true;
	}
}