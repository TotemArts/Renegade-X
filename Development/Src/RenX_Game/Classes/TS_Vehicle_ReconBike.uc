
class TS_Vehicle_ReconBike extends Rx_Vehicle
    placeable;


	
var GameSkelCtrl_Recoil    Recoil_Left, Recoil_Right;
	
/** added recoil */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
    {
		Recoil_Left = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_L') );
		Recoil_Right = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_R') );
	}
}

simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (RecoilTriggerTag == EventTag && Recoil_Left != none)
	{
		Recoil_Left.bPlayRecoil = true;
	}	
	
	if (RecoilTriggerTag == EventTag && Recoil_Right != none)
	{
		Recoil_Right.bPlayRecoil = true;
	}
}	


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
   local Name FireTriggerTag;

   Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);

   FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   if(Weapon != None) {
       if (Weapon.CurrentFireMode == 0)
       {
           switch(FireTriggerTag)
          {
          case 'FireLeft':
             Recoil_Left.bPlayRecoil = TRUE;
             break;
    
          case 'FireRight':
             Recoil_Right.bPlayRecoil = TRUE;
             break;
          }
       }
   }
}

DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=200
    bLightArmor=True
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.15
	LookForwardDist=200
    bHasHandbrake=true
    GroundSpeed=1200
    AirSpeed=1200
    MaxSpeed=1200
    HornIndex=1
    COMOffset=(x=20.0,y=0.0,z=-85.0)
    bUsesBullets = true
    bOkAgainstBuildings=true
    bSecondaryFireTogglesFirstPerson=false
	
	CustomGravityScaling=1.0

    HeavySuspensionShiftPercent=0.75f;
    bLookSteerOnNormalControls=true
    bLookSteerOnSimpleControls=true
    LookSteerSensitivity=2.2
    LookSteerDamping=0.07
    ConsoleSteerScale=1.1
    DeflectionReverseThresh=-0.3

    Begin Object Class=UDKVehicleSimCar Name=SimObject
        WheelSuspensionStiffness=40.0
        WheelSuspensionDamping=3.0
        WheelSuspensionBias=0.15
        ChassisTorqueScale=10.0
        MaxBrakeTorque=4.0
        StopThreshold=100

        MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45),(InVal=675.0,OutVal=30.0), (InVal=1000.0,OutVal=16.0)))
        SteerSpeed=150

        LSDFactor=0.4

		TorqueVSpeedCurve=(Points=((InVal=-700.0,OutVal=0.0),(InVal=0.0,OutVal=200.0),(InVal=1400.0,OutVal=10.0)))

		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=3500.0),(InVal=0.0,OutVal=1500.0),(InVal=1000.0,OutVal=4500.0), (InVal=1400.0,OutVal=6000.0)))

        EngineBrakeFactor=0.01
        ThrottleSpeed=1.2
        WheelInertia=0.2
        NumWheelsForFullSteering=6
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
        SkeletalMesh=SkeletalMesh'TS_VH_ReconBike.Mesh.SK_VH_ReconBike'
        AnimTreeTemplate=AnimTree'TS_VH_ReconBike.Anims.AT_VH_ReconBike'
        PhysicsAsset=PhysicsAsset'TS_VH_ReconBike.Mesh.SK_VH_ReconBike_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_ReconBike.Mesh.SK_VH_ReconBike'

	VehicleIconTexture=Texture2D'TS_VH_ReconBike.Materials.T_VehicleIcon_ReconBike'
	MinimapIconTexture=Texture2D'TS_VH_ReconBike.Materials.T_RadarBlip_ReconBike'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_ReconBike_Weapon',
                GunSocket=(Fire_Left,Fire_Right),
                TurretControls=(TurretPitch),
                GunPivotPoints=(b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-35),
                CameraOffset=-350,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_ReconBike.Materials.PhysMat_ReconBike_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_ReconBike.Materials.PhysMat_ReconBike'

    RecoilTriggerTag = "FireRight", "FireLeft"
    VehicleEffects(0)=(EffectStartTag="FireRight",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="Fire_Left")
    VehicleEffects(1)=(EffectStartTag="FireLeft",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="Fire_Right")
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_Buggy.Sounds.SC_Buggy_Engine'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_Buggy.Sounds.SC_Buggy_Start'
    ExitVehicleSound=SoundCue'RX_VH_Buggy.Sounds.SC_Buggy_Stop'
	
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

    Begin Object class=TS_Vehicle_ReconBike_Wheel Name=Wheel_F
		BoneName="b_Wheel_Dummy_F"
		SkelControlName="Wheel_F_Cont"
		SteerFactor=1.0
	End Object
	Wheels(0)=Wheel_F

	Begin Object class=TS_Vehicle_ReconBike_Wheel Name=Wheel_B
		BoneName="b_Wheel_Dummy_B"
		SkelControlName="Wheel_B_Cont"
		HandbrakeLongSlipFactor=0.35
		HandbrakeLatSlipFactor=0.1
	End Object
	Wheels(1)=Wheel_B
   
	Begin Object class=TS_Vehicle_ReconBike_Wheel Name=Wheel_L
		BoneName="b_Chassis_Roll"
		BoneOffset=(X=0.0,Y=50.0,Z=20.0)
		WheelRadius=10
		SuspensionTravel=60
		bPoweredWheel=false
		bHoverWheel=false
		bCollidesVehicles=False
		bCollidesPawns=False
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
	End Object
	Wheels(2)=Wheel_L

	Begin Object class=TS_Vehicle_ReconBike_Wheel Name=Wheel_R
		BoneName="b_Chassis_Roll"
		BoneOffset=(X=0.0,Y=-50.0,Z=20.0)
		WheelRadius=10
		SuspensionTravel=60
		bPoweredWheel=false
		bHoverWheel=false
		bCollidesVehicles=False
		bCollidesPawns=False
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
	End Object
	Wheels(3)=Wheel_R
	
	Begin Object class=TS_Vehicle_ReconBike_Wheel Name=Wheel_Steer
		BoneName="b_Root"
		SkelControlName="Wheel_Steer_Cont"
		bPoweredWheel=false
		bHoverWheel=false
		bCollidesVehicles=False
		bCollidesPawns=False
		WheelRadius=1
		SteerFactor=-1.0
	End Object
	Wheels(4)=Wheel_Steer
}