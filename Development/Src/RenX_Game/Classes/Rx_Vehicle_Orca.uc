/*********************************************************
*
* File: Rx_Vehicle_Orca.uc
* Author: RenegadeX-Team
* Poject: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Orca extends Rx_Vehicle_Air
    placeable;



var int missleBayToggle;

/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;


/** Extra Vehicle Sound stuff **/
var name TailRotorTriggerTag; 			// Is the same as "EngineStart"
var name TailRotorStopTag; 				// Is the same as "EngineStop"

var() AudioComponent TailRotorAmbient;	// The looping sound for the tailrotor
var() AudioComponent TailRotorStart;	// The start up sound for the tailrotor
var() AudioComponent TailRotorStop;		// The rev down sound for the tailrotor

var name GunCameraTag;


simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

	if (Mesh != none && TailRotorAmbient != none)
	{
		Mesh.AttachComponentToSocket(TailRotorAmbient, 'TailRotorSocket');
		Mesh.AttachComponentToSocket(TailRotorStart, 'TailRotorSocket');
		Mesh.AttachComponentToSocket(TailRotorStop, 'TailRotorSocket');
	}
}

function ToggleCam()
{
	if(fpCamera)
	{
		fpCamera = false;
		Seats[0].CameraTag = tpCameraTag;
		OldPositions.Length=0;
		//Mesh.SetHidden(false);
		//Driver.Mesh.SetHidden(false);
		UTPlayercontroller(Controller).setFOV(85);
	}
	else
	{
		fpCamera = true;
		Seats[0].CameraTag = GunCameraTag;
		//Mesh.SetHidden(true);
		//Driver.Mesh.SetHidden(true);
		UTPlayercontroller(Controller).setFOV(50);
	}
}

simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (TailRotorTriggerTag == EventTag)
	{
		TailRotorStart.Play();
		SetTimer(1.22, false, 'PlayTailRotorSound');
	}
		
	if (TailRotorStopTag == EventTag)
	{
		TailRotorAmbient.Stop();
		TailRotorStop.Play();
	}
}

function PlayTailRotorSound()
{
	TailRotorAmbient.Play();
}


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{  

	if (SeatFiringMode(0,,true) == 1)
	{
		VehicleEvent('GunFire');

		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
		}
	}
	else if (SeatFiringMode(0,,true) == 0)
	{
		if (GetBarrelIndex(SeatIndex) == 2)
		{
			VehicleEvent('FireLeft');
		}
		else if (GetBarrelIndex(SeatIndex) == 1)
		{
			VehicleEvent('FireRight');
		}

	}

}
    
simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
    }
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponStoppedFiring(bViaReplication,SeatIndex);
    }
    
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
            VehicleEvent('STOP_GunFire');
        }
    }

//    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
}


//================================================
// COPIED from RxVehicle_MammothTank
// Attribute of a multi weapon vehicle, this code correctly identifies 
// the propper firing socket
//================================================
simulated function vector GetEffectLocation(int SeatIndex)
{
    local vector SocketLocation;
    local name FireTriggerTag;

    if ( Seats[SeatIndex].GunSocket.Length <= 0 )
        return Location;

    // toggle missle bays
    if(missleBayToggle == 1)
        missleBayToggle = 2;
    else
        missleBayToggle = 1;

    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}


// Modified from the mammoth source to use missleBayToggle
// which switches between the 2 available missle bays
simulated function int GetBarrelIndex(int SeatIndex)
{
    local int OldBarrelIndex;
    
    OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
    if (Weapon == none)
        return OldBarrelIndex;

    return (Weapon.CurrentFireMode == 1 ? 0 : missleBayToggle);
}






