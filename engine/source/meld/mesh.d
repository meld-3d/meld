module meld.mesh;

import derelict.opengl3.gl3;
import std.stdio;
import std.conv;
import std.math;
import std.file;
import std.range;
import std.string;
import meld.maths;

struct Vertex
{
	this(float x, float y, float z, float nx, float ny, float nz, float u, float v)
	{
		pos = vec3(x, y, z);
		normal = vec3(nx, ny, nz);
		uv = vec2(u, v);
	}
	this(vec3 pos, vec3 normal, vec2 uv)
	{
		this.pos = pos;
		this.normal = normal;
		this.uv = uv;
	}

	vec3 pos;
	vec3 normal;
	vec2 uv;

	static void SetupLayout()
	{
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(char*)(0));
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(char*)(float.sizeof*3));
		glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(char*)(float.sizeof*6));

		glEnableVertexAttribArray(0);
		glEnableVertexAttribArray(1);
		glEnableVertexAttribArray(2);
	}
}

struct MeshData
{
	Vertex[] vertices;
	ushort[] indices;
}

class Mesh
{
private:
	GLuint m_vertexBuffer, m_indexBuffer, m_vertexLayout;
	int m_numIndices;
	GLenum m_drawMode;

	static void ErrCheck()
	{
		/*GLenum glErr;
	    int    retCode = 0;

	    glErr = glGetError();
	    if (glErr != GL_NO_ERROR)
	    {
	        assert(0, "OpenGL error: "~to!string(glErr));
	    }*/
	}

public:
	this(V)(ref V[] verts, ref ushort[] indices, GLenum drawMode)
	{
		//Create the vertex buffer
		glGenBuffers(1, &m_vertexBuffer);
		glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer);
		glBufferData(GL_ARRAY_BUFFER, V.sizeof*verts.length, &verts[0], GL_STATIC_DRAW);
		ErrCheck();

		//Create the index buffer
		glGenBuffers(1, &m_indexBuffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, ushort.sizeof*indices.length, &indices[0], GL_STATIC_DRAW);
		m_numIndices = cast(int)indices.length;
		ErrCheck();

		//Create the vertex layout
		glGenVertexArrays(1, &m_vertexLayout);
		glBindVertexArray(m_vertexLayout);

