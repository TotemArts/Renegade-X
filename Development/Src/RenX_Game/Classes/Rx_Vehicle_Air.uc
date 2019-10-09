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
var repnotify bool bLockedYaw;

replication {
	if(bNetDirty && ROLE == ROLE_Authority)
		bLockedYaw;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bLockedYaw')
	{
		LockYaw(bLockedYaw); 
	}
	else
		super.ReplicatedEvent(VarName); 
}

simulated event LockOnWarning(UDKProjectile IncomingMissile)
{
    SendLockOnMessage(1);
}

reliable server function IncreaseSprintSpeed()
{
	local float SprintSpeed_Max;

	Super.IncreaseSprintSpeed();

	SprintSpeed_Max = Default.AirSpeed * MinSprintSpeedMultiplier * Vet_SprintSpeedMod[VRank]  * GetScriptedSpeedModifier(); //default.AirSpeed * MinSprintSpeedMultiplier; //Default.AirSpeed * MinSprintSpeedMultiplier;

	if(PlayerController(Controller) != None)
	{
		ServerSetMaxSpeed(SprintSpeed_Max);
	}

	MaxSpeed = SprintSpeed_Max;

	if(UDKVehicleSimChopper(SimObj) != None)
	{
		UDKVehicleSimChopper(SimObj).MaxStrafeForce = UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce * MaxStrafeForce;
		UDKVehicleSimChopper(SimObj).MaxRiseForce = UDKVehicleSimChopper(SimObj).Default.MaxRiseForce * MaxRiseForce;
		
		if(!bLockedYaw) 
			UDKVehicleSimChopper(SimObj).MaxYawRate = UDKVehicleSimChopper(SimObj).Default.MaxYawRate * MaxYawRate;
		
		UDKVehicleSimChopper(SimObj).RollTorqueStrafeFactor = UDKVehicleSimChopper(SimObj).Default.RollTorqueStrafeFactor * RollTorqueStrafeFactor;
		UDKVehicleSimChopper(SimObj).PitchTorqueFactor = UDKVehicleSimChopper(SimObj).Default.PitchTorqueFactor * PitchTorqueFactor;
	}
}
reliable server function DecreaseSprintSpeed()
{
	Super.DecreaseSprintSpeed();

	/**if(PlayerController(Controller) != None)
	{
		ServerSetAirSpeed(AirSpeed);
	}

	AirSpeed = Default.AirSpeed;
*/
	if(UDKVehicleSimChopper(SimObj) != None)
	{
		UDKVehicleSimChopper(SimObj).MaxStrafeForce = UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce;
		UDKVehicleSimChopper(SimObj).MaxRiseForce = UDKVehicleSimChopper(SimObj).Default.MaxRiseForce;
		
		if(!bLockedYaw)
			UDKVehicleSimChopper(SimObj).MaxYawRate = UDKVehicleSimChopper(SimObj).Default.MaxYawRate;
		else
			UDKVehicleSimChopper(SimObj).MaxYawRate = 0;	
		
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
			ServerLockYaw(false);
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

	simulated function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
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
    		P.TakeDamage(10, none, P.Location, vect(0,0,1), class'Rx_DmgType_Fell');	
    }
}

//set shadow frustum scale (nBab)
simulated function SetShadowboundsScale()
{
    MyLightEnvironment = DynamicLightEnvironmentComponent(Mesh.LightEnvironment);
    MyLightEnvironment.LightingBoundsScale = Rx_MapInfo(WorldInfo.GetMapInfo()).AirVehicleShadowBoundsScale;
    Mesh.SetLightEnvironment(MyLightEnvironment);
}

event Touch ( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
if(Rx_VehicleBlockingVolume(Other) != none) 
	return; 
else
	super.Touch(Other,OtherComp,HitLocation,HitNormal);
}

event UnTouch ( Actor Other)
{
if(Rx_VehicleBlockingVolume(Other) != none) 
	return; 
else
	super.UnTouch(Other);
}


simulated function LockYaw(bool Lock){
	local UDKVehicleSimChopper Chopper; 
	
	Chopper = UDKVehicleSimChopper(SimObj);
	
	if(SimObj == none) return; 
	
	if(Lock){
		Chopper.MaxYawRate = 0;
		//Chopper.RollTorqueMax = 0;
	}
	else {
		Chopper.MaxYawRate = Chopper.default.MaxYawRate;
		//Chopper.RollTorqueMax = Chopper.default.RollTorqueMax;
	}
} 

simulated function StartLockYaw(bool Lock){
		local UDKVehicleSimChopper Chopper; 
		
		Chopper = UDKVehicleSimChopper(SimObj);
	
	if(Chopper == none) return; 
	
	/**if(Lock){
		Chopper.MaxYawRate = 0;
		//Chopper.RollTorqueMax = 0;
	}
	else {
		Chopper.MaxYawRate = Chopper.default.MaxYawRate;
		//Chopper.RollTorqueMax = Chopper.default.RollTorqueMax;
	}*/
		bLockedYaw = Lock; 
		ServerLockYaw(Lock); 
}

reliable server function ServerLockYaw(bool Lock){
	local UDKVehicleSimChopper Chopper; 
	
	Chopper = UDKVehicleSimChopper(SimObj);
	
	if(Chopper == none) return; 
	
	if(Lock){
		Chopper.MaxYawRate = 0;
		//Chopper.RollTorqueMax = 0;
		
	}
	else {
		Chopper.MaxYawRate = Chopper.default.MaxYawRate;
		//Chopper.RollTorqueMax = Chopper.default.RollTorqueMax;
	}
	
	bLockedYaw = Lock; 
}

defaultproperties
{
	//nBab
    /*Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=true
        bUseBooleanEnvironmentShadowing=FALSE
        //setting shadow frustum scale (nBab)
        LightingBoundsScale=0.35
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)*/

    bSeparateTurretFocus=True
	
	MaxStrafeForce=0.25
	MaxRiseForce=0.25
	MaxYawRate=0.25
	RollTorqueStrafeFactor=0.25
	PitchTorqueFactor=1.3
	MomentumMult=0.55
	
	bisAircraft=true
	
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
	OccupiedUpsideDownDamagePerSec=0.0

    
    bDropDetailWhenDriving=true
    bFindGroundExit=false

    //@todo: it would be nice if the alternate path code would count being in a VolumePathNode above the intended alternate path
    bUseAlternatePaths=true
    
    bJostleWhileDriving=true
    bFloatWhenDriven=true
	
	BurnOutTime=1.5
	DeadVehicleLifeSpan=2.0
	
	SecondaryExplosion=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle'
	
	DestroyedRotatorAddend = (Pitch=0,Roll=50000,Yaw=8000) //Most aircraft here aren't single rotor, so roll more than yaw

}
