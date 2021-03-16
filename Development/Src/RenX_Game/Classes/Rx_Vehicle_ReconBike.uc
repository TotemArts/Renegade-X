class Rx_Vehicle_ReconBike extends Rx_Vehicle
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

    Begin Object Name=CollisionCylinder
    CollisionHeight=40.0
    CollisionRadius=100.0
    Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object


    Health=250 //200
    bLightArmor=True
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.15
	LookForwardDist=250
    bHasHandbrake=true
    GroundSpeed=1100
    AirSpeed=1100
    MaxSpeed=2000 //1600 compensate for Veterancy increase 
    HornIndex=0
    COMOffset=(x=0.0,y=0.0,z=-75.0)
    bUsesBullets = false
    bOkAgainstBuildings=true
    bSecondaryFireTogglesFirstPerson=false
    bRotateCameraUnderVehicle=false
	
	MaxSprintSpeedMultiplier=2.0
	
	CustomGravityScaling=1.0

    HeavySuspensionShiftPercent=0.75f;
    bLookSteerOnNormalControls=true
    bLookSteerOnSimpleControls=true
    LookSteerSensitivity=2.2
    LookSteerDamping=0.07
    ConsoleSteerScale=1.1
    DeflectionReverseThresh=-0.3


    Begin Object Class=UDKVehicleSimCar Name=SimObject
        WheelSuspensionStiffness=60.0
        WheelSuspensionDamping=4.0
        WheelSuspensionBias=0.1
        ChassisTorqueScale=1.0
        MaxBrakeTorque=10.0
        StopThreshold=100

        MaxSteerAngleCurve=(Points=((InVal=0,OutVal=70),(InVal=675.0,OutVal=45.0), (InVal=1000.0,OutVal= 25.0))) //16.0)))
        SteerSpeed=150

        LSDFactor=0.4

		TorqueVSpeedCurve=(Points=((InVal=-1000.0,OutVal=0.0),(InVal=0.0,OutVal=400.0),(InVal=1200.0,OutVal=10.0)))

		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=3500.0),(InVal=0.0,OutVal=1500.0),(InVal=1000.0,OutVal=4500.0), (InVal=1400.0,OutVal=6000.0)))

        EngineBrakeFactor=0.1
        ThrottleSpeed=1.2
        WheelInertia=0.2
        NumWheelsForFullSteering=8
        SteeringReductionFactor=0.15 //0.0
        SteeringReductionMinSpeed=1100.0
        SteeringReductionSpeed=1400.0
        bAutoHandbrake=true
        bClampedFrictionModel=true
        FrontalCollisionGripFactor=0.01
        ConsoleHardTurnGripFactor=1.0
        HardTurnMotorTorque=0.7
        HandbrakeSpeed=1.0

        SpeedBasedTurnDamping=0.2
        AirControlTurnTorque=0.0

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.1
        WheelLongExtremumValue=0.8
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
		WheelLatExtremumSlip=0.35     // 20 degrees
        WheelLatExtremumValue=0.5
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
        SkeletalMesh=SkeletalMesh'RX_VH_ReconBike.Mesh.SK_VH_ReconBike'
        AnimTreeTemplate=AnimTree'RX_VH_ReconBike.Mesh.AT_VH_ReconBike'
        PhysicsAsset=PhysicsAsset'RX_VH_ReconBike.Mesh.SK_VH_ReconBike_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_ReconBike.Mesh.SK_PTVH_ReconBike'

	VehicleIconTexture=Texture2D'RX_VH_ReconBike.UI.T_VehicleIcon_ReconBike'
	MinimapIconTexture=Texture2D'TS_VH_ReconBike.Materials.T_RadarBlip_ReconBike'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_ReconBike_Weapon',
                GunSocket=("Fire_Left", "Fire_Right"),
                GunPivotPoints=(b_Root),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=40, Z=0),
                CameraOffset=-160,
                bSeatVisible=true,
                SeatBone=b_Seat,
                SeatSocket=SeatSocket,
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

    DrivingAnim=H_M_Seat_ReconBike

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_ReconBike.Materials.PhysMat_ReconBike_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_ReconBike.Materials.PhysMat_ReconBike'

    RecoilTriggerTag = "Recoil_Right", "Recoil_Left"
    VehicleEffects(0)=(EffectStartTag="FireRight",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="Fire_Left")
    VehicleEffects(1)=(EffectStartTag="FireLeft",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="Fire_Right")
    
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)

    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustSocket_L)
    VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustSocket_R)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_ReconBike.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'TS_VH_ReconBike.Sounds.SC_Engine_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'TS_VH_ReconBike.Sounds.SC_Engine_Start'
    ExitVehicleSound=SoundCue'TS_VH_ReconBike.Sounds.SC_Engine_Stop'
	
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


	DamageMorphTargets(0)=(InfluenceBone=b_Tire_Front,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=b_Tire_Rear,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=b_MissilePod_L,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=b_MissilePod_R,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=2.0)


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=FL_Wheel
		BoneName="b_Wheel_FL"
		SkelControlName="Wheel_FL_Cont"
		SteerFactor=1
		WheelRadius=26
	End Object
	Wheels(0)=FL_Wheel
	
	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=FR_Wheel
		BoneName="b_Wheel_FR"
		SkelControlName="Wheel_FR_Cont"
		SteerFactor=1
		WheelRadius=26
	End Object
	Wheels(1)=FR_Wheel
	
	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=RL_Wheel
		BoneName="b_Wheel_RL"
		SkelControlName="Wheel_RL_Cont"
		LongSlipFactor=2.4
		LatSlipFactor=2.4
		HandbrakeLongSlipFactor=0.4
		HandbrakeLatSlipFactor=0.4
	End Object
	Wheels(2)=RL_Wheel
	
	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=RR_Wheel
		BoneName="b_Wheel_RR"
		SkelControlName="Wheel_RR_Cont"
		LongSlipFactor=2.4
		LatSlipFactor=2.4
		HandbrakeLongSlipFactor=0.4
		HandbrakeLatSlipFactor=0.4
	End Object
	Wheels(3)=RR_Wheel
	
	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=F_Wheel
		BoneName="b_Suspension_Front_LookAt"
		SkelControlName="Wheel_F_Cont"
		SteerFactor=1
		WheelRadius=26
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		ParkedSlipFactor=0.0
	End Object
	Wheels(4)=F_Wheel
	
	Begin Object class=Rx_Vehicle_ReconBike_Wheel Name=R_Wheel
		BoneName="b_Suspension_Rear_LookAt"
		SkelControlName="Wheel_R_Cont"
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		ParkedSlipFactor=0.0
	End Object
	Wheels(5)=R_Wheel
	
//========================================================\\
//***************** Veterancy Multipliers ****************\\
//========================================================\\

	//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16 

	Vet_HealthMod(0)=1 //250
	Vet_HealthMod(1)=1.2 //300
	Vet_HealthMod(2)=1.4 //350
	Vet_HealthMod(3)=1.6 //400
		
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1.10
	Vet_SprintSpeedMod(2)=1.20
	Vet_SprintSpeedMod(3)=1.30

//========================================================\\

}