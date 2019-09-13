class Rx_Controller_Coop extends Rx_Controller;

reliable server function Array<Rx_CoopObjective> GetCoopObjectives()
{
	local array<Rx_CoopObjective> COList;
	local Rx_CoopObjective CO;


	foreach WorldInfo.AllNavigationPoints(class'Rx_CoopObjective', CO)
	{
			COList.AddItem(CO);
	}

	return COList;
}

function bool ValidPTUse(Rx_BuildingAttachment_PT PT)	// we don't always have PT inside buildings, so validate if this PT is not owned by any buildings
{
	if ((PT.OwnerBuilding == None || IsInBuilding() == PT.OwnerBuilding.BuildingVisuals) && PT.GetTeamNum() == GetTeamNum())
		return true;
	else
		return false;
}