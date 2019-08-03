class Rx_Rcon_Command_LockBuildingHealth extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local bool HealthLocked;
	local Rx_Building_Team_Internals BuildingInternals;
	
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	HealthLocked = bool(parameters);
	foreach `WorldInfoObject.AllActors(class'Rx_Building_Team_Internals', BuildingInternals)
		BuildingInternals.HealthLocked = HealthLocked;

	return "HealthLocked:" `s string(HealthLocked);
}

function string getHelp(string parameters)
{
	return "Locks or Unlocks building health" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("lockbuildings");
	triggers.Add("lockhealth");
	triggers.Add("lockb");
	triggers.Add("lockh");
	triggers.Add("lb");
	
	Syntax="Syntax: LockBuildings LockHealth[Bool]";
}
