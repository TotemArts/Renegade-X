class Rx_VehRolloutControllerAir extends Rx_VehRolloutController;

function GetRolloutNodes()
{
	local Rx_HelipadVehRolloutPendingNode navPoint;
	local Rx_HelipadVehRolloutNode parkingNode;

	ForEach WorldInfo.AllNavigationPoints(class'Rx_HelipadVehRolloutNode',parkingNode) {
		if(parkingNode.ScriptGetTeamNum() == TeamNum)
		{
			rolloutNodes.AddItem(parkingNode);
		}
	}
	ForEach WorldInfo.AllNavigationPoints(class'Rx_HelipadVehRolloutPendingNode',navPoint)
	{
		if(navPoint.ScriptGetTeamNum() == TeamNum)
		{
			rolloutPendingNode = navPoint;
		}
	}
}