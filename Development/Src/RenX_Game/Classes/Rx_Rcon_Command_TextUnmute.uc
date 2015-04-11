class Rx_Rcon_Command_TextUnmute extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local UTPlayerController TargetPlayerPC;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	TargetPlayerPC = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(parameters));
	if ( TargetPlayerPC != none )
	{
		TargetPlayerPC.bServerMutedText = false;
		return "Unmuted "$TargetPlayerPC.PlayerReplicationInfo.PlayerName;
	}

	return "Player not found";
}

function string getHelp(string parameters)
{
	return "Allows a player to chat." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("textunmute");
	triggers.Add("unmute");
	Syntax="Syntax: TextUnmute Player[String]";
}