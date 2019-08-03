class Rx_Rcon_Command_Help extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local string cmd;
	local int pos;
	if (parameters == "")
		return "The following commands are available:" $ `RxEngineObject.GetRconCommandsString();
	else
	{
		pos = InStr(parameters," ");
		if (pos < 0)
			cmd = parameters;
		else
			cmd = Left(parameters, pos);

		if (`RxEngineObject.HasRconCommand(cmd) == false)
			return "Error: Command \"" $ cmd $ "\" not found." @ getSyntax();

		return `RxEngineObject.GetRconCommandHelpString(cmd, pos < 0 ? "" : Mid(parameters, pos + 1));
	}
}

function string getHelp(string parameters)
{
	return "Lists commands, or sends command-specific help." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("help");
	Syntax="Syntax: Help Command[String]";
}
