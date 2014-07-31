module meld.material;
/*module three.d;

Material::Material(ShaderPtr& shader)
{
	m_shaders[0] = shader;
}

Material::Material()
{
}

Material::~Material()
{
}

Material& Material::Set( Pass::Enum pass, ShaderPtr& shader )
{
	m_shaders[pass] = shader;
	return *this;
}

Material& Material::Set( Pass::Enum pass, const char* property, MaterialProperty value )
{
	m_properties[pass][property] = value;
	return *this;
}

bool Material::Bind( Pass::Enum pass, glm::mat4& world )
{
	if (m_shaders[pass].valid())
	{
		m_shaders[pass]->Bind();
		m_shaders[pass]->SetParameter("world", world);

		for (std::map<const char*, MaterialProperty>::iterator iter = m_properties[pass].begin(); iter != m_properties[pass].end(); ++iter)
		{
			iter->second.Set(iter->first, m_shaders[pass]);
		}

		return true;
	}

	return false;
}

MaterialPtr Material::Clone( MaterialPtr mat )
{
	MaterialPtr newMat = MaterialPtr(new Material());
	*newMat = *mat;
	return newMat;
}

MaterialProperty::MaterialProperty( float value )
{
	x = value;
	type = Type::Float;
}

MaterialProperty::MaterialProperty( glm::vec2 value )
{
	x = value.x;
	y = value.y;
	type = Type::Vec2;
}

MaterialProperty::MaterialProperty( glm::vec3 value )
{
	x = value.x;
	y = value.y;
	z = value.z;
	type = Type::Vec3;
}

MaterialProperty::MaterialProperty( glm::vec4 value )
{
	x = value.x;
	y = value.y;
	z = value.z;
	w = value.w;
	type = Type::Vec4;
}

MaterialProperty::MaterialProperty() :
	type(Type::None)
{
}

void MaterialProperty::Set( const char* property, ShaderPtr& shader )
{
	switch (type)
	{
	case Type::Float:
		shader->SetParameter(property, x);
		break;
	case Type::Vec2:
        {
            glm::vec2 v2(x, y);
            shader->SetParameter(property, v2);
        }
		break;
	case Type::Vec3:
        {
            glm::vec3 v3(x, y, z);
            shader->SetParameter(property, v3);
        }
		break;
	case Type::Vec4:
        {
            glm::vec4 v4(x, y, z, w);
            shader->SetParameter(property, v4);
        }
		break;
    default:
        break;
	}
}*/
