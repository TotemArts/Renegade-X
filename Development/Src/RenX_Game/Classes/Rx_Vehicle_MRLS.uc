/*********************************************************
*
* File: Rx_Vehicle_MRLS.uc
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
class Rx_Vehicle_MRLS extends Rx_Vehicle_Treaded
    placeable;

var SkeletalMeshComponent AntennaMeshL;
var SkeletalMeshComponent AntennaMeshR;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;

/** Used to control the turret modes **/
var UTSkelControl_TurretConstrained Skel_TurretRotate;
var repnotify bool bLockTurret;

replication
{
    if(bNetDirty)
        bLockTurret;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName == 'bLockTurret')
        ChangeFireMode(bLockTurret);
    else
       super.ReplicatedEvent(VarName);
}

/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Mesh.AttachComponentToSocket(AntennaMeshL,'AntennaSocket_L');
    Mesh.AttachComponentToSocket(AntennaMeshR,'AntennaSocket_R');

    AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshL.FindSkelControl('Beam'));
    AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('Beam'));


    if (AntennaBeamControl != none)
    {
        AntennaBeamControl.EntireBeamVelocity = GetVelocity;
    }
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    Super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
        Skel_TurretRotate = UTSkelControl_TurretConstrained(SkelComp.FindSkelControl('TurretRotate'));

    else return;
}

/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
    return Velocity;
}

function bool DoJump(bool bUpdating)
{
    if (Role == ROLE_Authority)
    {
        switch (bLockTurret)
        {
            case true: 
            ChangeFireMode(false);
            if(Rx_Controller(Controller) != none)
                Rx_Controller(Controller).CTextMessage("Turret Unlocked", 'LightGreen', 30.0);
            break;
            
            case false:
            ChangeFireMode(true);
            if(Rx_Controller(Controller) != none)
                Rx_Controller(Controller).CTextMessage("Turret Locked", 'LightGreen', 30.0);
            break;
        }
        
    }
    return true;
}

simulated function ChangeFireMode(bool FM)
{
    bLockTurret = FM; 
    
    Skel_TurretRotate.bConstrainYaw = FM;
}


simulated event Destroyed()
{
    Super.Destroyed();
    Skel_TurretRotate = None;
}

DefaultProperties
{
    Begin Object Name=CollisionCylinder
    CollisionHeight=100.0
    CollisionRadius=200.0
    Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=400
    bLightArmor=True
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.2 //0.4
    LookForwardDist=100
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=-5.0,y=0.0,z=-50.0)
    
    SprintTrackTorqueFactorDivident=1.05
    bLockTurret=false 

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
    VPReward(0) = 5 
    VPReward(1) = 7 
    VPReward(2) = 9 
    VPReward(3) = 12 
    
    VPCost(0) = 20
    VPCost(1) = 50
    VPCost(2) = 110

    Vet_HealthMod(0)=1.0 //400
    Vet_HealthMod(1)=1.125 //450 
    Vet_HealthMod(2)=1.25 //500
    Vet_HealthMod(3)=1.375 //550 
        
    Vet_SprintSpeedMod(0)=1
    Vet_SprintSpeedMod(1)=1
    Vet_SprintSpeedMod(2)=1.05
    Vet_SprintSpeedMod(3)=1.10
        
    // +X as opposed to *X
    Vet_SprintTTFD(0)=0
    Vet_SprintTTFD(1)=0
    Vet_SprintTTFD(2)=0.05
    Vet_SprintTTFD(3)=0.1

