class Rx_PlayAreaVolume extends Rx_AreaVolume placeable;
var() const int PlayAreaGroupID;

function OutOfAreaActions(Actor Other, Controller PC) 
{
	`Logd("Play Area Volume: OutOfAreaActions",, 'DevScript');

	if(UDKVehicle(Other) != None)
		UDKVehicle(Other).bAllowedExit = false;

	if(Rx_Controller(PC) != none) //are we a human
		AreaWarningEffects(true, PC);		
}

function InAreaActions(Actor Other, Controller PC)
{
	`Logd("Play Area Volume: InAreaActions",, 'DevScript');

	if (UDKVehicle(Other) != None)
		UDKVehicle(Other).bAllowedExit = true;

	if(Rx_Controller(PC) != none)
		AreaWarningEffects(false, PC);
}

function bool IsAcceptableAreaVolume(Rx_AreaVolume V, Pawn P)
{
	if (!super.IsAcceptableAreaVolume(V, P))
		Return false;

	if (Rx_PlayAreaVolume(V) == none)
		return false;

	if (V == self)
		return false;

	return true;
}

DefaultProperties
{
}
