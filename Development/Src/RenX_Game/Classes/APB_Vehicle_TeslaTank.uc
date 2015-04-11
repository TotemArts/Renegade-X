/*********************************************************
*
* File: APB_Vehicle_TeslaTank.uc
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
class APB_Vehicle_TeslaTank extends Rx_Vehicle_Treaded
    placeable;

	
DefaultProperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    bRotateCameraUnderVehicle=true
    bSecondaryFireTogglesFirstPerson=true
    Health=600
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
    HornIndex=1
    COMOffset=(x=5.0,y=0.0,z=-55.0)
	
	SprintTrackTorqueFactorDivident=1.05

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=60
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
        MaxEngineTorque=8000
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'APB_VH_SOV_TeslaTank.Mesh.SK_VH_TeslaTank'
        AnimTreeTemplate=AnimTree'APB_VH_SOV_TeslaTank.Anims.AT_VH_TeslaTank'
        PhysicsAsset=PhysicsAsset'APB_VH_SOV_TeslaTank.Mesh.SK_VH_TeslaTank_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'APB_VH_SOV_TeslaTank.Mesh.SK_VH_TeslaTank'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'APB_Vehicle_TeslaTank_Weapon',
                GunSocket=(Fire01),
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
    RightTreadIndex   = 3

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_MuzzleFlash',EffectSocket="Fire01")

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
        SoundCue=SoundCue'RX_VH_MediumTank.Sounds.Med_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_stopCue'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


	/*		---------	Front Wheels	---------		*/

    Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_Lrg_RF
        BoneName="Wheel_Lrg_RF"
        SkelControlName="Wheel_Lrg_RF_Cont"
        Side=SIDE_Right
		WheelRadius=28
    End Object
    Wheels(0)=Wheel_Lrg_RF
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_Lrg_LF
        BoneName="Wheel_Lrg_LF"
        SkelControlName="Wheel_Lrg_LF_Cont"
        Side=SIDE_Left
		WheelRadius=28
    End Object
    Wheels(1)=Wheel_Lrg_LF
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_Lrg_RR
        BoneName="Wheel_Lrg_RR"
        SkelControlName="Wheel_Lrg_RR_Cont"
        Side=SIDE_Right
		WheelRadius=28
    End Object
    Wheels(2)=Wheel_Lrg_RR
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_Lrg_LR
        BoneName="Wheel_Lrg_LR"
        SkelControlName="Wheel_Lrg_LR_Cont"
        Side=SIDE_Left
		WheelRadius=28
    End Object
    Wheels(3)=Wheel_Lrg_LR
	
	
	/*		---------	Upper Wheels	---------		*/
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_Front
        BoneName="Wheel_RT_Front"
        SkelControlName="Wheel_RT_Front_Cont"
        Side=SIDE_Right
		WheelRadius=10
    End Object
    Wheels(4)=Wheel_RT_Front
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_Front
        BoneName="Wheel_LT_Front"
        SkelControlName="Wheel_LT_Front_Cont"
        Side=SIDE_Left
		WheelRadius=10
    End Object
    Wheels(5)=Wheel_LT_Front
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_Rear
        BoneName="Wheel_RT_Rear"
        SkelControlName="Wheel_RT_Rear_Cont"
        Side=SIDE_Right
		WheelRadius=10
    End Object
    Wheels(6)=Wheel_RT_Rear
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_Rear
        BoneName="Wheel_LT_Rear"
        SkelControlName="Wheel_LT_Rear_Cont"
        Side=SIDE_Left
		WheelRadius=10
    End Object
    Wheels(7)=Wheel_LT_Rear
	
	
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_01
        BoneName="Wheel_RT_01"
        SkelControlName="Wheel_RT_01_Cont"
        Side=SIDE_Right
		WheelRadius=4
    End Object
    Wheels(8)=Wheel_RT_01
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_02
        BoneName="Wheel_RT_02"
        SkelControlName="Wheel_RT_02_Cont"
        Side=SIDE_Right
		WheelRadius=4
    End Object
    Wheels(9)=Wheel_RT_02
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_03
        BoneName="Wheel_RT_03"
        SkelControlName="Wheel_RT_03_Cont"
        Side=SIDE_Right
		WheelRadius=4
    End Object
    Wheels(10)=Wheel_RT_03
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RT_04
        BoneName="Wheel_RT_04"
        SkelControlName="Wheel_RT_04_Cont"
        Side=SIDE_Right
		WheelRadius=4
    End Object
    Wheels(11)=Wheel_RT_04
	
	
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_01
        BoneName="Wheel_LT_01"
        SkelControlName="Wheel_LT_01_Cont"
        Side=SIDE_Left
		WheelRadius=4
    End Object
    Wheels(12)=Wheel_LT_01
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_02
        BoneName="Wheel_LT_02"
        SkelControlName="Wheel_LT_02_Cont"
        Side=SIDE_Left
		WheelRadius=4
    End Object
    Wheels(13)=Wheel_LT_02
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_03
        BoneName="Wheel_LT_03"
        SkelControlName="Wheel_LT_03_Cont"
        Side=SIDE_Left
		WheelRadius=4
    End Object
    Wheels(14)=Wheel_LT_03
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LT_04
        BoneName="Wheel_LT_04"
        SkelControlName="Wheel_LT_04_Cont"
        Side=SIDE_Left
		WheelRadius=4
    End Object
    Wheels(15)=Wheel_LT_04
	
	
	
	/*		---------	Driving Wheels	---------		*/	
	
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RB_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(16)=Wheel_RB_01
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RB_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=Wheel_RB_02
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RB_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(18)=Wheel_RB_03
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_RB_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(19)=Wheel_RB_04
	
	
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LB_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left

    End Object
    Wheels(20)=Wheel_LB_01
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LB_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(21)=Wheel_LB_02
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LB_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(22)=Wheel_LB_03
	
	Begin Object Class=APB_Vehicle_TeslaTank_Wheel Name=Wheel_LB_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(23)=Wheel_LB_04

}
