//=============================================================================
// Attacking any pawn. For debugging only.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_DebugTargetingPawn extends Rx_SentinelControllerComponent_Behaviour_TargetingPawn;

function BeginBehaviour()
{
	Focus = Enemy;
	bSeeFriendly = true;
}

function EndBehaviour()
{
	ClearTimer('NotVisibleTimer');
	bSeeFriendly = false;
}

function bool PossiblyTarget(Pawn PotentialTarget, optional bool bOnlyFastTrace, optional int ExtraWeight)
{
	if(PotentialTarget == none || PotentialTarget.bDeleteMe || PotentialTarget.Health <= 0 || PotentialTarget.DrivenVehicle != none)
		return false;

	//Don't target pawns outside of range.
	if(VSize(PotentialTarget.Location - Cannon.Location) > Cannon.GetRange())
		return false;

	//Always change if current target is dead or nonexistent.
	if(Enemy == none || Enemy.Health <= 0)
		return true;

	//Keep attacking until they go away.
	if(PotentialTarget == Enemy)
		return true;

	return false;
}

defaultproperties
{
}