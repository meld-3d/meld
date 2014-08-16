import std.string;
import std.path;
import derelict.assimp3.assimp;
import std.conv;
import std.stdio;
import meld;
import msgpack;
import std.file : write;

@(".fbx", ".obj") string modelImporter(string sourceFile, string outputFolder)
{
	static bool isInit;
	if (!isInit)
	{
		DerelictASSIMP3.load();
		isInit = true;
	}

	string targetFile = buildPath(outputFolder, baseName(stripExtension(sourceFile)) ~ ".mdl");

	uint flags = 
			  aiProcess_CalcTangentSpace
			| aiProcess_GenNormals
			| aiProcess_Triangulate
			//| aiProcess_MakeLeftHanded
			| aiProcess_PreTransformVertices
			| aiProcess_JoinIdenticalVertices
			| aiProcess_OptimizeMeshes
			| aiProcess_ImproveCacheLocality
			| aiProcess_RemoveRedundantMaterials
			| aiProcess_GenSmoothNormals
			| aiProcess_OptimizeGraph
			| aiProcess_FindInvalidData;
	const(aiScene)* scene = aiImportFile(cast(const(char*))sourceFile.toStringz, flags);
	if (!scene)
	{
		string errorMessage = to!string(aiGetErrorString());
		throw new Exception("Failed to build " ~ sourceFile ~ ": " ~ errorMessage);
	}
	scope(exit) aiReleaseImport(scene);

	if (scene.mNumMeshes != 1) throw new Exception("Model has more than one mesh!");

	const(aiMesh)* mesh = scene.mMeshes[0];

	if (!mesh.mNormals) throw new Exception("Model has no normals!");
	if (!mesh.mTextureCoords[0]) throw new Exception("Model has no tex coords!");
	if (mesh.mPrimitiveTypes != aiPrimitiveType_TRIANGLE) throw new Exception("Model is not triangulated!");

	MeshData outputMesh;

	//Output mesh data
	outputMesh.vertices = new Vertex[mesh.mNumVertices];
	foreach (int j, ref Vertex vert; outputMesh.vertices)
	{
		vert.pos = cast(vec3)mesh.mVertices[j];
		vert.normal = cast(vec3)mesh.mNormals[j];
		vert.uv = vec2(mesh.mTextureCoords[0][j].x, mesh.mTextureCoords[0][j].y);
	}

	//Output faces
	outputMesh.indices = new ushort[mesh.mNumFaces*3];
	foreach (int j; 0..mesh.mNumFaces)
		foreach (int k; 0..3)
			outputMesh.indices[j+k] = cast(ushort)mesh.mFaces[j].mIndices[k];

	ubyte[] contents = pack(outputMesh);
	write(targetFile, contents);

	return "Built " ~ targetFile;
}