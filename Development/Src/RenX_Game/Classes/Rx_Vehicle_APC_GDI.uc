/*********************************************************
*
* File: Rx_Vehicle_APC_GDI.uc
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
class Rx_Vehicle_APC_GDI extends Rx_Vehicle_Treaded
    placeable;

    
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;

var SkeletalMeshComponent AntennaMeshR;
var SkeletalMeshComponent AntennaMeshL;
var SkeletalMeshComponent TowRingMeshFR;
var SkeletalMeshComponent TowRingMeshFL;
var SkeletalMeshComponent TowRingMeshBR;
var SkeletalMeshComponent TowRingMeshBL;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(AntennaMeshR,'AntennaSocket_R');
	Mesh.AttachComponentToSocket(AntennaMeshL,'AntennaSocket_L');
	Mesh.AttachComponentToSocket(TowRingMeshFR,'TowRingSocket_FR');
	Mesh.AttachComponentToSocket(TowRingMeshFL,'TowRingSocket_FL');
	Mesh.AttachComponentToSocket(TowRingMeshBR,'TowRingSocket_BR');
	Mesh.AttachComponentToSocket(TowRingMeshBL,'TowRingSocket_BL');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('BeamLarge'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshL.FindSkelControl('BeamLarge'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshFR.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshFL.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshBR.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshBL.FindSkelControl('Beam'));


	if(AntennaBeamControl != none)
	{
		AntennaBeamControl.EntireBeamVelocity = GetVelocity;
	}
}

/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
	return Velocity;
}


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    VehicleEvent('MainGun');
    
    if (!FiringAmbient.bWasPlaying)
    {
        FiringAmbient.Play();
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
            VehicleEvent('STOP_MainGun');
        }
    }

    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
}



DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=600
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.1 //0.25 //0.3
	LookForwardDist=350
    GroundSpeed=600
    AirSpeed=500	// 600
    MaxSpeed=800
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=25.0,y=0.0,z=-55.0)
    bUsesBullets = true
    bOkAgainstBuildings=false
    bSecondaryFireTogglesFirstPerson=true
	
	SprintTrackTorqueFactorDivident=0.95
	
	MaxSprintSpeedMultiplier=1.2
	
/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 6 
	VPReward(1) = 8 
	VPReward(2) = 10 
	VPReward(3) = 14 
	
	VPCost(0) = 30
	VPCost(1) = 60
	VPCost(2) = 120

/**Vet_HealthMod(0)=1 //600
Vet_HealthMod(1)=1.083334 //650 
Vet_HealthMod(2)=1.166667 //700
Vet_HealthMod(3)=1.333334 //800
	*/

Vet_HealthMod(0)=1 //600
Vet_HealthMod(1)=1.083334 //650 
Vet_HealthMod(2)=1.166667 //700
Vet_HealthMod(3)=1.25 //750	

Vet_SprintSpeedMod(0)=1
Vet_SprintSpeedMod(1)=1
Vet_SprintSpeedMod(2)=1.05
Vet_SprintSpeedMod(3)=1.15
	
// +X as opposed to *X
Vet_SprintTTFD(0)=0
Vet_SprintTTFD(1)=0
Vet_SprintTTFD(2)=0.05
Vet_SprintTTFD(3)=0.15

/**********************/

	CustomGravityScaling=1.5

    Begin Object Class=SVehicleSimTank Name=SimObject
        bClampedFrictionModel=true

        WheelSuspensionStiffness=200
        WheelSuspensionDamping=2.0
        WheelSuspensionBias=0.0

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
        EngineDamping=4.0
        InsideTrackTorqueFactor=0.37
        TurnInPlaceThrottle=0.25
        TurnMaxGripReduction=0.9925 //0.980
        TurnGripScaleRate=1.0
        MaxEngineTorque=10000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)



