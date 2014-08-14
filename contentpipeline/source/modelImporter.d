import std.string;
import std.path;
import derelict.assimp3.assimp;
import std.conv;
import std.stdio;

@(".fbx", ".obj", ".blend") string modelImporter(string sourceFile, string outputFolder)
{
	string targetFile = buildPath(outputFolder, baseName(stripExtension(sourceFile)) ~ ".mdl");

	size_t flags = 
			  aiProcess_CalcTangentSpace
			| aiProcess_GenNormals
			| aiProcess_Triangulate
			| aiProcess_MakeLeftHanded
			| aiProcess_PreTransformVertices
			| aiProcess_JoinIdenticalVertices
			| aiProcess_OptimizeMeshes
			| aiProcess_ImproveCacheLocality
			| aiProcess_RemoveRedundantMaterials
			| aiProcess_GenSmoothNormals
			| aiProcess_OptimizeGraph
			| aiProcess_FindInvalidData
			| aiProcess_SortByPType;
	const(aiScene)* scene = aiImportFile(sourceFile.toStringz, flags);
	if (!scene)
	{
		string errorMessage = to!string(aiGetErrorString());
		throw new Exception("Failed to build " ~ sourceFile ~ ": " ~ errorMessage);
	}
	scope(exit) aiReleaseImport(scene);

	for (size_t i = 0; i<scene.mNumMeshes; ++i)
	{
		const(aiMesh)* mesh = scene.mMeshes[i];
		if (!mesh.mNormals) throw new Exception("Model has no normals!");
		if (!mesh.mTextureCoords[0]) throw new Exception("Model has no tex coords!");

		string meshName = to!string(mesh.mName.data[0..mesh.mName.length]);
		writefln("Mesh %d %d %d", mesh.mName.length, mesh.mNumVertices, mesh.mNumFaces);
	}

	return "Built nothin!";
}