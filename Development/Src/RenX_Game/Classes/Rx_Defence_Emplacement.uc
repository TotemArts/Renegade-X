class Rx_Defence_Emplacement extends Rx_Vehicle
	abstract;

event bool DriverLeave(bool bForceLeave)
{
    local bool ret;
    
    if(ret && Controller != None && Rx_Bot(Controller) != None) {
        Rx_Bot(Controller).LeftVehicle();  
    }
    ret = super(UTVehicle).DriverLeave(bForceLeave);
    return ret;
}

// Rx_Defence_Emplacement don't count towards CapturePoints, no need to notify.
function NotifyCaptuePointsOfDied(byte FromTeam);
function NotifyCaptuePointsOfTeamChange(byte from, byte to);

simulated function bool CanEnterVehicle(Pawn P)
{
	if(P.GetTeamNum() != getTeamNum())
		return false;
	return super.CanEnterVehicle(P);	
}

DefaultProperties
{
	bBindable=false
}
