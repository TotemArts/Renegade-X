/*********************************************************
*
* File: Rx_Vehicle_LightTank.uc
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
class Rx_Vehicle_LightTank extends Rx_Vehicle_Treaded
    placeable;
	

var SkeletalMeshComponent AntennaMesh;
var SkeletalMeshComponent TowRingMeshA;
var SkeletalMeshComponent TowRingMeshB;
var SkeletalMeshComponent TowRingMeshC;
var SkeletalMeshComponent TowRingMeshD;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(AntennaMesh,'AntennaSocket');
	Mesh.AttachComponentToSocket(TowRingMeshA,'TowRingSocket_FL');
	Mesh.AttachComponentToSocket(TowRingMeshB,'TowRingSocket_FR');
	Mesh.AttachComponentToSocket(TowRingMeshC,'TowRingSocket_RL');
	Mesh.AttachComponentToSocket(TowRingMeshD,'TowRingSocket_RR');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMesh.FindSkelControl('BeamShort'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshA.FindSkelControl('TowRingBeam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshB.FindSkelControl('TowRingBeam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshC.FindSkelControl('TowRingBeam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRingMeshD.FindSkelControl('TowRingBeam'));

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

DefaultProperties
{

    Begin Object Name=CollisionCylinder
    CollisionHeight=80.0
    CollisionRadius=200.0
    Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=600
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.1 //0.25
	LookForwardDist=200
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-30.0)
    bSecondaryFireTogglesFirstPerson=true
	
	SprintTrackTorqueFactorDivident=1.1//1.035

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 6 //7 
	VPReward(1) = 8// 9 
	VPReward(2) = 10 //12 
	VPReward(3) = 13// 15 
	
	VPCost(0) = 30
	VPCost(1) = 60
	VPCost(2) = 120

Vet_HealthMod(0)=1 //600
Vet_HealthMod(1)=1.125 //675
Vet_HealthMod(2)=1.25 //750
Vet_HealthMod(3)= 1.375 //825
	
Vet_SprintSpeedMod(0)=1
Vet_SprintSpeedMod(1)=1.10 //1.05
Vet_SprintSpeedMod(2)=1.20 //1.15
Vet_SprintSpeedMod(3)=1.30 //1.25
	
// +X as opposed to *X
Vet_SprintTTFD(0)=0
Vet_SprintTTFD(1)= 0.10 //0.05
Vet_SprintTTFD(2)= 0.20 //0.15
Vet_SprintTTFD(3)= 0.30 //0.25

Heroic_MuzzleFlash=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash_Heroic'

	BarrelLength(0)=400
	BarrelLength(1)=100
	BarrelLength(2)=100
	BarrelLength(3)=100
	BarrelLength(4)=100
	BarrelLength(5)=100

/**********************/
	
    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=45
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
        EngineDamping=4.0
        InsideTrackTorqueFactor=0.375
        TurnInPlaceThrottle=0.285 //0.225
        TurnMaxGripReduction=0.995 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=16500 //15000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_VH_LightTank'
        AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_VH_LightTank'
        PhysicsAsset=PhysicsAsset'RX_VH_LightTank.Mesh.SK_VH_LightTank_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_LightTank.Mesh.MT_VH_LightTank'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_LightTank.Mesh.SK_PTVH_LightTank'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMesh
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_Antenna'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMesh=SAntennaMesh
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshA
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_TowRing'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_TowRing_Front'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshA=STowRingMeshA
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshB
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_TowRing'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_TowRing_Front'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshB=STowRingMeshB
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshC
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_TowRing'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshC=STowRingMeshC
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshD
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_TowRing'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshD=STowRingMeshD

	VehicleIconTexture=Texture2D'RX_VH_LightTank.UI.T_VehicleIcon_LightTank'
	MinimapIconTexture=Texture2D'RX_VH_LightTank.UI.T_MinimapIcon_LightTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_LightTank_Weapon',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-410,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-410,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_LightTank.Materials.MI_VH_Burnout'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_LightTank.Materials.MI_VH_Burnout'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_LightTank.Materials.PhysMat_Light_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_LightTank.Materials.PhysMat_Light'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="Fire01")
    VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)

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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_LightTank.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Chassis_Front,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Chassis_Front_Left,MorphNodeName=MorphNodeW_Ch_FL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(2)=(InfluenceBone=MT_Chassis_Front_Right,MorphNodeName=MorphNodeW_Ch_FR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(3)=(InfluenceBone=MT_Chassis_Back_Left,MorphNodeName=MorphNodeW_Ch_BL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(4)=(InfluenceBone=MT_Chassis_Back_Right,MorphNodeName=MorphNodeW_Ch_BR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(5)=(InfluenceBone=MT_Turret_Left,MorphNodeName=MorphNodeW_Tu_L,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(6)=(InfluenceBone=MT_Turret_Right,MorphNodeName=MorphNodeW_Tu_R,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(7)=(InfluenceBone=MT_Turret_Back,MorphNodeName=MorphNodeW_Tu_B,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=1.0)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_LightTank.Sounds.Light_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RX_VH_LightTank.Sounds.Light_startCue'
    ExitVehicleSound=SoundCue'RX_VH_LightTank.Sounds.Light_StopCue'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FR_Wheel_01
        BoneName="Wheel_FR_01"
        SkelControlName="Wheel_FR_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=FR_Wheel_01

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FR_Wheel_02
        BoneName="Wheel_FR_02"
        SkelControlName="Wheel_FR_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=FR_Wheel_02

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FR_Wheel_03
        BoneName="Wheel_FR_03"
        SkelControlName="Wheel_FR_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=FR_Wheel_03

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FR_Wheel_04
        BoneName="Wheel_FR_04"
        SkelControlName="Wheel_FR_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=FR_Wheel_04



    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RR_Wheel_01
        BoneName="Wheel_RR_01"
        SkelControlName="Wheel_RR_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RR_Wheel_01

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RR_Wheel_02
        BoneName="Wheel_RR_02"
        SkelControlName="Wheel_RR_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=RR_Wheel_02

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RR_Wheel_03
        BoneName="Wheel_RR_03"
        SkelControlName="Wheel_RR_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(6)=RR_Wheel_03

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RR_Wheel_04
        BoneName="Wheel_RR_04"
        SkelControlName="Wheel_RR_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(7)=RR_Wheel_04



    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FL_Wheel_01
        BoneName="Wheel_FL_01"
        SkelControlName="Wheel_FL_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=FL_Wheel_01

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FL_Wheel_02
        BoneName="Wheel_FL_02"
        SkelControlName="Wheel_FL_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=FL_Wheel_02

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FL_Wheel_03
        BoneName="Wheel_FL_03"
        SkelControlName="Wheel_FL_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=FL_Wheel_03

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=FL_Wheel_04
        BoneName="Wheel_FL_04"
        SkelControlName="Wheel_FL_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=FL_Wheel_04



    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RL_Wheel_01
        BoneName="Wheel_RL_01"
        SkelControlName="Wheel_RL_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(12)=RL_Wheel_01

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RL_Wheel_02
        BoneName="Wheel_RL_02"
        SkelControlName="Wheel_RL_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(13)=RL_Wheel_02

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RL_Wheel_03
        BoneName="Wheel_RL_03"
        SkelControlName="Wheel_RL_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(14)=RL_Wheel_03

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RL_Wheel_04
        BoneName="Wheel_RL_04"
        SkelControlName="Wheel_RL_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(15)=RL_Wheel_04



    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RL_Wheel_05
        BoneName="Wheel_RL_05"
        SkelControlName="Wheel_L_Cont"
        Side=SIDE_Left
    End Object
    Wheels(16)=RL_Wheel_05

    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=RR_Wheel_05
        BoneName="Wheel_RR_05"
        SkelControlName="Wheel_R_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=RR_Wheel_05
}
