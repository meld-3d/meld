module meld.gameObject;

import meld;

import std.algorithm;

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
