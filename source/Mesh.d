
class Mesh
{
	this(Vertex* verts, int numVerts, unsigned short* indices, int numIndices, GLEnum drawMode)
	{
		//Create the vertex buffer
		HR(glGenBuffers(1, &m_vertexBuffer));
		HR(glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer));
		HR(glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)*numVerts, verts, GL_STATIC_DRAW));

		//Create the index buffer
		HR(glGenBuffers(1, &m_indexBuffer));
		HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer));
		HR(glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned short)*numIndices, indices, GL_STATIC_DRAW));
		m_numIndices = numIndices;

		//Create the vertex layout
		HR(glGenVertexArrays(1, &m_vertexLayout));
		HR(glBindVertexArray(m_vertexLayout));

		//Bind the vertex buffer to the layout and specify the format
		HR(glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer));
		HR(glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(0)));
		HR(glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(sizeof(float)*3)));
		HR(glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(sizeof(float)*6)));

		HR(glEnableVertexAttribArray(0));
		HR(glEnableVertexAttribArray(1));
		HR(glEnableVertexAttribArray(2));
		HR(glDisableVertexAttribArray(3));

		//Bind the index buffer to the layout
		HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer));
	    m_drawMode = drawMode;

		//Null out everything
		HR(glBindVertexArray(0));
		HR(glBindBuffer(GL_ARRAY_BUFFER, 0));
		HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0));
	}
}