/*

//==============================================\\
// ALTERNATE HALO BANSHEE STYLE FLIGHT CONTROLS \\
//==============================================\\

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
    local bool bReverseThrottle;
    local UTConsolePlayerController ConsolePC;
    local rotator SteerRot, VehicleRot;
    local vector SteerDir, VehicleDir; // , AngVel
    local float VehicleHeading, SteerHeading, DeltaTargetHeading, Deflection;

    Throttle = InForward;
	Steering = InStrafe;
	Rise = InUp;

	ConsolePC = UTConsolePlayerController(Controller);

    if (InForward > 0)
    {
		Throttle = 1;
    }

    if (InForward < 0)
    {
		Throttle = -1;
    }


    ConsolePC = UTConsolePlayerController(Controller);
    if (ConsolePC != None)
    {
        Steering = FClamp(Steering * ConsoleSteerScale, -1.0, 1.0);

        UpdateLookSteerStatus();

        // tank, wheeled / heavy vehicles will use this

        // If we desire 'look steering' on this vehicle, do it here.
//        if (bUsingLookSteer && IsHumanControlled())
//        {
            // If there is a deflection, look at the angle that its point in.
            Deflection = Sqrt(Throttle*Throttle + Steering*Steering);

            if(bStickDeflectionThrottle)
            {
                // The region we consider 'reverse' is anything below DeflectionReverseThresh, or anything withing the triangle below the center position.
                bReverseThrottle = ((Throttle < DeflectionReverseThresh) || (Throttle < 0.0 && Abs(Steering) < -Throttle));
                
				Deflection = Sqrt(Throttle*Throttle + Steering*Steering);
				Throttle = Deflection;

                if (bReverseThrottle)
                {
                    Throttle *= -1;
                }
            }
			

            VehicleRot.Yaw = Rotation.Yaw;
            VehicleDir = vector(VehicleRot);

            SteerRot.Yaw = DriverViewYaw;
            SteerRot.Pitch = DriverViewPitch;
            SteerDir = vector(SteerRot);

            VehicleHeading = GetHeadingAngle(VehicleDir);
            SteerHeading = GetHeadingAngle(SteerDir);
            DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);
			

            if (DeltaTargetHeading > LookSteerDeadZone)
            {
                Steering = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
                // Rise = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
            }
            else if (DeltaTargetHeading < -LookSteerDeadZone)
            {
                Steering = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
                // Rise = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
            }
            else
            {
                Steering = 0.0;
            }
			
			
        // Reverse steering when reversing
            if (Throttle < 0.0 && ForwardVel < 0.0)
            {
                Steering = -1.0 * Steering;
            }
//		}
        // `log( "Throttle: " $ Throttle $ " Steering: " $ Steering );
    }
}

*/


reliable server function ServerChangeSeat(int RequestedSeat)
{
	if ( RequestedSeat == 1 && Driver != None)
		return;
	super.ServerChangeSeat(RequestedSeat);
}


defaultproperties
{
    MaxDesireability = 0.8
    
    missleBayToggle = 0;
    ExitRadius=150.0

    // Helicopter Phyics
	Begin Object Class=UDKVehicleSimChopper Name=SimObject
        MaxThrustForce=700.0
        MaxReverseForce=500.0
        LongDamping=0.5
        MaxStrafeForce=400.0
        LatDamping=0.5
        MaxRiseForce=300.0
        UpDamping=0.6
        TurnTorqueFactor=9000.0
        TurnTorqueMax=10000.0
        TurnDamping=1.0
        MaxYawRate=1.25
        PitchTorqueFactor=2000.0
        PitchTorqueMax=300.0
        PitchDamping=0.5
        RollTorqueTurnFactor=8500.0
        RollTorqueStrafeFactor=750.0
        RollTorqueMax=3000.0
        RollDamping=1.0
        MaxRandForce=30.0
        RandForceInterval=0.5
        StopThreshold=10
		bAllowZThrust False
		bFullThrustOnDirectionChange False
        bShouldCutThrustMaxOnImpact=true
		bStabilizeStops=false
    End Object
    SimObj=SimObject
    Components.Add(SimObject)

    Health=400
    bLightArmor=true
    bFollowLookDir=false

    COMOffset=(X=50,Z=-50.0)

    BaseEyeheight=0
    Eyeheight=0
    bRotateCameraUnderVehicle=false
    CameraLag=0.2
    LookForwardDist=290.0
    bLimitCameraZLookingUp=true

    AirSpeed=775.0
    MaxSpeed=1000.0
    GroundSpeed=1100.0

    bStayUpright=true
    StayUprightRollResistAngle=5.0
    StayUprightPitchResistAngle=5.0
    StayUprightStiffness=1200
    StayUprightDamping=20

    SpawnRadius=180.0
    RespawnTime=5.0

    PushForce=50000.0
    HUDExtent=140.0

    HornIndex=1
	
	CustomGravityScaling=1.0	// 0.35
	
	SeekAimAheadModifier = 180
	SeekAccelrateModifier = 16

	GunCameraTag=CamViewGun

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

    Begin Object Name=CollisionCylinder
        //CollisionHeight=+200.0
        CollisionRadius=+300.0
        Translation=(X=-40.0,Y=0.0,Z=40.0)
    End Object

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Orca.Mesh.SK_VH_Orca'
        AnimTreeTemplate=AnimTree'RX_VH_Orca.Anims.AT_VH_Orca'
        PhysicsAsset=PhysicsAsset'RX_VH_Orca.Mesh.SK_VH_Orca_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Orca.Mesh.SK_PTVH_Orca'

	VehicleIconTexture=Texture2D'RX_VH_Orca.UI.T_VehicleIcon_Orca'
	MinimapIconTexture=Texture2D'RX_VH_Orca.UI.T_MinimapIcon_Orca'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

    Seats(0)={( GunClass=class'Rx_Vehicle_Orca_Weapon',
                GunSocket=("GunSocket","Missile_Left","Missile_Right"),
                TurretControls=(TurretPitch,TurretRotate,MissilePitch,MissileRotate),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=25),
                CameraOffset=-450, //-700,
                SeatIconPos=(X=0.5,Y=0.33),
                bSeatVisible=true,
                SeatBone=b_DriverLocation,
                SeatSocket=DriverSocket,
                SeatOffset=(X=0,Y=0,Z=0),
                SeatRotation=(Pitch=0,Yaw=0),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
                )}
				
	Seats(1)={( // GunClass=class'Rx_Vehicle_Orca_Passenger_Weapon',
				// TurretVarPrefix="Passenger",
                // GunSocket=("Missile_Left","Missile_Right"),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=25),
                CameraOffset=-400,
                bSeatVisible=true,
                SeatBone=b_DriverLocation,
                SeatSocket=PassengerSocket,
                SeatOffset=(X=59,Y=0,Z=-18),
                SeatRotation=(Pitch=0,Yaw=0),
				// MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				// WeaponEffects=((SocketName=HellFireMissile_Left),(SocketName=HellFireMissile_Right))
                )}
            
    DrivingAnim=H_M_Seat_Apache



