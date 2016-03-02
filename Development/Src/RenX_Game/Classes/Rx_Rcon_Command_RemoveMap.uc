class Rx_Rcon_Command_RemoveMap extends Rx_Rcon_Command;



function string trigger(string parameters)
{
		
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	if(Caps(Left(parameters, 3)) != "CNC") return "Error: Not a CnC map"; 
	
	if(Rx_Game(WorldInfo.Game).RemoveMapFromRotation(parameters)) return "Map removed from rotation";
	else
	return "Map was not in rotation"; 
}
function string getHelp(string parameters)
{
	return "Removes the listed map package from the rotation. [WARNING: BE SURE THE MAP PACKAGE EXISTS AND IS SPELLED CORRECTLY!!]" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("removemap");
	
	Syntax="Syntax: removemap [Fstring]Map Name";
}
