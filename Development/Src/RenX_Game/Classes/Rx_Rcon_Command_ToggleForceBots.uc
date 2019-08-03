class Rx_Rcon_Command_ToggleForceBots extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local String FinalMsg;

	if(Rx_Game(`WorldInfoObject.Game).ToggleForceBot())
		FinalMsg = "Toggling Force bot to"@Rx_Game(`WorldInfoObject.Game).bFillSpaceWithBots;

	else
		FinalMsg = "Toggling failed, unknown error";

	
	return FinalMsg;
}

function string getHelp(string parameters)
{
	return "Enables/Disables ability for server to add bots on demand" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("forcebots");
	triggers.Add("toggleforcebots");
	triggers.Add("switchforcebots");
	Syntax="Syntax: toggleforcebots";
}