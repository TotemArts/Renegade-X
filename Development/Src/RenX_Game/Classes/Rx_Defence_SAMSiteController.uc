class Rx_Defence_SAMSiteController extends Rx_Defence_GuardTowerController;

function bool IsTargetRelevant( Pawn thisTarget )
{
	if(Rx_Vehicle_Air(thisTarget) == None && Rx_Vehicle_Air_Jet(thisTarget) == None) {
		return false;
	}
	return super.IsTargetRelevant(thisTarget);
}

defaultproperties
{
}