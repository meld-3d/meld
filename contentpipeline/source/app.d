import std.stdio;
import std.string;
import std.file;
import std.path;
import std.algorithm;
import std.array;
import modelImporter : modelImporter;

void main()
{
	writeln("Meld Content Builder");
	writeln("Building Content...");

	if (!exists("content"))
		throw new Exception("Failed to find content folder");

	alias string function(string sourceFile, string outputFolder) BuildMethod;
	BuildMethod[string[]] fileTypeToPipeline = 
	[
		[".glsl", ".jpg", ".png"]: &copyFiles,
		[__traits(getAttributes, modelImporter)]: &modelImporter
	];
	
	immutable string targetFolder = "bin/data";
	if (!exists(targetFolder))
		mkdir(targetFolder);

	foreach (string file; dirEntries("content", "*.*", SpanMode.depth))
	{
		auto desiredExt = extension(file);
		foreach (extensions, method; fileTypeToPipeline)
			if (canFind(extensions, desiredExt))
			{
				writeln("Building " ~ file);
				string outputFile = method(file, targetFolder);
				writeln("\t-> " ~ outputFile);
				break;
			}
	}
}

string copyFiles(string sourceFile, string outputFolder)
{
	string target = buildPath(outputFolder, baseName(sourceFile));
	copy(sourceFile, target);
	return target;
}