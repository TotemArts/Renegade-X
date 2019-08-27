class Rx_CoopObjective_DestroyBuilding extends Rx_CoopObjective
	placeable;

var(Building) Rx_BuildingObjective myBuildingObjective;

function bool TellBotHowToDisable(UTBot B)
{
	return myBuildingObjective.TellBotHowToDisable(B);
}

function bool TellBotHowToHeal(UTBot B)
{
	return myBuildingObjective.TellBotHowToHeal(B);
}

function bool IsDisabled()
{
	return myBuildingObjective.IsDisabled();
}

DefaultProperties
{
	bAnnounceFinish = true
	bAnnounceCompletingPlayer = true
	CompletionMessage = "has destroyed the building!"

	BonusVP = 100;
	TeamBonusVP = 400;
}