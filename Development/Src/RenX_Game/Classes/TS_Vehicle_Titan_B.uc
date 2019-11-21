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
class TS_Vehicle_Titan_B extends Rx_Vehicle
    placeable;
	
var GameSkelCtrl_Recoil    Recoil_Barrel, Recoil_Cannon, Recoil_Turret;



	
var SkeletalMeshComponent AntennaMeshL;
var SkeletalMeshComponent AntennaMeshR;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(AntennaMeshL,'Antenna_L');
	Mesh.AttachComponentToSocket(AntennaMeshR,'Antenna_R');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshL.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('Beam'));


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


/**
*  Overloading this from SVehicle to avoid torquing the walker head.
*/
function AddVelocity( vector NewVelocity, vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo )
{
	// apply hit at location, not hitlocation
	Super.AddVelocity(NewVelocity, Location, DamageType, HitInfo);
}

    
DefaultProperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    bRotateCameraUnderVehicle=false
    bSecondaryFireTogglesFirstPerson=true
    Health=800
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.2
    LookForwardDist=100
    
    GroundSpeed=300
    MaxSpeed=300
    AirSpeed=300.0
    
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=0
    COMOffset=(x=0.0,y=0.0,z=-300.0)
	ExitOffset=(Z=-200.0)
	ExtraReachDownThreshold=450.0
	ObjectiveGetOutDist=750.0

	bStayUpright=true
	StayUprightRollResistAngle=0.0			// will be "locked"
	StayUprightPitchResistAngle=0.0
	StayUprightStiffness=2000
	StayUprightDamping=25
	
	UprightLiftStrength=50.0
	UprightTorqueStrength=50.0
	
	CustomGravityScaling=1.0
	
	Begin Object Class=RB_Handle Name=RB_BodyHandle
		LinearDamping=100.0
		LinearStiffness=99000.0
		AngularDamping=100.0
		AngularStiffness=99000.0
	End Object
	// BodyHandle=RB_BodyHandle
	Components.Add(RB_BodyHandle)

    Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=100.0
		WheelSuspensionDamping=4.0
		WheelSuspensionBias=1.0
		MaxThrustForce=600.0
		MaxReverseForce=600.0
		LongDamping=2.0
		MaxStrafeForce=600.0
		LatDamping=2.0
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=9000.0
		TurnTorqueMax=10000.0
		TurnDamping=3.0
		MaxYawRate=1.6
		PitchTorqueMax=35.0
		PitchDamping=0.1
		RollTorqueMax=50.0
		RollDamping=0.1
		MaxRandForce=0.0
		RandForceInterval=1000.0
		bCanClimbSlopes=true
		PitchTorqueFactor=0.0
		RollTorqueTurnFactor=0.0
		RollTorqueStrafeFactor=0.0
		bAllowZThrust=false
		bStabilizeStops=true
		StabilizationForceMultiplier=1.0
		bFullThrustOnDirectionChange=true
		bDisableWheelsWhenOff=false
		HardLimitAirSpeedScale=1.5
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TS_VH_Titan.Mesh.SK_VH_Titan_Reborn'
        AnimTreeTemplate=AnimTree'TS_VH_Titan.Anims.AT_VH_Titan_Reborn_B'
		AnimSets.Add(AnimSet'TS_VH_Titan.Anims.AS_VH_Titan_Reborn')
        PhysicsAsset=PhysicsAsset'TS_VH_Titan.Mesh.SK_VH_Titan_Reborn_Physics'
		MorphSets[0]=MorphTargetSet'TS_VH_Titan.Mesh.MT_VH_Titan_Reborn'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_Titan.Mesh.SK_VH_Titan_Reborn'
	
	Begin Object Name=CollisionCylinder
		CollisionHeight=50.0
		CollisionRadius=140.0
		Translation=(X=0.0,Y=0.0,Z=0.0)
		End Object
	CylinderComponent=CollisionCylinder
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshL
		SkeletalMesh=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_Antenna_Left'
		AnimTreeTemplate=AnimTree'RX_VH_MediumTank.Anims.AT_Antenna_Left'
		Scale=2.0
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshL=SAntennaMeshL
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_Antenna_Right'
		AnimTreeTemplate=AnimTree'RX_VH_MediumTank.Anims.AT_Antenna_Right'
		Scale=2.0
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshR=SAntennaMeshR
	
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
                CameraBaseOffset=(X=0,Z=-150),
                CameraOffset=-800,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
				
	Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
				CameraTag=CamView3P,
				CameraBaseOffset=(X=0,Z=-150),
                CameraOffset=-800,
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
	
	VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Titan.Effects.P_Laser',EffectSocket=LaserSocket)

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
   
    EnterVehicleSound=SoundCue'TS_VH_Titan.Sounds.SC_Start'
    ExitVehicleSound=SoundCue'TS_VH_Titan.Sounds.SC_Stop'

//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


	Begin Object Class=UTHoverWheel Name=RThruster
		BoneName="b_Root"
		BoneOffset=(X=0,Y=0,Z=-520)
		WheelRadius=80
		SuspensionTravel=20
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=10.0
		LatSlipFactor=10.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bCollidesVehicles=FALSE
	End Object
	Wheels(0)=RThruster

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 12 
	VPReward(1) = 14 
	VPReward(2) = 16 
	VPReward(3) = 20 
	
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
	
}
