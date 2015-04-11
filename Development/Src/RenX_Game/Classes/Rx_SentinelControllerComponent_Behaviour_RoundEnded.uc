//=============================================================================
// Doing nothing because the round has ended.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_RoundEnded extends Rx_SentinelControllerComponent_Behaviour_None;

function ComponentTick()
{
	//Ensures controller is destroyed before next level loads.
	if(WorldInfo.IsInSeamlessTravel())
	{
		if(Cannon != none)
		{
			Cannon.Destroy();
		}

		Destroy();
	}
}

defaultproperties
{
}