		//Bind the vertex buffer to the layout and specify the format
		glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer);
		V.SetupLayout();

		//Bind the index buffer to the layout
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
	    m_drawMode = drawMode;
		ErrCheck();

		//Null out everything
		glBindVertexArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		ErrCheck();
	}

	~this()
	{
		//Delete the buffers and vertex arrays
		glDeleteBuffers(1, &m_vertexBuffer);
		glDeleteBuffers(1, &m_indexBuffer);
		glDeleteVertexArrays(1, &m_vertexLayout);
	}

	void Draw()
	{
		glBindVertexArray(m_vertexLayout);
		glDrawRangeElements(m_drawMode, 0, m_numIndices, m_numIndices, GL_UNSIGNED_SHORT, null);
		ErrCheck();
	}

	static Mesh CreatePlane( float width, float height )
	{
		float hw = width * 0.5f;
		float hh = height * 0.5f;

		Vertex verts[] = 
		[
			Vertex(-hw, 0.0f, -hh, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f ),
			Vertex(  hw, 0.0f, -hh, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f ),
			Vertex(  hw, 0.0f,  hh, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f ),
			Vertex( -hw, 0.0f,  hh, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f ),
		];
		ushort indices[] =
		[
			0, 1, 2,
			0, 2, 3
		];

		return new Mesh(verts, indices, GL_TRIANGLES);
	}

	static Mesh CreateSphere( int rings, int segments, bool flip )
	{
		int numVerts = ((rings+1) * segments);
		Vertex[] vertices = new Vertex[numVerts];
		
		int numIndices = (numVerts-segments) * 6;
		ushort[] indices = new ushort[numIndices];
		
		float ringInterval = PI/cast(float)rings;
		float segInterval = (2.0f*PI)/cast(float)segments;
		
		float xTexInterval = 1.0f/cast(float)rings;
		float yTexInterval = 1.0f/cast(float)segments;
		float xTex = 0.0f;
		
		float ringPos = 0.0f;
		int i = 0, k = 0;
		
		for (int ring = 0; ring <= rings; ++ring, ringPos += ringInterval, xTex += xTexInterval)
		{
			float sinRing = sin(ringPos);
			float cosRing = cos(ringPos);
			float segPos = 0.0f;
			float yTex = 0.0f;
			for (int segment = 0; segment < segments; ++segment, segPos += segInterval, yTex += yTexInterval)
			{
				Vertex vertex = Vertex
				(
					cast(float)cos(segPos) * sinRing, cast(float)sin(segPos) * sinRing, cosRing,
					cast(float)cos(segPos) * sinRing, cast(float)sin(segPos) * sinRing, cosRing,
					xTex, yTex
				);
				vertices[k] = vertex;
				k++;
				
				if (ring < rings)
				{
					int j = i*6;
					indices[j+0] = cast(ushort)i;
					indices[j+1] = cast(ushort)(i+segments);
					indices[j+2] = cast(ushort)(segment == segments-1 ? i-segments+1 : i+1);
					
					indices[j+3] = cast(ushort)(segment == segments-1 ? i-segments+1 : i+1);
					indices[j+4] = cast(ushort)(i+segments);
					indices[j+5] = cast(ushort)(segment == segments-1 ? i+1 : i+segments+1);
					++i;
				}
			}
		}
		
		if (flip)
		{
			for (i = 0; i<numIndices; i+=3)
			{
				ushort tmp = indices[i+2];
				indices[i+2] = indices[i+1];
				indices[i+1] = tmp;
			}
		}
		
		Mesh sphere = new Mesh(vertices, indices, GL_TRIANGLES);
		delete vertices;
		delete indices;
		
		return sphere;
	}
	
	static Mesh CreateCone( int segments )
	{
		Vertex[] vertices = new Vertex[segments + 2];
		Vertex top = Vertex
		(
			0.0f, 0.0f, 1.0f,
			0.0f, 0.0f, 1.0f,
			0.0f, 0.0f
		);
		Vertex bottom = Vertex
		(
			0.0f, 0.0f, -1.0f,
				0.0f, 0.0f, -1.0f,
				0.0f, 1.0f
		);
		vertices[0] = top;
		vertices[1] = bottom;
		
		ushort[] indices = new ushort[segments * 6];
		int j = 2;
		int k = 0;
		float segPos = 0.0f, segInterval = (2.0f*PI)/cast(float)segments;
		for (int i = 0; i<segments; ++i, ++j, segPos += segInterval)
		{
			Vertex vertex = Vertex
			(
				cast(float)sin(segPos), cast(float)cos(segPos), -1.0f,
				cast(float)sin(segPos), cast(float)cos(segPos), -1.0f,
				segPos, 0.5f
			);
			vertices[j] = vertex;
			
			indices[k++] = cast(ushort)(i==segments-1? 2 : j+1);
			indices[k++] = cast(ushort)j;
			indices[k++] = 0;
			
			indices[k++] = 1;
			indices[k++] = cast(ushort)j;
			indices[k++] = cast(ushort)(i==segments-1? 2 : j+1);
		}
		
		Mesh cone = new Mesh(vertices, indices, GL_TRIANGLES);
		delete indices;
		delete vertices;
		
		return cone;
	}

	static Mesh CreateCube()
	{
		const float hw = 1.0f;
		const float hy = 1.0f;
		const float hh = 1.0f;
		
		Vertex verts[] = 
		[
			//Top Face (+y)
			Vertex(-hw, hy, -hh, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f ),
			Vertex(-hw, hy,  hh, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f ),
			Vertex( hw, hy,  hh, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f ),
	        Vertex( hw, hy, -hh, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f ),
				
			//Bottom Face (-y)
			Vertex( -hw, -hy, -hh, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f ),
			Vertex(  hw, -hy, -hh, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f ),
			Vertex(  hw, -hy,  hh, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f ),
			Vertex( -hw, -hy,  hh, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f ),
				
			//Left Face (-x)
			Vertex( -hw, hy, -hh, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f ),
			Vertex( -hw, -hy,-hh, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f ),
			Vertex( -hw, -hy, hh, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f ),
			Vertex( -hw, hy,  hh, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f ),
				
			//Right Face (+x)
			Vertex( hw, hy, -hh, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f ),
			Vertex( hw, hy,  hh, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f ),
			Vertex( hw, -hy, hh, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f ),
			Vertex( hw, -hy,-hh, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f ),
				
			//Front Face (-z)
			Vertex( -hw, hy, -hh, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f ),
			Vertex(  hw, hy, -hh, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f ),
			Vertex(  hw,-hy, -hh, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f ),
			Vertex( -hw,-hy, -hh, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f ),
				
			//Back Face (+z)
			Vertex( -hw, hy, hh, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f ),
			Vertex( -hw,-hy, hh, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f ),
			Vertex(  hw,-hy, hh, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f ),
			Vertex(  hw, hy, hh, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f )
		];
		ushort indices[] =
		[
			//Top Face (+y)
			0, 1, 2,
			0, 2, 3,
			//Bottom Face (-y)
			4, 5, 6,
			4, 6, 7,
			//Left Face (-x)
			8, 9, 10,
			8, 10, 11,
			//Right Face (+x)
			12, 13, 14,
			12, 14, 15,
			//Front Face (-z)
			16, 17, 18,
			16, 18, 19,
			//Back Face (+z)
			20, 21, 22,
			20, 22, 23
		];
		
		return new Mesh(verts, indices, GL_TRIANGLES);
	}
	
	static Mesh CreateCylinder(int segments)
	{
		int numVerts = (segments * 4) + 2;
		int numIndices = segments * 12;
		Vertex[] verts = new Vertex[numVerts];
		ushort[] indices = new ushort[numIndices];
		
		float segmentInterval = 2.0f*PI/cast(float)segments;
		float texIntervalIncr = 1.0f/cast(float)segments;
		float interval = 0.0f, texInterval = 0.0f;
		int ind = 0;
		for (int i = 0; i<segments; ++i, interval += segmentInterval, texInterval += texIntervalIncr)
		{
			float cosI = cos(interval);
			float sinI = sin(interval);
			
			//Cylinder caps
			{
				Vertex vert = Vertex
				(
					sinI, cosI, -1.0f,
					0.0f, 0.0f, -1.0f,
					sinI*0.5f, cosI*0.5f
				);
				verts[i] = vert;
				
				indices[ind++] = cast(ushort)i;
				indices[ind++] = cast(ushort)(i+1 == segments ? 0 : i+1);
				indices[ind++] = cast(ushort)(numVerts - 1);
				
				vert.normal.z = 1.0f;
				vert.pos.z = 1.0f;
				verts[i+segments] = vert;
				
				indices[ind++] = cast(ushort)(numVerts - 2);
				indices[ind++] = cast(ushort)(i+1 == segments ? segments : i+segments+1);
				indices[ind++] = cast(ushort)(i+segments);
			}
			//Cylinder sides
			{
				Vertex vert = Vertex
				(
					sinI, cosI, -1.0f,
						sinI, cosI, 0.0f,
						texInterval, 0.0f
				);
				int f = segments*2;
				verts[i+f] = vert;
				
				vert.uv.y = 1.0f;
				vert.pos.z = 1.0f;
				int s = segments*3;
				verts[i+s] = vert;
				
				indices[ind++] = cast(ushort)(i+f);
				indices[ind++] = cast(ushort)(i+s);
				indices[ind++] = cast(ushort)(i+1 == segments ? f : i+f+1);
				
				indices[ind++] = cast(ushort)(i+1 == segments ? s : i+s+1);
				indices[ind++] = cast(ushort)(i+1 == segments ? f : i+f+1);
				indices[ind++] = cast(ushort)(i+s);
			}
		}
		
		//Cylinder ends
		Vertex vertEnd = Vertex
		(
			0.0f, 0.0f, -1.0f,
				0.0f, 0.0f, -1.0f,
				0.0f, 0.0f
		);
		verts[numVerts-1] = vertEnd;
		vertEnd.pos.z = 1.0f;
		vertEnd.normal.z = 1.0f;
		verts[numVerts-2] = vertEnd;
		
		Mesh mesh = new Mesh(verts, indices, GL_TRIANGLES);
		delete verts;
		delete indices;
		
		return mesh;
	}

	static Mesh LoadMesh(in string path)
	{
		import msgpack;
		import std.file;

		ubyte[] data = cast(ubyte[])read(path);
		MeshData meshData = data.unpack!MeshData();

		return new Mesh(meshData.vertices, meshData.indices, GL_TRIANGLES);
	}

	/*static Mesh LoadMeshObj(string path)
	{
		import meld.maths;
		vec3[] positions = [];
		vec2[] uvs = [];
		vec3[] normals = [];

		ushort[] indices = [];
		Vertex[] verts = [];
		ushort[Vertex] vertToInd;

		auto file = File(path);
		foreach (char[] line; file.byLine())
		{
			if (line.empty) continue;

			char[][] parts = strip(line[2..$]).split(' ');

			switch (line[0..2])
			{
				case "v ":
					positions ~= vec3(to!float(parts[0]), to!float(parts[1]), to!float(parts[2]));
					break;

				case "vt":
					uvs ~= vec2(to!float(parts[0]), to!float(parts[1]));
					break;

				case "vn":
					normals ~= vec3(to!float(parts[0]), to!float(parts[1]), to!float(parts[2]));
					break;

				case "f ":
					Vertex Parse(char[][] bits)
					{
						//writeln("'" ~ bits[0] ~ "' (" ~ strip(line[2..$]) ~ ")");
						vec3 pos = positions[to!int(bits[0]) - 1];
						vec2 uv = bits.length >= 2 ? uvs[to!int(bits[1]) - 1] : vec2.zero;
						vec3 normal = bits.length >= 3 ? normals[to!int(bits[2]) - 1] : vec3.zero;
						return Vertex(pos.x, pos.y, pos.z, normal.x, normal.y, normal.z, uv.x, uv.y);
					}

					for (int i = 0; i<parts.length; i++)
					{
						Vertex vert = Parse(parts[i].split('/'));
						ushort* index = vert in vertToInd;
						ushort ind;
						if (index is null)
						{
							verts ~= vert;
							ind = to!ushort(verts.length - 1);
							//vertToInd[vert] = ind;
						}

						indices ~= ind;
					}
					break;

				default:
    				continue;
			}
		}

		Mesh mesh = new Mesh(verts, indices, GL_TRIANGLES);
		delete verts;
		delete indices;
		delete positions;
		delete uvs;
		delete normals;
		return mesh;
	}*/
}
