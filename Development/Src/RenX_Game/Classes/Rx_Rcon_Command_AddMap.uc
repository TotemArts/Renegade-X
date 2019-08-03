class Rx_Rcon_Command_AddMap extends Rx_Rcon_Command;



function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	if(Caps(Left(parameters, 3)) != "CNC")
		return "Error: Not a CnC map"; 
	
	if(Rx_Game(`WorldInfoObject.Game).AddMapToRotation(parameters) == false)
		return "Map addition failed";
	
	return "";
}
function string getHelp(string parameters)
{
	return "Adds the listed map package to the rotation. [WARNING: BE SURE THE MAP PACKAGE EXISTS AND IS SPELLED CORRECTLY!!]" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("addmap");
	
	Syntax="Syntax: addmap [Fstring]Map Name";
}
