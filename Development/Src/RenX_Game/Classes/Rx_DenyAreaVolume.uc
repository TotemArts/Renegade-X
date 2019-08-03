class Rx_DenyAreaVolume extends Rx_AreaVolume placeable;

var() const bool bAllowInfantry;
var() const bool bAllowVehicles;
var() const bool bAllowAircraft;

function OutOfAreaActions(Actor Other, Controller PC) 
{
	`Logd("Deny Area Volume: OutOfAreaActions",, 'DevScript');

	if(Rx_Controller(PC).IsInPlayArea == true)
		return;

	if(UDKVehicle(Other) != None)
		UDKVehicle(Other).bAllowedExit = true;

	if(Rx_Controller(PC) != none) //are we a human
		AreaWarningEffects(false, PC);		
}

function InAreaActions(Actor Other, Controller PC)
{
	`Logd("Deny Area Volume: InAreaActions",, 'DevScript');

	if(Rx_Controller(PC).IsInPlayArea == false)
		return;

	if (UDKVehicle(Other) != None)
		UDKVehicle(Other).bAllowedExit = false;

	if(Rx_Controller(PC) != none)
		AreaWarningEffects(true, PC);
}

function bool PawnTypeAllowed(Pawn other)
{
	if (Rx_Vehicle_Air(other) != None) {
		// This is an aircraft
		return bAllowAircraft;
	}

	if (UDKVehicle(other) != None) {
		// This is a ground vehicle
		return bAllowVehicles;
	}

	// Not a vehicle nor an aircraft; must be infantry
	return bAllowInfantry;
}

function bool IsAcceptableAreaVolume(Rx_AreaVolume V, Pawn P)
{
	if(!super.IsAcceptableAreaVolume(V, P))
		Return false;

	if(Rx_DenyAreaVolume(V) == none)
		return false;

	return !Rx_DenyAreaVolume(V).PawnTypeAllowed(P);
}

DefaultProperties
{
	/** Allowed pawn types (allow all by default) */
	bAllowInfantry = true;
	bAllowVehicles = true;
	bAllowAircraft = true;
}
