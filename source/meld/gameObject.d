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
	@property mat4 localToWorld() 
	{
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
		return gameObject._transform;
	}
}

class GameObject
{
package:
	immutable int _instanceID;
	Transform _transform;

public:
	T Add(T,A...)(A a)
	{
		T component = new T(a);
		T.componentList ~= component;
		T.componentMap[_instanceID] = component;
		return component;
	}

	void Remove(T)()
	{
		T* component = _instanceID in T.componentMap;
		if (component !is null)
		{
			int ind = countUntil(T.componentList, *component);
			T.componentList = remove(T.componentList, ind);
			T.componentMap.remove(_instanceID);
		}
	}

	T* Get(T)()
	{
		return _instanceID in T.componentMap;
	}

	static T[] GetComponentList(T)()
	{
		return T.componentList;
	}
}

class MeshRenderer : Component!MeshRenderer
{
private:
	Mesh mesh;
	Material material;

public:
	this(Mesh mesh, Material material)
	{
		this.mesh = mesh;
		this.material = material;
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
		material.Bind(transform.localToWorld);

	}
}
