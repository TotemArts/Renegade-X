/*********************************************************
*
* File: RA2_Vehicle_TeslaTank.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class RA2_Vehicle_TeslaTank extends Rx_Vehicle_Treaded
    placeable;
	
DefaultProperties
{
//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    //VP Given on death (by VRank)
    VPReward(0) = 10
    VPReward(1) = 12 
    VPReward(2) = 14 
    VPReward(3) = 20 
    
    VPCost(0) = 30
    VPCost(1) = 70
    VPCost(2) = 150

    Vet_HealthMod(0)=1 //800
    Vet_HealthMod(1)=1.125 //900 
    Vet_HealthMod(2)=1.25 //1000
    Vet_HealthMod(3)=1.375 //1100
        
    Vet_SprintSpeedMod(0)=1
    Vet_SprintSpeedMod(1)=1.05
    Vet_SprintSpeedMod(2)=1.10
    Vet_SprintSpeedMod(3)=1.15
        
    // +X as opposed to *X
    Vet_SprintTTFD(0)=0.3
    Vet_SprintTTFD(1)=0.30//0
    Vet_SprintTTFD(2)=0.4
    Vet_SprintTTFD(3)=0.45

    bRotateCameraUnderVehicle=true
    bSecondaryFireTogglesFirstPerson=true
    Health=800
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.4
    LookForwardDist=350
    GroundSpeed=500
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=15
    ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=5.0,y=0.0,z=-50.0)
	
	SprintTrackTorqueFactorDivident=0.975

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=65
        WheelSuspensionDamping=2.0
        WheelSuspensionBias=0.15

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
        MaxEngineTorque=5000
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RA2_VH_TeslaTank.Meshes.RA2_VH_TeslaTank'
        AnimTreeTemplate=AnimTree'RA2_VH_TeslaTank.Animations.AT_VH_TeslaTank'
        PhysicsAsset=PhysicsAsset'RA2_VH_TeslaTank.RA2_VH_TeslaTank_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RA2_VH_TeslaTank.Meshes.RA2_VH_TeslaTank'
	VehicleIconTexture=Texture2D'RA2_VH_TeslaTank.Textures.T_VehicleIcon_TeslaTank'
	MinimapIconTexture=Texture2D'RA2_VH_TeslaTank.T_Minimapicon_TeslaTank'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

    Seats(0)={(GunClass=class'RA2_Vehicle_TeslaTank_Weapon',
                GunSocket=(Fire01,Fire02),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-50),
                CameraOffset=-600,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'APB_Light_TeslaTank_MuzzleFlash'
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


    LeftTeadIndex     = 2
    RightTreadIndex   = 1

    DrivingPhysicalMaterial=PhysicalMaterial'RA2_VH_TeslaTank.Materials.PhysMat_TeslaTank_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RA2_VH_TeslaTank.Materials.PhysMat_TeslaTank'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_MuzzleFlash',EffectSocket="Fire01")
	VehicleEffects(1)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_MuzzleFlash',EffectSocket="Fire02")
    VehicleEffects(2)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffectLeft")
    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffectLRight")
    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Generator',EffectSocket="GeneratorEffect")
    VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Startup',EffectSocket="ExhaustEffectLeft")
    VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Startup',EffectSocket="ExhaustEffectLRight")

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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RA2_VH_TeslaTank.Sounds.Teslatank_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RA2_VH_TeslaTank.Sounds.Teslatank_startCue'
    ExitVehicleSound=SoundCue'RA2_VH_TeslaTank.Sounds.Teslatank_StopCue'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

     Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RB_Wheel_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=RB_Wheel_01

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RB_Wheel_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=RB_Wheel_02

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RB_Wheel_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=RB_Wheel_03

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RB_Wheel_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=RB_Wheel_04

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RB_Wheel_05
        BoneName="Wheel_RB_05"
        SkelControlName="Wheel_RB_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RB_Wheel_05

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LB_Wheel_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(5)=LB_Wheel_01

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LB_Wheel_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(6)=LB_Wheel_02

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LB_Wheel_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=LB_Wheel_03

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LB_Wheel_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=LB_Wheel_04

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LB_Wheel_05
        BoneName="Wheel_LB_05"
        SkelControlName="Wheel_LB_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=LB_Wheel_05


    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LT_Wheel_Front
        BoneName="Wheel_LT_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=LT_Wheel_Front

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=LT_Wheel_Rear
        BoneName="Wheel_LT_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=LT_Wheel_Rear

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RT_Wheel_Front
        BoneName="Wheel_RT_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(12)=RT_Wheel_Front

    Begin Object Class=RA2_Vehicle_TeslaTank_Wheel Name=RT_Wheel_Rear
        BoneName="Wheel_RT_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(13)=RT_Wheel_Rear
}
