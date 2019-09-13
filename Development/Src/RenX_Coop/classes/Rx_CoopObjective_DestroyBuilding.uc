class Rx_CoopObjective_DestroyBuilding extends Rx_CoopObjective
	placeable;

var(Building) Rx_BuildingObjective myBuildingObjective;

simulated function Vector GetWaypointLocation()
{
	if(VisualIndicatedActor != None)
		return VisualIndicatedActor.Location;

	else if (myBuildingObjective != None && myBuildingObjective.myBuilding != None)
		return myBuildingObjective.myBuilding.Location;

	return Location;
}

simulated function Color GetIndicatorColor()
{
	local Color myColor;

	if(myBuildingObjective == None || myBuildingObjective.myBuilding == None)	
		return Super.GetIndicatorColor();

	if(myBuildingObjective.myBuilding.GetTeamNum() != Rx_Game_Cooperative(WorldInfo.Game).GetPlayerTeam())
	{
		MyColor.R = 255;
		MyColor.G = 20;
		MyColor.B = 20;
	}
	else
	{
		MyColor.R = 20;
		MyColor.G = 255;
		MyColor.B = 20;
	}

	MyColor.A = 0;	// ignore this

	return myColor;
}

function bool TellBotHowToDisable(UTBot B)
{
	return myBuildingObjective.TellBotHowToDisable(B);
}

function bool TellBotHowToHeal(UTBot B)
{
	return myBuildingObjective.TellBotHowToHeal(B);
}

simulated function SetDefenderTeam()
{
	DefenderTeamIndex = myBuildingObjective.myBuilding.ScriptGetTeamNum();
}


DefaultProperties
{
	bAnnounceFinish = true
	bAnnounceCompletingPlayer = true
	CompletionMessage = "has destroyed the building!"

	BonusVP = 100;
	TeamBonusVP = 400;
}