//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Orca.Materials.MI_VH_Orca_BO'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Orca.Materials.MI_VH_Orca_BO'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Orca.Materials.PhysMat_Orca_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Orca.Materials.PhysMat_Orca'

    RecoilTriggerTag = "GunFire"
	TailRotorTriggerTag = "EngineStart"
	TailRotorStopTag = "EngineStop"
    VehicleEffects(0)=(EffectStartTag="GunFire",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Gun',EffectSocket="GunSocket")
    VehicleEffects(1)=(EffectStartTag="FireLeft",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Left")
    VehicleEffects(2)=(EffectStartTag="FireRight",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Right")
	
	VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet',EffectSocket=TurbineJetSocket_R)
	VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet',EffectSocket=TurbineJetSocket_L)
    
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_01)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_02)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_01)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_02)

    VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Exhaust',EffectSocket=Exhaust_L)
    VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Exhaust',EffectSocket=Exhaust_R)

    VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_GroundEffect',EffectSocket=GroundEffectSocket_R)
	VehicleEffects(12)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_GroundEffect',EffectSocket=GroundEffectSocket_L)
	
	VehicleEffects(13)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipA)
	VehicleEffects(14)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipB)
	VehicleEffects(15)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipC)
	VehicleEffects(16)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipD)
    

//    ContrailEffectIndices=(2,3,4,5,13,14)
//    GroundEffectIndices=(7,8)

//    ReferenceMovementMesh=StaticMesh'RX_VH_Chinook.Mesh.S_Air_Wind_Ball'

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air')
    BigExplosionSocket=VH_Death


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Start'
    ExitVehicleSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Stop'
	
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Gun_Looping'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Stop'

    // Scrape sound.
    Begin Object Class=AudioComponent Name=BaseScrapeSound
        SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
    End Object
    ScrapeSound=BaseScrapeSound
    Components.Add(BaseScrapeSound);

    // Initialize sound parameters.
    EngineStartOffsetSecs=3.34
    EngineStopOffsetSecs=0.0
	
	
	Begin Object Class=AudioComponent name=TailRotorAmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Idle'
    End Object
    TailRotorAmbient=TailRotorAmbientSoundComponent
    Components.Add(TailRotorAmbientSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStartSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Start'
    End Object
    TailRotorStart=TailRotorStartSoundComponent
    Components.Add(TailRotorStartSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStopSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Stop'
    End Object
    TailRotorStop=TailRotorStopSoundComponent
    Components.Add(TailRotorStopSoundComponent)	
}