module meld.gameObject;

import meld;

import std.algorithm;

class Transform
{
private:
	bool _transformDirty = false;
	mat4 _localToWorld = mat4.identity;
	vec3 _position = vec3.zero, _forward = vec3.forward;

public:
	GameObject gameObject;
	Transform parent;

	@property mat4 localToWorld() 
	{
		if (_transformDirty)
		{
			if (parent is null)
				_localToWorld = mat4.basis(_position, _forward, vec3.up);
			else
				_localToWorld = parent.localToWorld * mat4.basis(_position, _forward, vec3.up);
		}

		_transformDirty = false;
		return _localToWorld; 
	}
	
	@property vec3 position() { return _position; }
	@property void position(vec3 value) { _position = value; _transformDirty = true; }

	@property vec3 forward() { return _forward; }
	@property void forward(vec3 value) { _forward = value; _transformDirty = true; }

	void LookAt(vec3 position)
	{
		_forward = (position - _position).normalized();
		_transformDirty = true;
	}

	vec3 ToWorld(vec3 point)
	{
		return localToWorld * point;
	}
}

abstract class Component(T)
{
package:
	static T[int] componentMap;
	static T[] componentList;
public:
	GameObject gameObject;

	@property Transform transform()
	{
		return gameObject.m_transform;
	}
}

class GameObject
{
private:
	int m_maxInstanceID = 0;
package:
	immutable int m_instanceID;
	Transform m_transform;

public:
	@property Transform transform() { return m_transform; }

	this(Transform parent = null)
	{
		m_transform = new Transform();
		m_transform.gameObject = this;
		m_transform.parent = parent;
		m_instanceID = m_maxInstanceID++;
	}

	T Add(T,A...)(A a)
	{
		T component = new T(a);
		component.gameObject = this;
		T.componentList ~= component;
		T.componentMap[m_instanceID] = component;
		return component;
	}

	void Remove(T)()
	{
		T* component = m_instanceID in T.componentMap;
		if (component !is null)
		{
			int ind = countUntil(T.componentList, *component);
			T.componentList = remove(T.componentList, ind);
			T.componentMap.remove(m_instanceID);
		}
	}

	T* Get(T)()
	{
		return m_instanceID in T.componentMap;
	}

	static T[] GetComponentList(T)()
	{
		return T.componentList;
	}
}

class MeshRenderer : Component!MeshRenderer
{
private:
	Mesh m_mesh;
	Material m_material;

public:
	this(Mesh mesh, Material material)
	{
		this.m_mesh = mesh;
		this.m_material = material;
	}

	static void Draw()
	{
		foreach (MeshRenderer renderer; GameObject.GetComponentList!MeshRenderer())
		{
			renderer.DrawInternal();
		}
	}

	void DrawInternal()
	{
		m_material.Bind(transform.localToWorld);
		m_mesh.Draw();
	}
}
