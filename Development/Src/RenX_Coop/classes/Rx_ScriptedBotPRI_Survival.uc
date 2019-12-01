class Rx_ScriptedBotPRI_Survival extends Rx_ScriptedBotPRI;

simulated function byte GetRadarVisibility()
{
	if(Rx_GRI_Survival(WorldInfo.GRI) != None && Rx_GRI_Survival(WorldInfo.GRI).bNearWaveEnd)
		return 2;

	return super.GetRadarVisibility();
}