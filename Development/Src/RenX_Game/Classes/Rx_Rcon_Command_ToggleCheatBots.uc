class Rx_Rcon_Command_ToggleCheatBots extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local String FinalMsg;

	if(Rx_Game(`WorldInfoObject.Game).ToggleCheatBot())
		FinalMsg = "Cheat Bots set to"@Rx_Game(`WorldInfoObject.Game).CheckCheatBot();

	else
		FinalMsg = "Toggling failed, unknown error";

	
	return FinalMsg;
}

function string getHelp(string parameters)
{
	return "Enables/Disables ability to vote for adding cheat bots. Does not disable already existing cheat bots" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("cheatbots");
	triggers.Add("togglecheatbots");
	triggers.Add("switchcheatbots");
	Syntax="Syntax: togglecheatbots";
}
