class Rx_Rcon_Command_ToggleBotVoice extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_Bot B;

	foreach `WorldInfoObject.AllControllers(class'Rx_Bot', B)
	{
		B.ToggleBotVoice();
	}
	return parameters;
}

function string getHelp(string parameters)
{
	return "Toggle bots' radio chat ability." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("togglebotvoice");
	triggers.Add("mutebot");
	triggers.Add("mutebots");
	triggers.Add("unmutebot");
	triggers.Add("unmutebots");
	Syntax="Syntax: togglebotvoice";
}
