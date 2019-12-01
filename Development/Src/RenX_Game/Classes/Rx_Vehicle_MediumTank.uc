/*********************************************************
*
* File: Rx_Vehicle_MediumTank.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_MediumTank extends Rx_Vehicle_Treaded
    placeable;
	
var SkeletalMeshComponent AntennaMeshL;
var SkeletalMeshComponent AntennaMeshR;

/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;
var repnotify bool bPlayingAmbientFireSound; 

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;

replication
{
    if (bNetDirty && !bNetOwner)
		bPlayingAmbientFireSound;
}

simulated event ReplicatedEvent(Name VarName)
{
    if (VarName == 'bPlayingAmbientFireSound')
	{
		if(bPlayingAmbientFireSound)
			FiringAmbient.Play();
		else
		{
			FiringAmbient.Stop();
		}
	}
    else 
		super.ReplicatedEvent(VarName);
}

/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    Mesh.AttachComponentToSocket(FlagAmbient, 'AntennaSocket_R');

	Mesh.AttachComponentToSocket(AntennaMeshL,'AntennaSocket_L');
	Mesh.AttachComponentToSocket(AntennaMeshR,'AntennaSocket_R');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshL.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('Beam'));

	if (AntennaBeamControl != none)
	{
		AntennaBeamControl.EntireBeamVelocity = GetVelocity;
	}
}

/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
	return Velocity;
}

simulated function vector GetEffectLocation(int SeatIndex)
{

    local vector SocketLocation;
    local name FireTriggerTag;

    if (Seats[SeatIndex].GunSocket.Length <= 0)
        return Location;

    //`Log("GetEffectLocation called",, '_Mammoth_Debug');
    
    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];
    
    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);
    
     //if (Weapon.CurrentFireMode == 0)
     //   ShotCount = ShotCounts >= 255 ? 0 : ShotCounts + 1;
    //  else
    //     AltShotCounts = AltShotCounts >= 255 ? 0 : AltShotCounts + 1;
    return SocketLocation;
}

// special for mammoth
simulated event GetBarrelLocationAndRotation(int SeatIndex, out vector SocketLocation, optional out rotator SocketRotation)
{
    if (Seats[SeatIndex].GunSocket.Length > 0)
    {
        Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)], SocketLocation, SocketRotation);
    }
    else
    {
        SocketLocation = Location;
        SocketRotation = Rotation;
    }
}

simulated function int GetBarrelIndex(int SeatIndex)
{
    local int OldBarrelIndex;
    
    OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
    if (Weapon == none)
        return OldBarrelIndex;

    return (Weapon.CurrentFireMode == 0 ? OldBarrelIndex % 1 : (OldBarrelIndex % 1) + 1);
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
	Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);
	
	if (Weapon != none && Weapon.CurrentFireMode == 1)
	{
		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
			VehicleEvent('AltGun');
		}
	}
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
    }
	
	if(ROLE == ROLE_Authority && Weapon.CurrentFireMode == 1)
	{
		bPlayingAmbientFireSound = true; 
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
            VehicleEvent('STOP_AltGun');
        }

    }
		if(Weapon != none && Weapon.CurrentFireMode == 1)
		{
			PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
			FiringAmbient.Stop();
		}
	
	if(ROLE == ROLE_Authority && Weapon.CurrentFireMode == 1)
	{
		bPlayingAmbientFireSound = false; 
	}
		
}
	

    
DefaultProperties
{

    Begin Object Name=CollisionCylinder
    CollisionHeight=75.0
    CollisionRadius=200.0
    Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    bRotateCameraUnderVehicle=true
    bSecondaryFireTogglesFirstPerson=false
    Health=800
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.4
    LookForwardDist=350
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=0
    COMOffset=(x=-21.0,y=0.0,z=-42.0)
	
	SprintTrackTorqueFactorDivident=1.05
	
	Heroic_MuzzleFlash=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash_Heroic'
	
	BarrelLength(0)=450
	BarrelLength(1)=100
	BarrelLength(2)=100
	BarrelLength(3)=100
	BarrelLength(4)=100
	BarrelLength(5)=100

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16 
	
	VPCost(0) = 30
	VPCost(1) = 70
	VPCost(2) = 150

	Vet_HealthMod(0)=1 //800
	Vet_HealthMod(1)=1.125 //900 
	Vet_HealthMod(2)=1.25 //1000
	Vet_HealthMod(3)=1.375 //1100
		
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1
	Vet_SprintSpeedMod(2)=1.05
	Vet_SprintSpeedMod(3)=1.10
		
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)=0
	Vet_SprintTTFD(2)=0.10
	Vet_SprintTTFD(3)=0.15

/**********************/
	
    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=40
        WheelSuspensionDamping=2.0
        WheelSuspensionBias=0.2

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.5
        WheelLongExtremumValue=2.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
           WheelLatExtremumSlip=0.5 //0.35     // 20 degrees
        WheelLatExtremumValue=4.0
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=4
        InsideTrackTorqueFactor=0.375
        TurnInPlaceThrottle=0.225
        TurnMaxGripReduction=0.995
        TurnGripScaleRate=0.8
        MaxEngineTorque=8000
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_VH_MediumTank'
        AnimTreeTemplate=AnimTree'RX_VH_MediumTank.Anims.AT_VH_MediumTank'
        PhysicsAsset=PhysicsAsset'RX_VH_MediumTank.Mesh.SK_VH_MediumTank_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_MediumTank.Mesh.MT_VH_MediumTank'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_PTVH_MediumTank'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshL
		SkeletalMesh=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_Antenna_Left'
		AnimTreeTemplate=AnimTree'RX_VH_MediumTank.Anims.AT_Antenna_Left'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshL=SAntennaMeshL
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_Antenna_Right'
		AnimTreeTemplate=AnimTree'RX_VH_MediumTank.Anims.AT_Antenna_Right'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshR=SAntennaMeshR

	VehicleIconTexture=Texture2D'RX_VH_MediumTank.UI.T_VehicleIcon_MediumTank'
	MinimapIconTexture=Texture2D'RX_VH_MediumTank.UI.T_MinimapIcon_MediumTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_MediumTank_Weapon',
                GunSocket=("Fire01", "MGFireSocket"),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraBaseOffset=(Z=20),
                CameraOffset=-460,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
	Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
				CameraTag=CamView3P,
				CameraBaseOffset=(Z=20),
				CameraOffset=-460,
				)}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="Fire01")
    VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke02)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks01)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks02)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire02)
    VehicleEffects(9)=(EffectStartTag="AltGun",EffectEndTag="STOP_AltGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="MGFireSocket")

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Snow_Small')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Stone')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_WhiteSand_Small')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_YellowSand_Small')
	DefaultWheelPSCTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_MediumTank.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Chassis_Front,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Chassis_Front_Left,MorphNodeName=MorphNodeW_Ch_FL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(2)=(InfluenceBone=MT_Chassis_Front_Right,MorphNodeName=MorphNodeW_Ch_FR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=MT_Chassis_Rear,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(4)=(InfluenceBone=MT_Chassis_Rear_Left,MorphNodeName=MorphNodeW_Ch_BL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(5)=(InfluenceBone=MT_Chassis_Rear_Right,MorphNodeName=MorphNodeW_Ch_BR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(6)=(InfluenceBone=MT_Chassis_Left,MorphNodeName=MorphNodeW_Ch_L,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=MT_Chassis_Right,MorphNodeName=MorphNodeW_Ch_R,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(8)=(InfluenceBone=MT_Turret_Rear_Left,MorphNodeName=MorphNodeW_Tu_BL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(9)=(InfluenceBone=MT_Turret_Rear_Right,MorphNodeName=MorphNodeW_Tu_BR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(10)=(InfluenceBone=MT_Turret_Left,MorphNodeName=MorphNodeW_Tu_L,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(11)=(InfluenceBone=MT_Turret_Right,MorphNodeName=MorphNodeW_Tu_R,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(12)=(InfluenceBone=MT_Turret_Front_Right,MorphNodeName=MorphNodeW_Tu_FR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(13)=(InfluenceBone=MT_Turret_Front_Left,MorphNodeName=MorphNodeW_Tu_FL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=2.0)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_MediumTank.Sounds.Med_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_stopCue'

	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_MediumTank.Sounds.SC_MediumTank_MG'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Stop' //SoundCue'RX_VH_MediumTank.Sounds.SC_MediumTank_MG_Stop'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=RB_Wheel_01

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=RB_Wheel_02

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=RB_Wheel_03

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=RB_Wheel_04

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_05
        BoneName="Wheel_RB_05"
        SkelControlName="Wheel_RB_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RB_Wheel_05

     Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_06
        BoneName="Wheel_RB_06"
        SkelControlName="Wheel_RB_06_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=RB_Wheel_06

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RB_Wheel_07
        BoneName="Wheel_RB_07"
        SkelControlName="Wheel_RB_07_Cont"
        Side=SIDE_Right
    End Object
    Wheels(6)=RB_Wheel_07

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=LB_Wheel_01

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=LB_Wheel_02

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=LB_Wheel_03

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=LB_Wheel_04

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_05
        BoneName="Wheel_LB_05"
        SkelControlName="Wheel_LB_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=LB_Wheel_05

     Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_06
        BoneName="Wheel_LB_06"
        SkelControlName="Wheel_LB_06_Cont"
        Side=SIDE_Left
    End Object
    Wheels(12)=LB_Wheel_06

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LB_Wheel_07
        BoneName="Wheel_LB_07"
        SkelControlName="Wheel_LB_07_Cont"
        Side=SIDE_Left
    End Object
    Wheels(13)=LB_Wheel_07

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LT_Wheel_Front
        BoneName="Wheel_LT_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(14)=LT_Wheel_Front

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LT_Wheel_Rear
        BoneName="Wheel_LT_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(15)=LT_Wheel_Rear

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RT_Wheel_Front
        BoneName="Wheel_RT_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(16)=RT_Wheel_Front

    Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RT_Wheel_Rear
        BoneName="Wheel_RT_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=RT_Wheel_Rear
}
