/**
 * Copyright Alex Parker 2013-2014
 *
 * This file contains vec3, mat4 data structures and associated operations.
 **/

import std.math;

//converts radians to degrees
float rad2deg(float radians)
{
    return radians * (180.0f/PI);
}

//converts degrees to radians
float deg2rad(float deg)
{
    return (deg * PI) / 180.0f;
}

//represents a 2D vector
struct vec2
{
    float x, y;
    
    this(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
    
    //multiplies the vector by a scalar, returning the result.
    vec2 opBinary(string op)(immutable float scalar)
    {
        static if (op == "*")
            return vec2(x * scalar, y * scalar);
        else static assert(0, "Operator "~op~" not implemented");
    }

    vec2 opBinary(string op)(immutable vec2 other)
    {
        static if (op == "+")
            return vec2(x + other.x, y + other.y);
        else static if (op == "-")
            return vec2(x - other.x, y - other.y);
        else static assert(0, "Operator "~op~" not implemented");
    }

    //calculate the dot product with the other vector, returning the result.
    float dot(immutable vec2 other)
    {
        return x*other.x + y*other.y;
    }
    
    //calculates the squared length of the current vector.
    float lengthSq()
    {
        return dot(this);
    }
    
	//calculates the length of the vector.
    float length()
    {
        return sqrt(lengthSq());
    }
    
    //normalizes the current vector.
    void normalize()
    {
        float len = length();
        x /= len;
        y /= len;
    }
};

//represents a 3D vector
struct vec3
{
    float x, y, z;
    
    this(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
	//multiplies the vector by a scalar, returning the result.
    vec3 opBinary(string op)(immutable float scalar)
    {
        static if (op == "*")
            return vec3(x * scalar, y * scalar, z * scalar);
        else static assert(0, "Op "~op~" not implemented");
    }
	
    vec3 opBinary(string op)(immutable vec3 other)
    {
        static if (op == "+")
            return vec3(x + other.x, y + other.y, z + other.z);
        else static if (op == "-")
            return vec3(x - other.x, y - other.y, z - other.z);
        else static assert(0, "Operator "~op~" not implemented");
    }
    
	//calculate the dot product with the other vector, returning the result.
    float dot(immutable vec3 other)
    {
        return x*other.x + y*other.y + z*other.z;
    }
    
	//calculates the squared length of the current vector.
    float lengthSq()
    {
        return dot(this);
    }
    
	//calculates the length of the vector.
    float length()
    {
        return sqrt(lengthSq());
    }
    
	//normalizes the current vector.
    void normalize()
    {
        float len = length();
        x /= len;
        y /= len;
        z /= len;
    }
    
	//calculates the cross product with the other vector, returning the result.
    vec3 cross(immutable vec3 other)
    {
        return vec3(
                    y*other.z - z*other.y,
                    z*other.x - x*other.z,
                    x*other.y - y*other.x
                    );
    }
};

//represents a 4D vector
struct vec4
{
	float x, y, z, w;

	this(float x, float y, float z, float w)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
};

//represents a 4x4 matrix
struct mat4
{
    float rows[16];

    this(float rows[16])
    {
        this.rows = rows;
    }

	//performs a matrix multiplication and returns the result.
    mat4 opBinary(string op)(immutable mat4 other)
    {
        static if (op == "*")
        {
            mat4 res;
            for (int i = 0; i<16; i+=4)
                for (int j = 0; j<4; j++)
                    res.rows[i+j] =
                    other.rows[i]*rows[j] +
                    other.rows[i+1]*rows[j+4] +
                    other.rows[i+2]*rows[j+8] +
                    other.rows[i+3]*rows[j+12];
            
            return res;
        }
    }
    
	//produces a axis angle matrix. This will produce a rotation in radians about the normalized axis.
    static mat4 axisangle(immutable vec3 axis, float angle)
    {
        float c = cos(angle), ic = 1.0f - c;
        float s = sin(angle);
        mat4 mat = mat4([
            c+ic*axis.x*axis.x,         ic*axis.x*axis.y-axis.z*s,  ic*axis.x*axis.z+axis.y*s, 0.0f,
            ic*axis.x*axis.y+axis.z*s,  c+ic*axis.y*axis.y,         ic*axis.y*axis.z-axis.x*s, 0.0f,
            ic*axis.x*axis.z-axis.y*s,  ic*axis.y*axis.z+axis.x*s,  c+ic*axis.z*axis.z,        0.0f,
            0.0f,                       0.0f,                       0.0f,                      1.0f
        ]);
		return mat;
    }

    static mat4 translate(immutable vec3 pos)
    {
        return translate(pos.x, pos.y, pos.z);
    }
    
	//produces a translation matrix
    static mat4 translate(float x, float y, float z)
    {
        mat4 mat = mat4([
            1.0f, 0.0f, 0.0f, x,
            0.0f, 1.0f, 0.0f, y,
            0.0f, 0.0f, 1.0f, z,
            0.0f, 0.0f, 0.0f, 1.0f
        ]);
		return mat;
    }
    
	//returns the identity matrix
    static mat4 identity()
    {
        mat4 mat = mat4([
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
        ]);
		return mat;
    }
    
	//calculates a projection matrix from the field of view in radians,
	//the aspect ratio, the near culling plane and far culling plane.
    static mat4 proj(float fov, float aspect, float n, float f)
    {
        float yScale = 1.0f/tan(fov*0.5f);
        float xScale = yScale / aspect;
        
        mat4 mat = mat4([
            xScale, 0.0f,   0.0f, 0.0f,
            0.0f,   yScale, 0.0f, 0.0f,
            0.0f,   0.0f,   f/(f-n), (-f*n)/(f-n),
            0.0f,   0.0f,   1.0f, 0.0f
        ]);
		return mat;
    }
}
