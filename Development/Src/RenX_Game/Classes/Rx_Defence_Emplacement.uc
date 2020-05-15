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
function NotifyCaptuePointsOfTeamChange();

simulated function bool CanEnterVehicle(Pawn P)
{
	if(P.GetTeamNum() != getTeamNum())
		return false;
	return super.CanEnterVehicle(P);	
}

DefaultProperties
{
	bBindable=false
	
	/*Veterancy */
	VRank=0
	
	//VP Given on death (by VRank)

	VPReward(0) = 0
	VPReward(1) = 0
	VPReward(2) = 0
	VPReward(3) = 0
	
	/*************/

	VPCost(0) = 30
	VPCost(1) = 60
	VPCost(2) = 120
	
	Vet_HealthMod(0)=1
	Vet_HealthMod(1)=1.25 //500
	Vet_HealthMod(2)=1.5 //600
	Vet_HealthMod(3)=1.75 //700
	
	Vet_SprintSpeedMod(0)=1.0
	Vet_SprintSpeedMod(1)=1.0
	Vet_SprintSpeedMod(2)=1.0
	Vet_SprintSpeedMod(3)=1.0
	
	
	/**************************/
	
	bCanBePromoted = false  
}
