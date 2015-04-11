class Rx_Rcon_Command_EndMap extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	Rx_Game(WorldInfo.Game).EndRxGame("triggered",255);
	return "";
}

function string getHelp(string parameters)
{
	return "Ends the game immediately." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("endmap");
	triggers.Add("gameover");
	triggers.Add("endgame");
	Syntax="Syntax: EndMap";
}