/**********************/

    
    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=70
        WheelSuspensionDamping=5
        WheelSuspensionBias=0.1

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.5
        WheelLongExtremumValue=2.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
           WheelLatExtremumSlip=0.5     // 20 degrees
        WheelLatExtremumValue=4.0
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=4
        InsideTrackTorqueFactor=0.375
        TurnInPlaceThrottle=0.275
        TurnMaxGripReduction=0.997
        TurnGripScaleRate=0.8
        MaxEngineTorque=6000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_VH_MRLS'
        AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_VH_MRLS'
        PhysicsAsset=PhysicsAsset'RX_VH_MRLS.Mesh.SK_VH_MRLS_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_MRLS.Mesh.MT_VH_MRLS'
    End Object

    DrawScale=1.0
    
    SkeletalMeshForPT=SkeletalMesh'RX_VH_MRLS.Mesh.SK_PTVH_MRLS'
    
    Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshL
        SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
        AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
        LightEnvironment = MyLightEnvironment
    End Object
    AntennaMeshL=SAntennaMeshL
    
    Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
        SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
        AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
        LightEnvironment = MyLightEnvironment
    End Object
    AntennaMeshR=SAntennaMeshR

    VehicleIconTexture=Texture2D'RX_VH_MRLS.UI.T_VehicleIcon_MRLS'
    MinimapIconTexture=Texture2D'RX_VH_MRLS.UI.T_MinimapIcon_MRLS'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_MRLS_Weapon',
                GunSocket=(Fire01,Fire02,Fire03,Fire04,Fire05,Fire06,Fire07,Fire08,Fire09,Fire10,Fire11,Fire12),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                SeatBone=Base,
                SeatSocket=VH_Death,
                CameraBaseOffset=(Z=40),
                CameraOffset=-550,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( CameraTag=CamView3P,
                TurretVarPrefix="Passenger",
                CameraBaseOffset=(Z=40),
                CameraOffset=-550,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MRLS.Materials.PhysMat_MRLS_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MRLS.Materials.PhysMat_MRLS'

    RecoilTriggerTag = "TurretFire01", "TurretFire02", "TurretFire03", "TurretFire04", "TurretFire05", "TurretFire06", "TurretFire07", "TurretFire08", "TurretFire09", "TurretFire10", "TurretFire11", "TurretFire12"
    VehicleEffects(0)=(EffectStartTag=TurretFire01,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire01)
    VehicleEffects(1)=(EffectStartTag=TurretFire02,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire02)
    VehicleEffects(2)=(EffectStartTag=TurretFire03,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire03)
    VehicleEffects(3)=(EffectStartTag=TurretFire04,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire04)
    VehicleEffects(4)=(EffectStartTag=TurretFire05,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire05)
    VehicleEffects(5)=(EffectStartTag=TurretFire06,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire06)
    VehicleEffects(6)=(EffectStartTag=TurretFire07,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire07)
    VehicleEffects(7)=(EffectStartTag=TurretFire08,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire08)
    VehicleEffects(8)=(EffectStartTag=TurretFire09,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire09)
    VehicleEffects(9)=(EffectStartTag=TurretFire10,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire10)
    VehicleEffects(10)=(EffectStartTag=TurretFire11,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire11)
    VehicleEffects(11)=(EffectStartTag=TurretFire12,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire12)
    VehicleEffects(12)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)

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
    
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_MRLS.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Chassis_Front,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Chassis_Front_Left,MorphNodeName=MorphNodeW_Ch_FL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(2)=(InfluenceBone=MT_Chassis_Front_Right,MorphNodeName=MorphNodeW_Ch_FR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(3)=(InfluenceBone=MT_Chassis_Back,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(4)=(InfluenceBone=MT_Chassis_Back_Left,MorphNodeName=MorphNodeW_Ch_BL,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(5)=(InfluenceBone=MT_Chassis_Back_Right,MorphNodeName=MorphNodeW_Ch_BR,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(6)=(InfluenceBone=MT_Turret_Left,MorphNodeName=MorphNodeW_Tu_L,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=MT_Turret_Right,MorphNodeName=MorphNodeW_Tu_R,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.5)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.5)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.5)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.2)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_MRLS.Sounds.MRLS_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
    
    EnterVehicleSound=SoundCue'RX_VH_MRLS.Sounds.MRLS_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MRLS.Sounds.MRLS_stopCue'
    
    ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'
    
    MaxCuePitch= 0.9f
    MinCuePitch= 0.8f
    EaseOutFactor = 2.0f
    EaseOutStep = 0.001f
    VelocitySaltDegree = 0.3f
    VelocityBeginMultiplier = 2.5f


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RB_Wheel_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=RB_Wheel_01

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RB_Wheel_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=RB_Wheel_02

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RB_Wheel_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=RB_Wheel_03

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RB_Wheel_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=RB_Wheel_04

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RB_Wheel_05
        BoneName="Wheel_RB_05"
        SkelControlName="Wheel_RB_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RB_Wheel_05




    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LB_Wheel_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(5)=LB_Wheel_01

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LB_Wheel_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(6)=LB_Wheel_02

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LB_Wheel_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=LB_Wheel_03

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LB_Wheel_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=LB_Wheel_04

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LB_Wheel_05
        BoneName="Wheel_LB_05"
        SkelControlName="Wheel_LB_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=LB_Wheel_05




    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LT_Wheel_Front
        BoneName="Wheel_LT_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=LT_Wheel_Front

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LT_Wheel_MF
        BoneName="Wheel_LT_MF"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=LT_Wheel_MF

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LT_Wheel_MR
        BoneName="Wheel_LT_MR"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(12)=LT_Wheel_MR

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=LT_Wheel_Rear
        BoneName="Wheel_LT_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(13)=LT_Wheel_Rear




    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RT_Wheel_Front
        BoneName="Wheel_RT_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(14)=RT_Wheel_Front

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RT_Wheel_MF
        BoneName="Wheel_RT_MF"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(15)=RT_Wheel_MF

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RT_Wheel_MR
        BoneName="Wheel_RT_MR"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(16)=RT_Wheel_MR

    Begin Object Class=Rx_Vehicle_MRLS_Wheel Name=RT_Wheel_Rear
        BoneName="Wheel_RT_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=RT_Wheel_Rear
}
