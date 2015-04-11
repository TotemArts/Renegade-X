class Rx_Rcon_Command_RecordDemo extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	Rx_Game(WorldInfo.Game).AdminRecord(None);
	return "";
}

function string getHelp(string parameters)
{
	return "Starts a demo recording." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("recorddemo");
	triggers.Add("demorecord");
	triggers.Add("demorec");
	Syntax="Syntax: RecordDemo";
}