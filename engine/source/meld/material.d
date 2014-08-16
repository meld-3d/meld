module meld.material;

import meld;

class Material
{
private:
	struct MaterialProperty
	{
		byte[64] value;
		void function(string property, ref MaterialProperty prop, ref Shader shader) setParameter;

		void SetValue(T)(T value)
		{
			static assert(T.sizeof <= this.value.sizeof);
			byte* valPtr = cast(byte*)&value;
			foreach (i; 0..T.sizeof)
				this.value[i] = valPtr[i];
		}

		T GetValue(T)()
		{
			const int floatWidth = T.sizeof / float.sizeof;
			static assert(T.sizeof <= this.value.sizeof);
			T value;
			byte* valPtr = cast(byte*)&value;
			foreach (i; 0..T.sizeof)
				valPtr[i] = this.value[i];
			return value;
		}
	}

	Shader m_shader;
	MaterialProperty[string] m_properties;
	static Material m_currentMaterial;
	static MaterialProperty[string] m_globalProperties;
	static bool m_globalPropsChanged = false;

public:
	this(Shader shader)
	{
		m_shader = shader;
	}

	Material SetParameter(T)(string property, T value)
	{
		MaterialProperty prop;
		prop.SetValue!T(value);

		prop.setParameter = function(string property, ref MaterialProperty value, ref Shader shader)
		{
			shader.SetParameter(property, value.GetValue!T());
		};
		m_properties[property] = prop;
		return this;
	}

	static void SetGlobalParameter(T)(string property, T value)
	{
		MaterialProperty prop;
		prop.SetValue!T(value);

		prop.setParameter = function(string property, ref MaterialProperty value, ref Shader shader)
		{
			shader.SetParameter(property, value.GetValue!T());
		};
		m_globalProperties[property] = prop;
		m_globalPropsChanged = true;
	}

	void SetParameters(ref MaterialProperty[string] propList)
	{
		foreach (string property, MaterialProperty value; propList)
			value.setParameter(property, value, m_shader);
	}

	void Bind( mat4 world )
	{
		m_shader.Bind();
		m_shader.SetParameter("world", world);
		SetParameters(m_globalProperties);
		SetParameters(m_properties);
		/*if (m_globalPropsChanged)
		{
			
			m_globalPropsChanged = false;
		}

		if (m_currentMaterial == this)
			return;

		m_currentMaterial = this;

		//If the shader has changed, rebind all global variables onto the new shader
		if (m_shader.Bind())
			
		
		SetParameters(m_properties);*/
	}

	void Test()
	{
		SetParameter!vec3("Test", vec3.zero);
	}
}
