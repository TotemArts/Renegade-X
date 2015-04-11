class Rx_Rcon_Command_Help extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_Rcon_Command cmd;
	local string listOut;
	local int pos;
	if (parameters == "")
	{
		listOut = "The following commands are available:";
		foreach RconCommands(cmd)
			if (cmd.triggers.Length != 0)
				listOut $= `nbsp $ cmd.getTrigger(0);
		return listOut;
	}
	else
	{
		pos = InStr(parameters," ");
		if (pos < 0)
			cmd = GetCommand(parameters);
		else
			cmd = GetCommand(Left(parameters, pos));
		if (cmd == None)
			return "Error: Command \"" $ Left(parameters, InStr(parameters," ")) $ "\" not found." @ getSyntax();
		return cmd.getHelp(pos < 0 ? "" : Mid(parameters, pos + 1));
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
