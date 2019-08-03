class Rx_Rcon_Command_Rotation extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local string map_rotation;
	local int index;
	local array<string> maps;
	
	maps = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;
	if (maps.Length == 0)
		return "";

	map_rotation = maps[0] `s class'Rx_Game'.static.GuidToHex(`WorldInfoObject.GetPackageGuid(name(maps[0])));

	index = 1;
	while (index != maps.Length)
	{
		map_rotation $= "\n" $ maps[index] `s class'Rx_Game'.static.GuidToHex(`WorldInfoObject.GetPackageGuid(name(maps[index])));
		++index;
	}
	return map_rotation;
}

function string getHelp(string parameters)
{
	return "Fetches the current map rotation." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("rotation");
	Syntax="Syntax: Rotation";
}