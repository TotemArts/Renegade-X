class Rx_ScriptedObj_AttackBuildings extends Rx_ScriptedObj
	placeable;

var(ScriptedObjective) Array<Rx_BuildingObjective> MyBuildingObjectives;

simulated event PostBeginPlay()
{
	local Rx_BuildingObjective BO;

	if(MyBuildingObjectives.Length <= 0)
	{
		foreach WorldInfo.AllNavigationPoints(class'Rx_BuildingObjective',BO)
		{
			if(BO != None)
			{
				MyBuildingObjectives.AddItem(BO);
			}
		}
	}
}

function bool DoTaskFor(Rx_Bot_Scripted B)
{
	local int i;
	local Rx_BuildingObjective BO;

	if(MyBuildingObjectives.Length <= 0)
		return false;

	foreach MyBuildingObjectives(BO)
	{
		if(BO.myBuilding.IsDestroyed() || BO.myBuilding.GetTeamNum() == B.GetTeamNum())
			MyBuildingObjectives.RemoveItem(BO);
	}

	if(MyBuildingObjectives.Length <= 0)
		return DoNextObjectiveFor(B);

	else if(Rx_BuildingObjective(B.Squad.SquadObjective) == None || Rx_BuildingObjective(B.Squad.SquadObjective).myBuilding.IsDestroyed())
	{
		i = Rand(MyBuildingObjectives.Length);
		B.CurrentBO = MyBuildingObjectives[i];
		B.Squad.SquadObjective = MyBuildingObjectives[i];
	}
	
	return B.CurrentBO.TellBotHowToDisable(B);


	
}