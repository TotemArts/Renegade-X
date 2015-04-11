
class Rx_VehicleSeatPawn extends UTWeaponPawn;

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super(UDKWeaponPawn).PossessedBy(C,bVehicleTransition);
	SetBaseEyeHeight();
	Eyeheight = BaseEyeheight;
}

simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{
    local vector out_CamStart;

	if (MyVehicle != None && MySeatIndex > 0 && MySeatIndex < MyVehicle.Seats.length)
	{
		UTVehicle(MyVehicle).VehicleCalcCamera(fDeltaTime, MySeatIndex, out_CamLoc, out_CamRot, out_CamStart);
		return true;
	}
	else
	{
		return Super(UDKWeaponPawn).CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}
}

simulated function SwitchWeapon(byte NewGroup)
{
	if(UTPlayerController(Controller) == None || (!Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bAltPressed 
			&& !Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bCntrlPressed)) {	
		super.SwitchWeapon(NewGroup);
	}
}

defaultproperties
{

}
