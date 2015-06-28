/*********************************************************
*
* File: TS_Vehicle_Titan.uc
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
class TS_Vehicle_Titan extends Rx_Vehicle_Treaded
    placeable;
	
var GameSkelCtrl_Recoil    Recoil_Barrel, Recoil_Cannon, Recoil_Turret;
	
/** added recoil */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
    {
		Recoil_Barrel = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Barrel') );
		Recoil_Cannon = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Cannon') );
		Recoil_Turret = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Turret') );
	}
}

simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (RecoilTriggerTag == EventTag && Recoil_Barrel != none)
	{
		Recoil_Barrel.bPlayRecoil = true;
	}	
	
	if (RecoilTriggerTag == EventTag && Recoil_Cannon != none)
	{
		Recoil_Cannon.bPlayRecoil = true;
	}
	
	if (RecoilTriggerTag == EventTag && Recoil_Turret != none)
	{
		Recoil_Turret.bPlayRecoil = true;
	}
}


    
DefaultProperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

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
    GroundSpeed=300
    MaxSpeed=500
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-300.0)

	bStayUpright=true
	StayUprightRollResistAngle=15.0
	StayUprightPitchResistAngle=15.0
	StayUprightStiffness=2000
	StayUprightDamping=25
	
	UprightLiftStrength=50.0
	UprightTorqueStrength=50.0
	
	CustomGravityScaling=2.0

    Begin Object Class=SVehicleSimTank Name=SimObject
	
        bClampedFrictionModel=true

        WheelSuspensionStiffness=90
        WheelSuspensionDamping=40.0
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
        EngineDamping=3.5
        InsideTrackTorqueFactor=0.35
        TurnInPlaceThrottle=0.35
        TurnMaxGripReduction=0.995
        TurnGripScaleRate=0.8
        MaxEngineTorque=5250
		
    End Object
    SimObj=SimObject
    Components.Add(SimObject)

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TS_VH_Titan.Mesh.SK_VH_Titan'
        AnimTreeTemplate=AnimTree'TS_VH_Titan.Anims.AT_VH_Titan'
		AnimSets.Add(AnimSet'TS_VH_Titan.Anims.AS_VH_Titan')
        PhysicsAsset=PhysicsAsset'TS_VH_Titan.Mesh.SK_VH_Titan_Physics'
		MorphSets[0]=MorphTargetSet'TS_VH_Titan.Mesh.MT_VH_Titan'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_Titan.Mesh.SK_VH_Titan'
	
	VehicleIconTexture=Texture2D'TS_VH_Titan.Materials.T_VehicleIcon_Titan'
	MinimapIconTexture=Texture2D'TS_VH_Titan.Materials.T_RadarBlip_Titan'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_Titan_Weapon',
                GunSocket=(MuzzleFlashSocket),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=230,Z=-65),
                CameraOffset=-1040,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
				
	Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
				CameraTag=CamView3P,
				CameraBaseOffset=(X=230,Z=-65),
                CameraOffset=-1040,
				)}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_Titan.Materials.PhysMat_Titan_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_Titan.Materials.PhysMat_Titan'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'TS_VH_Titan.Effects.P_MuzzleFlash',EffectSocket="MuzzleFlashSocket")
	VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSteam01)
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks03)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSpark01))
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Snow')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Stone')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_WhiteSand')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_YellowSand')
	DefaultWheelPSCTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=b_Root,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=b_Hip,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage2))
    DamageMorphTargets(6)=(InfluenceBone=b_Leg_L_Upper,MorphNodeName=MorphNodeW_Ch_L,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=b_Leg_R_Upper,MorphNodeName=MorphNodeW_Ch_R,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'TS_VH_Titan.Sounds.SC_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_stopCue'
	
	Begin Object Name=ScorpionTireSound
		SoundCue=none
	End Object
	TireAudioComp=ScorpionTireSound

//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RFThruster
		BoneName="b_Root"
		BoneOffset=(X=65.0,Y=60.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		Side=SIDE_Right
	End Object
	Wheels(0)=RFThruster

	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LFThruster
		BoneName="b_Root"
		BoneOffset=(X=65.0,Y=-60.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		Side=SIDE_Left
	End Object
	Wheels(1)=LFThruster
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RRThruster
		BoneName="b_Root"
		BoneOffset=(X=-65.0,Y=60.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		Side=SIDE_Right
	End Object
	Wheels(2)=RRThruster
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LRThruster
		BoneName="b_Root"
		BoneOffset=(X=-65.0,Y=-60.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		Side=SIDE_Left
	End Object
	Wheels(3)=LRThruster
	
	
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=CFThruster
		BoneName="b_Root"
		BoneOffset=(X=104.0,Y=0.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
	End Object
	Wheels(4)=CFThruster
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=CRThruster
		BoneName="b_Root"
		BoneOffset=(X=-104.0,Y=0.0,Z=-350.0)
		WheelRadius=26
		SuspensionTravel=300
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
	End Object
	Wheels(5)=CRThruster

}