//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_APC_GDI.Mesh.SK_VH_GDI_APC'
        AnimTreeTemplate=AnimTree'RX_VH_APC_GDI.Anims.AT_VH_GDI_APC'
        PhysicsAsset=PhysicsAsset'RX_VH_APC_GDI.Mesh.SK_VH_GDI_APC_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_APC_GDI.Mesh.MT_VH_GDI_APC'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_APC_GDI.Mesh.SK_PTVH_GDI_APC'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshL
		SkeletalMesh=SkeletalMesh'RX_VH_APC_Nod.Mesh.SK_Antinna_Large'
		AnimTreeTemplate=AnimTree'RX_VH_APC_Nod.Anims.AT_Antinna_Large'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshL=SAntennaMeshL
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_APC_Nod.Mesh.SK_Antinna_Large'
		AnimTreeTemplate=AnimTree'RX_VH_APC_Nod.Anims.AT_Antinna_Large'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshR=SAntennaMeshR
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshFR
		SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.towring'
		AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshFR=STowRingMeshFR
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshFL
		SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.towring'
		AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshFL=STowRingMeshFL
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshBR
		SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.towring'
		AnimTreeTemplate=AnimTree'RX_VH_APC_GDI.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshBR=STowRingMeshBR
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshBL
		SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.towring'
		AnimTreeTemplate=AnimTree'RX_VH_APC_GDI.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshBL=STowRingMeshBL


	VehicleIconTexture=Texture2D'RX_VH_APC_GDI.UI.T_VehicleIcon_APC_GDI'
	MinimapIconTexture=Texture2D'RX_VH_APC_GDI.UI.T_MinimapIcon_APC_GDI'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_APC_GDI_Weapon',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraBaseOffset=(X=-50,Z=-20),
                CameraOffset=-400,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}
 
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger1",
                CameraTag=CamView3P,
                CameraOffset=-400,
                )}

    Seats(2)={( GunClass=none,
				TurretVarPrefix="Passenger2",
                CameraTag=CamView3P,
                CameraOffset=-400,
                )}

    Seats(3)={( GunClass=none,
				TurretVarPrefix="Passenger3",
                CameraTag=CamView3P,
                CameraOffset=-400,
                )}

    Seats(4)={( GunClass=none,
				TurretVarPrefix="Passenger4",
                CameraTag=CamView3P,
                CameraOffset=-400,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 2
    RightTreadIndex   = 1

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_APC_GDI.Materials.PhysMat_APC_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_APC_GDI.Materials.PhysMat_APC'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="Fire01")
    VehicleEffects(1)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_ShellCasing_Looping',EffectSocket="ShellCasingSocket")
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke02)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_APC_GDI.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_APC_F,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=120,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_APC_L,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=120,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_APC_R,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=120,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_APC_B,MorphNodeName=MorphNodeW_Back,LinkedMorphNodeName=none,Health=120,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
    
    Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Stop'

    EnterVehicleSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Start'
    ExitVehicleSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Stop'

    EngineStartOffsetSecs=2.0
    EngineStopOffsetSecs=1.0


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

   Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RB_Wheel_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=RB_Wheel_01

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RB_Wheel_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=RB_Wheel_02

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RB_Wheel_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=RB_Wheel_03

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RB_Wheel_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=RB_Wheel_04

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RB_Wheel_05
        BoneName="Wheel_RB_05"
        SkelControlName="Wheel_RB_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RB_Wheel_05

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LB_Wheel_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(5)=LB_Wheel_01

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LB_Wheel_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(6)=LB_Wheel_02

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LB_Wheel_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=LB_Wheel_03

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LB_Wheel_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=LB_Wheel_04

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LB_Wheel_05
        BoneName="Wheel_LB_05"
        SkelControlName="Wheel_LB_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=LB_Wheel_05

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LT_Wheel_Front
        BoneName="Wheel_LT_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=LT_Wheel_Front

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=LT_Wheel_Rear
        BoneName="Wheel_LT_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=LT_Wheel_Rear

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RT_Wheel_Front
        BoneName="Wheel_RT_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(12)=RT_Wheel_Front

    Begin Object Class=Rx_Vehicle_APC_GDI_Wheel Name=RT_Wheel_Rear
        BoneName="Wheel_RT_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(13)=RT_Wheel_Rear
}