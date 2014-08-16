module meld.transform;

import meld.maths;
import meld.gameObject;

class Transform
{
public:
	GameObject gameObject;
	Transform parent;
	mat4 transform = mat4.identity;

	@property mat4 localToWorld()
	{
		if (parent is null)
			return transform;
		else
			return parent.localToWorld * transform;
	}
}
