class Rx_Rcon_Command_VehicleLimit extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int index;
	if (parameters != "")
	{
		Rx_Game(WorldInfo.Game).VehicleLimit = Max(0, int(parameters));
		for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
			Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]).VehicleLimit = Rx_Game(WorldInfo.Game).VehicleLimit;
	}
	parameters = string(Rx_Game(WorldInfo.Game).VehicleLimit);
	for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
		parameters $= `nbsp $ class'Rx_Game'.static.GetTeamName(index) `s Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]).VehicleLimit;
	return parameters;
}

function string getHelp(string parameters)
{
	return "Sets the vehicle limit, if specified; returns the vehicle limit." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("vehiclelimit");
	triggers.Add("vlimit");
	Syntax="Syntax: VehicleLimit Amount[Int]";
}
