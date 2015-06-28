class Rx_Rcon_Command_BuildingInfo extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local string ret;
	local Rx_Building building;

	ret = "Building" `s "Health" `s "MaxHealth" `s "Team" `s "Capturable";
	foreach WorldInfo.AllActors(class'Rx_Building', building)
		ret $= "\n" $ string(building.Class.name) `s string(building.GetHealth()) `s string(building.GetMaxHealth()) `s class'Rx_Game'.static.GetTeamName(building.GetTeamNum()) `s string(RxIfc_Capturable(building.BuildingInternals) != None);
	return ret;
}

function string getHelp(string parameters)
{
	return "Constructs a list of buildings, and their statuses." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("buildinginfo");
	triggers.Add("binfo");
	triggers.Add("buildinglist");
	triggers.Add("blist");
	Syntax="Syntax: BuildingInfo";
}