class Rx_Rcon_Command_TextMute extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local UTPlayerController TargetPlayerPC;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	TargetPlayerPC = UTPlayerController(`WorldInfoObject.Game.AccessControl.GetControllerFromString(parameters));
	if ( TargetPlayerPC != none )
	{
		TargetPlayerPC.bServerMutedText = true;
		return "";
	}

	return "Error: Player not found";
}

function string getHelp(string parameters)
{
	return "Prevents a player from chatting." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("textmute");
	triggers.Add("mute");
	Syntax="Syntax: TextMute Player[String]";
}