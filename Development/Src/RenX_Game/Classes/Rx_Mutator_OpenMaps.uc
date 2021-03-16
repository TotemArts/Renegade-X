class Rx_Mutator_OpenMaps extends Rx_Mutator;

function bool CheckReplacement(Actor Other)
{
	if (Rx_TeamInfo(Other) != None)
	{
		Rx_Game(WorldInfo.Game).EndRxGame("triggered", 0);
	}

	return true;
}