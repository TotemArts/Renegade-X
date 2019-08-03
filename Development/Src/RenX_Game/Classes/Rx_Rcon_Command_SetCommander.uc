class Rx_Rcon_Command_SetCommander extends Rx_Rcon_Command;



function string trigger(string parameters)
{
	local Rx_PRI PlayerPRI; 

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	PlayerPRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters);
	
	if( PlayerPRI != none)
	{
		Rx_Game(`WorldInfoObject.Game).ChangeCommander(PlayerPRI.GetTeamNum(), PlayerPRI);
		return "Set player to commander" ;  
	}
	
	return "";
}
function string getHelp(string parameters)
{
	return "Sets the player to commander of their team" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("setcommander");
	
	Syntax="Syntax: setcommander [Fstring]Player Name";
}
