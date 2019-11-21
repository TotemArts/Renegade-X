
class Rx_Vehicle_Humvee extends Rx_Vehicle
    placeable;

    
    
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;


var SkeletalMeshComponent AntennaMesh;
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

	Mesh.AttachComponentToSocket(AntennaMesh,'AntennaSocket');
	Mesh.AttachComponentToSocket(TowRingMeshFR,'TowRingSocket_FR');
	Mesh.AttachComponentToSocket(TowRingMeshFL,'TowRingSocket_FL');
	Mesh.AttachComponentToSocket(TowRingMeshBR,'TowRingSocket_BR');
	Mesh.AttachComponentToSocket(TowRingMeshBL,'TowRingSocket_BL');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMesh.FindSkelControl('Beam'));
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

simulated function VehicleWeaponStoppedFiring(bool bViaReplication, int SeatIndex)
{
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

    Begin Object Name=CollisionCylinder
    CollisionHeight=80.0
    CollisionRadius=160.0
    Translation=(X=-32.0,Y=0.0,Z=0.0)
    End Object

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=300
    bLightArmor=True
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.05 		// 0.1
	LookForwardDist=200
    bHasHandbrake=true
    GroundSpeed=800
    AirSpeed=700
    MaxSpeed=2500
    HornIndex=0
    COMOffset=(x=10.0,y=0.0,z=-55.0)
    bUsesBullets = true
    bOkAgainstBuildings=false
    bSecondaryFireTogglesFirstPerson=true
	
	CustomGravityScaling=0.95

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 5 
	VPReward(1) = 7 
	VPReward(2) = 9 
	VPReward(3) = 12 

	VPCost(0) = 15
	VPCost(1) = 30
	VPCost(2) = 70
	
Vet_HealthMod(0)=1 //300
Vet_HealthMod(1)=1.166667 //350
Vet_HealthMod(2)=1.333334 //400
Vet_HealthMod(3)=1.666667 //500
	
Vet_SprintSpeedMod(0)=1.0f
Vet_SprintSpeedMod(1)=1.0f
Vet_SprintSpeedMod(2)=1.05f
Vet_SprintSpeedMod(3)=1.10f


/**********************/
	
    HeavySuspensionShiftPercent=0.75f;
    bLookSteerOnNormalControls=true
    bLookSteerOnSimpleControls=true
    LookSteerSensitivity=2.2
    LookSteerDamping=0.07
    ConsoleSteerScale=1.1
    DeflectionReverseThresh=-0.3

    Begin Object Class=UDKVehicleSimCar Name=SimObject
        WheelSuspensionStiffness=65.0
        WheelSuspensionDamping=4.0
        WheelSuspensionBias=0.15
        ChassisTorqueScale=2.0
        MaxBrakeTorque=4.0
        StopThreshold=100

        MaxSteerAngleCurve=(Points=((InVal=0,OutVal=60),(InVal=675.0,OutVal=30.0), (InVal=750.0,OutVal=8.0)))
        SteerSpeed=150

        LSDFactor=0.4

        // TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0),(InVal=0.0,OutVal=130.0),(InVal=950.0,OutVal=130.0),(InVal=1050.0,OutVal=10.0),(InVal=1150.0,OutVal=0.0)))
        TorqueVSpeedCurve=(Points=((InVal=-700.0,OutVal=0.0),(InVal=0.0,OutVal=130.0),(InVal=900.0,OutVal=10.0)))

        // EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=549.0,OutVal=3500.0),(InVal=550.0,OutVal=1000.0),(InVal=849.0,OutVal=4500.0),(InVal=850.0,OutVal=1500.0),(InVal=1100.0,OutVal=5000.0)))
        EngineRPMCurve=(Points=((InVal=-500.0,OutVal=3500.0),(InVal=0.0,OutVal=1500.0),(InVal=800.0,OutVal=4500.0), (InVal=1000.0,OutVal=6000.0)))

        EngineBrakeFactor=0.025
        ThrottleSpeed=1.2
        WheelInertia=0.2
        NumWheelsForFullSteering=4
        SteeringReductionFactor=0.0
        SteeringReductionMinSpeed=1100.0
        SteeringReductionSpeed=1400.0
        bAutoHandbrake=true
        bClampedFrictionModel=true
        FrontalCollisionGripFactor=0.01
        ConsoleHardTurnGripFactor=1.0
        HardTurnMotorTorque=0.7

        SpeedBasedTurnDamping=0.2
        AirControlTurnTorque=0.0

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.1
        WheelLongExtremumValue=1.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
		WheelLatExtremumSlip=0.35     // 20 degrees
        WheelLatExtremumValue=0.6
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=6.0

        bAutoDrive=false
        AutoDriveSteer=0.3
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.SK_VH_Humvee'
        AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_VH_Humvee'
        PhysicsAsset=PhysicsAsset'RX_VH_Humvee.Mesh.SK_VH_Humvee_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_Humvee.Mesh.MT_VH_Humvee'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Humvee.Mesh.SK_PTVH_Humvee'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMesh
		SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMesh=SAntennaMesh
	
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
		AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshBR=STowRingMeshBR
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshBL
		SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.towring'
		AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_TowRing'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRingMeshBL=STowRingMeshBL

	VehicleIconTexture=Texture2D'RX_VH_Humvee.UI.T_VehicleIcon_Humvee'
	MinimapIconTexture=Texture2D'RX_VH_Humvee.UI.T_MinimapIcon_Humvee'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_Humvee_Weapon',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
				bSeatVisible=false,
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-350,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-350,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_HumveeDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_Humvee'

    RecoilTriggerTag = "MainGun"
	VehicleEffects(0)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="Fire01")
	VehicleEffects(1)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.P_ShellCasing_Looping',EffectSocket="ShellCasingSocket")
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustLeft)
    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustRight)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_Humvee.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Chassis_Front,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Chassis_Left,MorphNodeName=MorphNodeW_Ch_L,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(2)=(InfluenceBone=MT_Chassis_Right,MorphNodeName=MorphNodeW_Ch_R,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))
    DamageMorphTargets(3)=(InfluenceBone=MT_Chassis_Back,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.2)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_Humvee.Sounds.Humvee_engine_cue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
    
    Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Looping'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Stop'

    EnterVehicleSound=SoundCue'RX_VH_Humvee.Sounds.humvee_start_cue'
    ExitVehicleSound=SoundCue'RX_VH_Humvee.Sounds.humvee_stop_cue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Small'

    SquealThreshold=0.1
    SquealLatThreshold=0.02
    LatAngleVolumeMult = 30.0
    EngineStartOffsetSecs=1.0
    EngineStopOffsetSecs=1.0
	
	Begin Object Class=AudioComponent Name=ScorpionSquealSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_TireSlide'
	End Object
	SquealSound=ScorpionSquealSound
	Components.Add(ScorpionSquealSound);
	
	Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);
	
	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireFoliage')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireGrass')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMetal')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMud')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireSnow')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireStone')
	TireSoundList(7)=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWater')
	TireSoundList(8)=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWood')


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

    Begin Object class=Rx_Vehicle_Humvee_Wheel Name=RRWheel
      BoneName="Rt_Rear_Tire"
      SkelControlName="Rt_Rear_Control"
	  LongSlipFactor=2.0
      LatSlipFactor=2.0
      HandbrakeLongSlipFactor=0.35
      HandbrakeLatSlipFactor=0.35
   End Object
   Wheels(0)=RRWheel

   Begin Object class=Rx_Vehicle_Humvee_Wheel Name=LRWheel
      BoneName="Lt_Rear_Tire"
      SkelControlName="Lt_Rear_Control"
	  LongSlipFactor=2.0
      LatSlipFactor=2.0
      HandbrakeLongSlipFactor=0.35
      HandbrakeLatSlipFactor=0.35
   End Object
   Wheels(1)=LRWheel

   Begin Object class=Rx_Vehicle_Humvee_Wheel Name=RFWheel
      BoneName="Rt_Front_Tire"
      SkelControlName="Rt_Front_Control"
      SteerFactor=1.00
   End Object
   Wheels(2)=RFWheel

   Begin Object class=Rx_Vehicle_Humvee_Wheel Name=LFWheel
      BoneName="Lt_Front_Tire"
      SkelControlName="Lt_Front_Control"
      SteerFactor=1.00
   End Object
   Wheels(3)=LFWheel
}