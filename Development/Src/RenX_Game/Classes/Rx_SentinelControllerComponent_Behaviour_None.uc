//=============================================================================
// No behaviour at all.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_None extends Rx_SentinelControllerComponent_Behaviour;

function BeginBehaviour()
{
	bEnemyIsVisible = false;
	Enemy = none;
	Focus = none;
}

defaultproperties
{
}