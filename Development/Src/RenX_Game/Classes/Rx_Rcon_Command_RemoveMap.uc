class Rx_Rcon_Command_RemoveMap extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	if(Rx_Game(`WorldInfoObject.Game).RemoveMapFromRotation(parameters) == false)
		return "Error: Map was not in rotation"; 
	
	return "";
}
function string getHelp(string parameters)
{
	return "Removes the listed map package from the rotation. [WARNING: BE SURE THE MAP PACKAGE EXISTS AND IS SPELLED CORRECTLY!!]" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("removemap");
	
	Syntax="Syntax: RemoveMap MapName[String]";
}
