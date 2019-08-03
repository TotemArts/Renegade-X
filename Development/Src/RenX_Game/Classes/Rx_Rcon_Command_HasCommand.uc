class Rx_Rcon_Command_HasCommand extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	pos = InStr(parameters," ");
	if (pos < 0)
		return string(`RxEngineObject.HasRconCommand(parameters));
	return string(`RxEngineObject.HasRconCommand(Left(parameters, pos)));
}

function string getHelp(string parameters)
{
	return "Checks if a command exists." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("hascommand");
	Syntax="Syntax: HasCommand Command[String]";
}
