/*********************************************************
*
* File: Rx_Vehicle_C130.uc
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
class Rx_Vehicle_C130 extends Rx_Vehicle_Air_Jet
    placeable;
 

DefaultProperties
{

    Begin Object Name=CollisionCylinder
    CollisionHeight=1000.0
    CollisionRadius=2000.0
    Translation=(X=0.0,Y=0.0,Z=256.0)
    End Object
//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\



    BaseEyeheight=0 //30
    Eyeheight=0 //30
    PushForce=50000.0
    LookForwardDist=0 //500.0
    bRotateCameraUnderVehicle=true
    bLimitCameraZLookingUp=false
    CollisionDamageMult=0.005

    Health=6000
    bLightArmor=true
    MomentumMult=0.7
    bCanFlip=true
    bSeparateTurretFocus=false //true
    CameraLag=0.3 //0.05
    AirSpeed=6000.0
    MaxSpeed=2000
    HornIndex=0
    COMOffset=(x=-50.0,y=0.0,z=50.0)
    bUsesBullets = true
    
	MaxDesireability = 0 // todo: reactivate when flying AI is fixed    

  
	// Jet Physics
    Begin Object Name=SimObject
        MaxThrustForce=160000.0
        MaxReverseForce=0.0
        LongDamping=0.1
        MaxStrafeForce=0.0
        LatDamping=0.7
        MaxRiseForce=1000000.0
        UpDamping=0.0
        TurnTorqueFactor=100000.0
        TurnTorqueMax=200000.0
        TurnDamping=1.0 //1.2
        MaxYawRate=1.5
        PitchTorqueFactor=0 //-1000.0
        PitchTorqueMax=0 //2000.0
        PitchDamping=3.0
        RollTorqueTurnFactor=40000 //6000.0
        RollTorqueStrafeFactor=60000 //2000.0
        RollTorqueMax=60000 //6000.0
        RollDamping=0.5 //1.2
        MaxRandForce=0.0
        RandForceInterval=1.5
        StopThreshold=1000
        bShouldCutThrustMaxOnImpact=false
    End Object
    SimObj=SimObject
    Components.Add(SimObject)
	
	bStayUpright=true //false
    UprightLiftStrength=30000000 //30.0
    UprightTorqueStrength=30000000 //30.0
    StayUprightRollResistAngle=50000000 //0 //5.0
    StayUprightPitchResistAngle=1000000	//5.0
    StayUprightStiffness=600000000 //1200
    StayUprightDamping=20000000 //20


/*
	// Chopper Physics
    Begin Object Class=UDKVehicleSimChopper Name=SimObject
        MaxThrustForce=700.0 //450.0
        MaxReverseForce=500.0 //350.0
        LongDamping=0.5
        MaxStrafeForce=600.0 //350.0
        LatDamping=0.5
        MaxRiseForce=400.0 //250.0
        UpDamping=0.6
        TurnTorqueFactor=9000.0
        TurnTorqueMax=10000.0
        TurnDamping=1.0 //0.5
        MaxYawRate=1.0 //0.8
        PitchTorqueFactor=2000.0
        PitchTorqueMax=300.0
        PitchDamping=0.5
        RollTorqueTurnFactor=3000.0
        RollTorqueStrafeFactor=1000.0
        RollTorqueMax=3000.0
        RollDamping=1.0
        MaxRandForce=30.0
        RandForceInterval=0.5
        StopThreshold=10
        bShouldCutThrustMaxOnImpact=true
    End Object
    SimObj=SimObject
    Components.Add(SimObject)
	
	UprightLiftStrength=30.0
    UprightTorqueStrength=30.0

    bStayUpright=true
    StayUprightRollResistAngle=5.0
    StayUprightPitchResistAngle=5.0
    StayUprightStiffness=1200
    StayUprightDamping=20
*/	
	
//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\
    
    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_C-130.Mesh.SK_C-130'
        AnimTreeTemplate=AnimTree'RX_VH_C-130.Anim.AT_C-130'
        PhysicsAsset=PhysicsAsset'RX_VH_C-130.Mesh.SK_C-130_Physics'
    End Object

    DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_VH_C-130.UI.T_VehicleIcon_C130'
	MinimapIconTexture=Texture2D'RX_VH_C-130.UI.T_MinimapIcon_C130'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={( CameraTag=CamView3P,
                CameraBaseOffset=(X=0,Z=200),
                CameraOffset=-3500,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_C-130.Materials.MI_C-130_BO'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_C-130.Materials.MI_C-130_BO'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_C-130.Materials.PhysMat_C-130_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_C-130.Materials.PhysMat_C-130'

    VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_C-130.Effects.P_C-130_WingTip',EffectSocket=Flare_Wing_L)
    VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_C-130.Effects.P_C-130_WingTip',EffectSocket=Flare_Wing_R)
    
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=Engine_R_1)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=Engine_R_2)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=Engine_L_1)
	VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=Engine_L_2)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_C-130.Sounds.SC_C-130_Engine'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    // Scrape sound.
    Begin Object Class=AudioComponent Name=BaseScrapeSound
        SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
    End Object
    ScrapeSound=BaseScrapeSound
    Components.Add(BaseScrapeSound);

    ExplosionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Explode'
    CollisionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
    EnterVehicleSound=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Start'
    ExitVehicleSound=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Stop'

    EngineStartOffsetSecs=1.0
    EngineStopOffsetSecs=1.0

}