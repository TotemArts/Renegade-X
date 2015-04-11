/*********************************************************
*
* File: Rx_Vehicle_Air.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
* Base class for vehicles that fly or hover.
*********************************************************/
class Rx_Vehicle_Air extends Rx_Vehicle
    abstract;

var float MaxStrafeForce;
var float MaxRiseForce;
var float MaxYawRate;
var float RollTorqueStrafeFactor;
var float PitchTorqueFactor;

var bool bAutoLand;
var float PushForce;    // for AI when landing;

var localized string RadarLockMessage;  /** Displayed when enemy raptor fires locked missile at you */

var float LastRadarLockWarnTime;

simulated event LockOnWarning(UDKProjectile IncomingMissile)
{
    SendLockOnMessage(1);
}

reliable server function IncreaseSprintSpeed()
{
	local float SprintSpeed_Max;

	Super.IncreaseSprintSpeed();

	SprintSpeed_Max = Default.MaxSpeed * MinSprintSpeedMultiplier;

	if(PlayerController(Controller) != None)
	{
		ServerSetMaxSpeed(SprintSpeed_Max);
	}

	MaxSpeed = SprintSpeed_Max;

	if(UDKVehicleSimChopper(SimObj) != None)
	{
		UDKVehicleSimChopper(SimObj).MaxStrafeForce = UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce * MaxStrafeForce;
		UDKVehicleSimChopper(SimObj).MaxRiseForce = UDKVehicleSimChopper(SimObj).Default.MaxRiseForce * MaxRiseForce;
		UDKVehicleSimChopper(SimObj).MaxYawRate = UDKVehicleSimChopper(SimObj).Default.MaxYawRate * MaxYawRate;
		UDKVehicleSimChopper(SimObj).RollTorqueStrafeFactor = UDKVehicleSimChopper(SimObj).Default.RollTorqueStrafeFactor * RollTorqueStrafeFactor;
		UDKVehicleSimChopper(SimObj).PitchTorqueFactor = UDKVehicleSimChopper(SimObj).Default.PitchTorqueFactor * PitchTorqueFactor;
	}
}
reliable server function DecreaseSprintSpeed()
{
	Super.DecreaseSprintSpeed();

	if(PlayerController(Controller) != None)
	{
		ServerSetMaxSpeed(MaxSpeed);
	}

	MaxSpeed = Default.MaxSpeed;

	if(UDKVehicleSimChopper(SimObj) != None)
	{
		UDKVehicleSimChopper(SimObj).MaxStrafeForce = UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce;
		UDKVehicleSimChopper(SimObj).MaxRiseForce = UDKVehicleSimChopper(SimObj).Default.MaxRiseForce;
		UDKVehicleSimChopper(SimObj).MaxYawRate = UDKVehicleSimChopper(SimObj).Default.MaxYawRate;
		UDKVehicleSimChopper(SimObj).RollTorqueStrafeFactor = UDKVehicleSimChopper(SimObj).Default.RollTorqueStrafeFactor;
		UDKVehicleSimChopper(SimObj).PitchTorqueFactor = UDKVehicleSimChopper(SimObj).Default.PitchTorqueFactor;
	}
}

simulated function SetDriving(bool bNewDriving)
{
    if (!bNewDriving && bAutoLand && !bEMPd && !bChassisTouchingGround && Health > 0)
    {
        if (Role == ROLE_Authority)
        {
            GotoState('AutoLanding');
        }
    }
    else
    {
        Super.SetDriving(bNewDriving);
    }
}

/** state to automatically land when player jumps out while high above land */
state AutoLanding
{
    simulated function SetDriving(bool bNewDriving)
    {
        if ( bNewDriving )
        {
            GotoState('Auto');
            Global.SetDriving(bNewDriving);
        }
    }

    function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
    {
        if (Global.Died(Killer, DamageType, HitLocation))
        {
            SetDriving(false);
            return true;
        }
        else
        {
            return false;
        }
    }

    function Tick(float DeltaTime)
    {
        local actor HitActor;
        local vector HitNormal, HitLocation;

        if (bChassisTouchingGround)
        {
            GotoState('Auto');
            SetDriving(false);
        }
        else
        {
            HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2500), Location, false);
            if ( Velocity.Z < -1200 )
                OutputRise = 1.0;
            else if ( HitActor == None )
                OutputRise = -1.0;
            else if ( VSize(HitLocation - Location) < -2*Velocity.Z )
            {
                if ( Velocity.Z > -100 )
                    OutputRise = 0;
                else
                    OutputRise = 1.0;
            }
            else if ( Velocity.Z > -500 )
                OutputRise = -0.4;
            else
                OutputRise = -0.1;
        }
    }

	function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor)
	{
		if (super.EMPHit(InstigatedByController, EMPCausingActor))
		{
			GotoState('Auto');
			SetDriving(false);
			return true;
		}
		else
			return false;
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    if ( FRand() < 0.7 )
    {
        VehicleMovingTime = WorldInfo.TimeSeconds + 1;
        Rise = 1;
    }
    return false;
}

simulated function StartEngineSound()
{
	super.StartEngineSound();
	if(WorldInfo.Netmode == NM_DedicatedServer)
		SetTimer(1.0,true,'DamageVehicleSurfers');
}

simulated function StopEngineSound()
{	
	super.StopEngineSound();
	ClearTimer('DamageVehicleSurfers');
}

function DamageVehicleSurfers()
{
	local float DmgRadius;
	local Pawn P;
	
	DmgRadius=400.0;
	
	foreach CollidingActors(class'Pawn', P, DmgRadius, Location, false)
    {
    	if(self == P)
    		continue;
    	if(p.base == self)	
    		P.TakeDamage(10, none, P.Location, vect(0,0,1), class'UTDmgType_LinkBeam');	
    }
}

defaultproperties
{
	bSeparateTurretFocus=True
	
	MaxStrafeForce=0.25
	MaxRiseForce=0.25
	MaxYawRate=0.25
	RollTorqueStrafeFactor=0.25
	PitchTorqueFactor=1.3
	
	MinSprintSpeedMultiplier=1.0
	MaxSprintSpeedMultiplier=1.25
	SprintTimeInterval=1.0
	SprintSpeedIncrement=1.0
	
	bAutoLand=true
    ContrailColorParameterName=ContrailColor
    bNoZDampingInAir=false

    bReducedFallingCollisionDamage=true

    bCanStrafe=true
    bCanFly=true
    bTurnInPlace=true
    bFollowLookDir=true
    bDriverHoldsFlag=false
    bCanCarryFlag=false

    LookForwardDist=100.0
	
	bHomingTarget=True

    IconCoords=(U=989,V=24,UL=43,VL=48)

    bEjectPassengersWhenFlipped=false
    bMustBeUpright=false
    UpsideDownDamagePerSec=0.0
    
    bDropDetailWhenDriving=true
    bFindGroundExit=false

    //@todo: it would be nice if the alternate path code would count being in a VolumePathNode above the intended alternate path
    bUseAlternatePaths=true
    
    bJostleWhileDriving=true
    bFloatWhenDriven=true
}