/*#include "glwt.h"
#include "Mesh.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

Mesh::Mesh( Vertex* verts, int numVerts, unsigned short* indices, int numIndices, GLenum drawMode )
{
	//Create the vertex buffer
	HR(glGenBuffers(1, &m_vertexBuffer));
	HR(glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer));
	HR(glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)*numVerts, verts, GL_STATIC_DRAW));

	//Create the index buffer
	HR(glGenBuffers(1, &m_indexBuffer));
	HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer));
	HR(glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned short)*numIndices, indices, GL_STATIC_DRAW));
	m_numIndices = numIndices;

	//Create the vertex layout
	HR(glGenVertexArrays(1, &m_vertexLayout));
	HR(glBindVertexArray(m_vertexLayout));

	//Bind the vertex buffer to the layout and specify the format
	HR(glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer));
	HR(glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(0)));
	HR(glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(sizeof(float)*3)));
	HR(glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(sizeof(float)*6)));

	HR(glEnableVertexAttribArray(0));
	HR(glEnableVertexAttribArray(1));
	HR(glEnableVertexAttribArray(2));
	HR(glDisableVertexAttribArray(3));

	//Bind the index buffer to the layout
	HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer));
    m_drawMode = drawMode;

	//Null out everything
	HR(glBindVertexArray(0));
	HR(glBindBuffer(GL_ARRAY_BUFFER, 0));
	HR(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0));
}

Mesh::~Mesh()
{
	//Delete the buffers and vertex arrays
	glDeleteBuffers(1, &m_vertexBuffer);
	glDeleteBuffers(1, &m_indexBuffer);
	glDeleteVertexArrays(1, &m_vertexLayout);
}

void Mesh::Draw()
{
	HR(glBindVertexArray(m_vertexLayout));
	HR(glDrawRangeElements(m_drawMode, 0, m_numIndices, m_numIndices, GL_UNSIGNED_SHORT, NULL));
}

MeshPtr Mesh::CreatePlane( float width, float height )
{
	float hw = width * 0.5f;
	float hh = height * 0.5f;

	Vertex verts[] = 
	{
		{ -hw, 0.0f, -hh, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f },
		{  hw, 0.0f, -hh, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f },
		{  hw, 0.0f,  hh, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f },
		{ -hw, 0.0f,  hh, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f },
	};
	unsigned short indices[] =
	{
		0, 1, 2,
		0, 2, 3
	};

	return MeshPtr(new Mesh(verts, 4, indices, 6));
}

MeshPtr Mesh::CreateSphere( int rings, int segments, bool flip )
{
	int numVerts = ((rings+1) * segments);
	Vertex* vertices = new Vertex[numVerts];
	Vertex* pVertex = vertices;

	int numIndices = (numVerts-segments) * 6;
	unsigned short* indices = new unsigned short[numIndices];
	
	float ringInterval = PI/static_cast<float>(rings);
	float segInterval = (2.0f*PI)/static_cast<float>(segments);

	float xTexInterval = 1.0f/static_cast<float>(rings);
	float yTexInterval = 1.0f/static_cast<float>(segments);
	float xTex = 0.0f;

	float ringPos = 0.0f;
	int i = 0;

	for (int ring = 0; ring <= rings; ++ring, ringPos += ringInterval, xTex += xTexInterval)
	{
		float sinRing = sin(ringPos);
		float cosRing = cos(ringPos);
		float segPos = 0.0f;
		float yTex = 0.0f;
		for (int segment = 0; segment < segments; ++segment, segPos += segInterval, yTex += yTexInterval)
		{
			Vertex vertex =
			{
				(float)cos(segPos) * sinRing, (float)sin(segPos) * sinRing, cosRing,
				(float)cos(segPos) * sinRing, (float)sin(segPos) * sinRing, cosRing,
				xTex, yTex
			};
			*pVertex = vertex;
			++pVertex;

			if (ring < rings)
			{
				int j = i*6;
				indices[j+0] = i;
				indices[j+1] = i+segments;
				indices[j+2] = segment == segments-1 ? i-segments+1 : i+1;

				indices[j+3] = segment == segments-1 ? i-segments+1 : i+1;
				indices[j+4] = i+segments;
				indices[j+5] = segment == segments-1 ? i+1 : i+segments+1;
				++i;
			}
		}
	}

	if (flip)
	{
		for (int i = 0; i<numIndices; i+=3)
		{
			unsigned short tmp = indices[i+2];
			indices[i+2] = indices[i+1];
			indices[i+1] = tmp;
		}
	}

	Mesh* sphere = new Mesh(vertices, numVerts, indices, numIndices);
	delete[] vertices;
	delete[] indices;

	return MeshPtr(sphere);
}

MeshPtr Mesh::CreateCone( int segments )
{
	Vertex* vertices = new Vertex[segments + 2];
	Vertex top =
	{
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f
	};
	Vertex bottom =
	{
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f,
		0.0f, 1.0f
	};
	vertices[0] = top;
	vertices[1] = bottom;

	unsigned short* indices = new unsigned short[segments * 6];
	int j = 2;
	int k = 0;
	float segPos = 0.0f, segInterval = (2.0f*PI)/static_cast<float>(segments);
	for (int i = 0; i<segments; ++i, ++j, segPos += segInterval)
	{
		Vertex vertex =
		{
			(float)sin(segPos), (float)cos(segPos), -1.0f,
			(float)sin(segPos), (float)cos(segPos), -1.0f,
			segPos, 0.5f
		};
		vertices[j] = vertex;

		indices[k++] = i==segments-1? 2 : j+1;
		indices[k++] = j;
		indices[k++] = 0;

		indices[k++] = 1;
		indices[k++] = j;
		indices[k++] = i==segments-1? 2 : j+1;
	}

	Mesh* cone = new Mesh(vertices, segments + 2, indices, segments * 6);
	delete[] indices;
	delete[] vertices;

	return MeshPtr(cone);
}

MeshPtr Mesh::CreateSphereNormals( int rings, int segments )
{
	int numVerts = ((rings+1) * segments) * 2;
	Vertex* vertices = new Vertex[numVerts];
	Vertex* pVertex = vertices;

	int numIndices = numVerts * 2;
	unsigned short* indices = new unsigned short[numIndices];

	float ringInterval = PI/static_cast<float>(rings);
	float segInterval = (2.0f*PI)/static_cast<float>(segments);
	float ringPos = 0.0f;
	int i = 0;

	for (int ring = 0; ring <= rings; ++ring, ringPos += ringInterval)
	{
		float sinRing = sin(ringPos);
		float cosRing = cos(ringPos);
		float segPos = 0.0f;
		for (int segment = 0; segment < segments; ++segment, segPos += segInterval)
		{
			Vertex vertex =
			{
				(float)cos(segPos) * sinRing, (float)sin(segPos) * sinRing, cosRing,
				0.0f, 0.0f, 0.0f,
				1.0f, 1.0f
			};
			*pVertex = vertex;
			++pVertex;

			Vertex normal =
			{
				(float)cos(segPos) * sinRing * 1.2f, (float)sin(segPos) * sinRing * 1.2f, cosRing * 1.2f,
				0.0f, 0.0f, 0.0f,
				1.0f, 1.0f
			};
			*pVertex = normal;
			++pVertex;

			indices[i*2] = i*2;
			indices[i*2+1] = i*2+1;
			++i;
		}
	}

	Mesh* sphere = new Mesh(vertices, numVerts, indices, numIndices, GL_LINES);
	delete[] vertices;
	delete[] indices;

	return MeshPtr(sphere);
}

MeshPtr Mesh::CreateCube()
{
	const float hw = 1.0f;
	const float hy = 1.0f;
	const float hh = 1.0f;

	Vertex verts[] = 
	{
		//Top Face (+y)
		{ -hw, hy, -hh, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f },
		{ -hw, hy,  hh, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f },
		{  hw, hy,  hh, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f },
		{  hw, hy, -hh, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f },

		//Bottom Face (-y)
		{ -hw, -hy, -hh, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f },
		{  hw, -hy, -hh, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f },
		{  hw, -hy,  hh, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f },
		{ -hw, -hy,  hh, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f },

		//Left Face (-x)
		{ -hw, hy, -hh, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f },
		{ -hw, -hy,-hh, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f },
		{ -hw, -hy, hh, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f },
		{ -hw, hy,  hh, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f },

		//Right Face (+x)
		{ hw, hy, -hh, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f },
		{ hw, hy,  hh, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f },
		{ hw, -hy, hh, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f },
		{ hw, -hy,-hh, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f },

		//Front Face (-z)
		{ -hw, hy, -hh, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f },
		{  hw, hy, -hh, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f },
		{  hw,-hy, -hh, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f },
		{ -hw,-hy, -hh, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f },

		//Back Face (+z)
		{ -hw, hy, hh, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f },
		{ -hw,-hy, hh, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f },
		{  hw,-hy, hh, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f },
		{  hw, hy, hh, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f },
	};
	unsigned short indices[] =
	{
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
	};

	return MeshPtr(new Mesh(verts, 24, indices, 36));
}

MeshPtr Mesh::CreateCylinder(int segments)
{
	int numVerts = (segments * 4) + 2;
	int numIndices = segments * 12;
	Vertex* verts = new Vertex[numVerts];
	unsigned short* indices = new unsigned short[numIndices];

	float segmentInterval = 2.0f*PI/static_cast<float>(segments);
	float texIntervalIncr = 1.0f/static_cast<float>(segments);
	float interval = 0.0f, texInterval = 0.0f;
	int ind = 0;
	for (int i = 0; i<segments; ++i, interval += segmentInterval, texInterval += texIntervalIncr)
	{
		float cosI = cos(interval);
		float sinI = sin(interval);

		//Cylinder caps
		{
			Vertex vert =
			{
				sinI, cosI, -1.0f,
				0.0f, 0.0f, -1.0f,
				sinI*0.5f, cosI*0.5f
			};
			verts[i] = vert;

			indices[ind++] = i;
			indices[ind++] = i+1 == segments ? 0 : i+1;
			indices[ind++] = numVerts - 1;

			vert.nz = 1.0f;
			vert.z = 1.0f;
			verts[i+segments] = vert;

			indices[ind++] = numVerts - 2;
			indices[ind++] = i+1 == segments ? segments : i+segments+1;
			indices[ind++] = i+segments;
		}
		//Cylinder sides
		{
			Vertex vert =
			{
				sinI, cosI, -1.0f,
				sinI, cosI, 0.0f,
				texInterval, 0.0f
			};
			int f = segments*2;
			verts[i+f] = vert;

			vert.ty = 1.0f;
			vert.z = 1.0f;
			int s = segments*3;
			verts[i+s] = vert;

			indices[ind++] = i+f;
			indices[ind++] = i+s;
			indices[ind++] = i+1 == segments ? f : i+f+1;

			indices[ind++] = i+1 == segments ? s : i+s+1;
			indices[ind++] = i+1 == segments ? f : i+f+1;
			indices[ind++] = i+s;
		}
	}

	//Cylinder ends
	Vertex vertEnd =
	{
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f
	};
	verts[numVerts-1] = vertEnd;
	vertEnd.z = 1.0f;
	vertEnd.nz = 1.0f;
	verts[numVerts-2] = vertEnd;

	Mesh* mesh = new Mesh(verts, numVerts, indices, ind);
	delete[] verts;
	delete[] indices;

	return MeshPtr(mesh);
}*/