class Rx_Rcon_Command_VehicleLimit extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int index;

	parameters = string(Rx_Game(WorldInfo.Game).VehicleLimit);
	for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
		parameters $= `nbsp $ class'Rx_Game'.static.GetTeamName(index) `s Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]).VehicleLimit;
	return parameters;
}

function string getHelp(string parameters)
{
	return "Returns the vehicle limit." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("vehiclelimit");
	triggers.Add("vlimit");
	Syntax="Syntax: VehicleLimit";
}
