/*********************************************************
*
* File: Rx_Vehicle_Apache.uc
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
class Rx_Vehicle_Apache extends Rx_Vehicle_Air
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
		Mesh.AttachComponentToSocket(TailRotorAmbient, 'RotorSocket_Tail');
		Mesh.AttachComponentToSocket(TailRotorStart, 'RotorSocket_Tail');
		Mesh.AttachComponentToSocket(TailRotorStop, 'RotorSocket_Tail');
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
    if (SeatFiringMode(0,,true) == 0)
	{
		VehicleEvent('GunFire');

		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
		}
	}
	else if (SeatFiringMode(0,,true) == 1)
	{		
		if (GetBarrelIndex(SeatIndex) == 1)
		{
			VehicleEvent('FireLeft');
		}
		else if (GetBarrelIndex(SeatIndex) == 2)
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

    if (SeatFiringMode(0,,true) == 0)
	{
		PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
	}
	
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
		
	//toggle missle bays
	if(missleBayToggle == 2)
		missleBayToggle = 1;
	else
		missleBayToggle = 2;	

    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}

//Modified from the mammoth source to use missleBayToggle
//which switches between the 2 available missle bays
simulated function int GetBarrelIndex(int SeatIndex)
{
    return (SeatFiringMode(0,,true) == 0 ? 0 : missleBayToggle);
}

reliable server function ServerChangeSeat(int RequestedSeat)
{
	if ( RequestedSeat == 1 && Driver != None)
		return;
	super.ServerChangeSeat(RequestedSeat);
}

defaultproperties
{
    MaxDesireability = 0.8 // todo: reactivate when flying AI is fixed
    
    missleBayToggle = 0;
    ExitRadius=150.0
    
    GunCameraTag=CamViewGun

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    Begin Object Class=UDKVehicleSimChopper Name=SimObject
        MaxThrustForce=700.0
		MaxReverseForce=500.0 
        LongDamping=0.5
        MaxStrafeForce=400.0
        LatDamping=0.5
        MaxRiseForce=250.0
        UpDamping=0.6
        TurnTorqueFactor=9000.0
        TurnTorqueMax=10000.0
        TurnDamping=1.0
        MaxYawRate=1.25
        PitchTorqueFactor=2000.0
        PitchTorqueMax=300.0
        PitchDamping=0.5
        RollTorqueTurnFactor=3000.0
        RollTorqueStrafeFactor=600.0	// 1000
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

    COMOffset=(X=40,Z=0.0)

    BaseEyeheight=30
    Eyeheight=30
    bRotateCameraUnderVehicle=false
    CameraLag=0.28 //0.4
    LookForwardDist=290.0
    bLimitCameraZLookingUp=true

    AirSpeed=775.0
    MaxSpeed=1000.0 
    GroundSpeed=1100.0

    UprightLiftStrength=30.0
    UprightTorqueStrength=30.0

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
	
	bIsConsoleTurning=False
	bJostleWhileDriving=True
	
	SeekAimAheadModifier = 120
	SeekAccelrateModifier = 4


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

    Begin Object Name=CollisionCylinder
        CollisionHeight=+200.0
        CollisionRadius=+300.0
        Translation=(X=-40.0,Y=0.0,Z=40.0)
    End Object

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Apache.Meshes.SK_VH_Apache'
        AnimTreeTemplate=AnimTree'RX_VH_Apache.Anims.AT_VH_Apache'
        AnimSets.Add(AnimSet'RX_VH_Apache.Anims.AS_VH_Apache')
        PhysicsAsset=PhysicsAsset'RX_VH_Apache.Meshes.SK_VH_Apache_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_Apache.Meshes.MT_VH_Apache'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Apache.Meshes.SK_PTVH_Apache'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\
	Seats(0)={( GunClass=class'Rx_Vehicle_Apache_Weapon',
                GunSocket=("GunSocket","Missile_Left","Missile_Right"),
                TurretControls=(TurretPitch,TurretRotate,MissilePitch,MissileRotate),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=25),
                CameraOffset=-400,
                bSeatVisible=true,
                SeatBone=b_DriverLocation,
                SeatSocket=DriverSocket,
                SeatOffset=(X=0,Y=0,Z=0),
                SeatRotation=(Pitch=0,Yaw=0),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				// WeaponEffects=((SocketName=GunSocket),(SocketName=Missile_Left),(SocketName=Missile_Right))
                )}
				
	Seats(1)={( // GunClass=class'Rx_Vehicle_Apache_Passenger_Weapon',
				// TurretVarPrefix="Passenger",
                // GunSocket=("HellFireMissile_Left","HellFireMissile_Right"),
                // TurretControls=(HellFireMissilePitch),
				CameraTag=CamView3P_Passenger, //CamView3P 1P
                CameraBaseOffset=(Z=25),
                CameraOffset=-400,
                bSeatVisible=true,
                SeatBone=b_GunnerLocation,
                SeatSocket=GunnerSocket,
                SeatOffset=(X=0,Y=0,Z=0),
                SeatRotation=(Pitch=0,Yaw=0),
				// MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				// WeaponEffects=((SocketName=HellFireMissile_Left),(SocketName=HellFireMissile_Right))
                )}
            
    DrivingAnim=H_M_Seat_Apache



//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Apache.Materials.PhysMat_Apache_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Apache.Materials.PhysMat_Apache'

    RecoilTriggerTag = "GunFire"
	TailRotorTriggerTag = "EngineStart"
	TailRotorStopTag = "EngineStop"
    VehicleEffects(0)=(EffectStartTag="GunFire",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Gun',EffectSocket="GunSocket")
    VehicleEffects(1)=(EffectStartTag="FireLeft",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Left")
    VehicleEffects(2)=(EffectStartTag="FireRight",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Right")
	
	VehicleEffects(3)=(EffectStartTag="HellFire_Left",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="HellFireMissile_Left")
    VehicleEffects(4)=(EffectStartTag="HellFire_Right",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="HellFireMissile_Right")
    
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_01)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_02)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_01)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_02)

    VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_Exhaust',EffectSocket=Exhaust_L)
    VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_Exhaust',EffectSocket=Exhaust_R)

    VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_GroundEffect',EffectSocket=GroundEffectSocket)

    VehicleEffects(12)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_Blades_Blurred_Front',EffectSocket=RotorSocket_Top)
    VehicleEffects(13)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_Blades_Blurred_Rear',EffectSocket=RotorSocket_Tail)
	
	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(ApacheBladeRise),AnimRate=0.33,bAnimLoopLastSeq=false,AnimPlayerName=ApachePlayer)
	VehicleAnims(1)=(AnimTag=EngineStop,AnimSeqs=(ApacheBladeDrop),AnimRate=0.33,bAnimLoopLastSeq=false,AnimPlayerName=ApachePlayer)

//    ContrailEffectIndices=(2,3,4,5,13,14)
//    GroundEffectIndices=(7,8)

//    ReferenceMovementMesh=StaticMesh'RX_VH_Chinook.Mesh.S_Air_Wind_Ball'

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_F,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_FL,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_FR,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_Tail,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage4))
	DamageMorphTargets(4)=(InfluenceBone=MT_Engine_L,MorphNodeName=MorphNodeW_EngineLeft,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(5)=(InfluenceBone=MT_Engine_R,MorphNodeName=MorphNodeW_EngineRight,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_Apache.Sounds.SC_Apache_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_Apache.Sounds.SC_Apache_Start'
    ExitVehicleSound=SoundCue'RX_VH_Apache.Sounds.SC_Apache_Stop'
	
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Apache.Sounds.SC_Apache_Gun_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Apache.Sounds.SC_Apache_Gun_Stop'
	
    // Scrape sound.
    Begin Object Class=AudioComponent Name=BaseScrapeSound
        SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
    End Object
    ScrapeSound=BaseScrapeSound
    Components.Add(BaseScrapeSound);

    // Initialize sound parameters.
    EngineStartOffsetSecs=2.54
    EngineStopOffsetSecs=0.0
	
	
	Begin Object Class=AudioComponent name=TailRotorAmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Apache.Sounds.SC_TailRotor_Idle'
    End Object
    TailRotorAmbient=TailRotorAmbientSoundComponent
    Components.Add(TailRotorAmbientSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStartSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Apache.Sounds.SC_TailRotor_Start'
    End Object
    TailRotorStart=TailRotorStartSoundComponent
    Components.Add(TailRotorStartSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStopSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Apache.Sounds.SC_TailRotor_Stop'
    End Object
    TailRotorStop=TailRotorStopSoundComponent
    Components.Add(TailRotorStopSoundComponent)	
}