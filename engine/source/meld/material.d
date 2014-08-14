module meld.material;

import meld;

class Material
{
private:
	interface IMaterialProperty
	{
		void SetParameter(string property, ref Shader shader);
	}

	class MaterialProperty(T) : IMaterialProperty
	{
	private:
		T m_value;

	public:
		this(T value)
		{
			m_value = value;
		}

		override void SetParameter(string property, ref Shader shader)
		{
			shader.SetParameter(property, m_value);
		}
	}

	Shader m_shader;
	IMaterialProperty[string] m_properties;
	static Material m_currentMaterial;

public:
	this(Shader shader)
	{
		m_shader = shader;
	}

	Material SetParameter(T)(string property, T value)
	{
		m_properties[property] = new MaterialProperty!T(value);
		return this;
	}

	void Bind( mat4 world )
	{
		m_shader.SetParameter("world", world);

		if (m_currentMaterial == this)
			return;

		m_currentMaterial = this;
		m_shader.Bind();

		foreach(string property, IMaterialProperty value; m_properties)
			value.SetParameter(property, m_shader);
	}
}
