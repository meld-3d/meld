import std.stdio;
import std.string;
import std.file;
import std.path;
import std.algorithm;
import std.array;
import derelict.assimp3.assimp : DerelictASSIMP3;
import modelImporter : modelImporter;

void main()
{
	writeln("Meld Content Builder");

	if (!exists("content"))
		throw new Exception("Failed to find content folder");

	alias string function(string sourceFile, string outputFolder) BuildMethod;
	BuildMethod[string[]] fileTypeToPipeline = 
	[
		[__traits(getAttributes, modelImporter)]: &modelImporter
	];

	DerelictASSIMP3.load();
	
	if (!exists("data"))
		mkdir("data");

	foreach (string file; dirEntries("content", "*.*", SpanMode.depth))
	{
		auto desiredExt = extension(file);
		BuildMethod buildMethod = &copyFiles;

		foreach (extensions, method; fileTypeToPipeline)
			if (canFind(extensions, desiredExt))
			{
				buildMethod = method;
				break;
			}

		//TODO: only build content if changed
		writeln("Building " ~ file);
		string outputFile = buildMethod(file, "data");
		writeln("\t-> " ~ outputFile);
	}
}

string copyFiles(string sourceFile, string outputFolder)
{
	string target = buildPath(outputFolder, baseName(sourceFile));
	copy(sourceFile, target);
	return target;
}