/**
 * Manages information about UDK packages, including Name and GUID information
 * 
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_PackageManager extends Object;

struct PackageInfo
{
	var string PackageName;
	var GUID PackageGUID;
};

var array<PackageInfo> AvailablePackages;

function Initialize()
{
	// Cycle through all package files and read headers as necessary. Store into PackageInfo
}

function AddPackage(string PackageName, array<byte> PackageData)
{
	local int index;
	local string tmp;

	`log("PACKAGE START " $ PackageName $ ":");

	for (index = 0; index != PackageData.Length; ++index)
		tmp $= Chr(PackageData[index]);

	`log(tmp);

	`log("PACKAGE END");

	// write PackageData to Cache

	// Add new package to package list

	// Analyze package for dependencies. If any are found that aren't being downloaded
}

function Tick(float DeltaTime)
{
}

DefaultProperties
{
}
