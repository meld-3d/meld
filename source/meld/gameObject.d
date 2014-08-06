import meld;

abstract class Component(T)
{
package:
	static T[int] componentMap;
	static T[] componentList;
public:
	immutable GameObject gameObject;
}

class GameObject
{
private:
	immutable int instanceID;

public:
	T Add(T,A...)(A a)
	{
		T component = new T(a);
		T.componentList ~= component;
		T.componentMap[instanceID] = component;
		return component;
	}

	static T[] GetComponentList(T)()
	{
		return T.componentList;
	}
}

void Test()
{
	GameObject o;
	Mesh mesh;
	o.Add!MeshRenderer(mesh);

	MeshRenderer.Draw();
}

class MeshRenderer : Component!MeshRenderer
{
private:
	Mesh mesh;

public:
	this(Mesh mesh)
	{
		this.mesh = mesh;
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

	}
}
