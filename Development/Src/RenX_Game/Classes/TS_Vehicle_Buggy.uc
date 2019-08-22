/*********************************************************
*
* File: TS_Vehicle_Buggy.uc
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
class TS_Vehicle_Buggy extends Rx_Vehicle
    placeable;


    
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    VehicleEvent('FireRight');
	VehicleEvent('FireLeft');
    
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
            VehicleEvent('STOP_FireRight');
			VehicleEvent('STOP_FireLeft');
        }
    }

    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
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


    Health=250
    bLightArmor=False
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.075 //0.125 //0.2
	LookForwardDist=150
    bHasHandbrake=true
    GroundSpeed=900
    AirSpeed=900
    MaxSpeed=2500
    HornIndex=1
    COMOffset=(x=-10.0,y=0.0,z=-30.0)
    bUsesBullets = true
    bOkAgainstBuildings=false
    bSecondaryFireTogglesFirstPerson=true
	
	CustomGravityScaling=1.0

    HeavySuspensionShiftPercent=0.75f;
    bLookSteerOnNormalControls=true
    bLookSteerOnSimpleControls=true
    LookSteerSensitivity=2.2
    LookSteerDamping=0.07
    ConsoleSteerScale=1.1
    DeflectionReverseThresh=-0.3

	/*Veterancy */
	VRank=0
	
	//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16
	
	Vet_HealthMod(0)=1.0
	Vet_HealthMod(1)=1.2
	Vet_HealthMod(2)=1.4
	Vet_HealthMod(3)=1.6
	
	Vet_SprintSpeedMod(0)=1.0
	Vet_SprintSpeedMod(1)=1.10
	Vet_SprintSpeedMod(2)=1.175
	Vet_SprintSpeedMod(3)=1.25
	/**************************/
	
	
    Begin Object Class=UDKVehicleSimCar Name=SimObject
        WheelSuspensionStiffness=60
        WheelSuspensionDamping=1.0
        WheelSuspensionBias=0.0
        ChassisTorqueScale=1.0
        MaxBrakeTorque=4.0
        StopThreshold=100

        MaxSteerAngleCurve=(Points=((InVal=0,OutVal=60),(InVal=800.0,OutVal=20.0), (InVal=1200.0,OutVal=8.0)))
        SteerSpeed=150

        LSDFactor=0.0

        // TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0),(InVal=0.0,OutVal=130.0),(InVal=950.0,OutVal=130.0),(InVal=1050.0,OutVal=10.0),(InVal=1150.0,OutVal=0.0)))
        TorqueVSpeedCurve=(Points=((InVal=-750.0,OutVal=0.0),(InVal=0.0,OutVal=100.0),(InVal=850.0,OutVal=10.0)))

        // EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=549.0,OutVal=3500.0),(InVal=550.0,OutVal=1000.0),(InVal=849.0,OutVal=4500.0),(InVal=850.0,OutVal=1500.0),(InVal=1100.0,OutVal=5000.0)))
        EngineRPMCurve=(Points=((InVal=-500.0,OutVal=3500.0),(InVal=0.0,OutVal=1500.0),(InVal=850.0,OutVal=3750.0),(InVal=1400.0,OutVal=6000.0)))

        EngineBrakeFactor=0.02
        ThrottleSpeed=1.0
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
        WheelLatExtremumValue=0.5
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=5.0

        bAutoDrive=false
        AutoDriveSteer=0.3
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TS_VH_Buggy.Mesh.SK_VH_Buggy'
        AnimTreeTemplate=AnimTree'TS_VH_Buggy.Anims.AT_VH_Buggy'
        PhysicsAsset=PhysicsAsset'TS_VH_Buggy.Mesh.SK_VH_Buggy_Physics'
		MorphSets[0]=MorphTargetSet'TS_VH_Buggy.Mesh.MT_VH_Buggy'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_Buggy.Mesh.SK_VH_Buggy'

	VehicleIconTexture=Texture2D'TS_VH_Buggy.Materials.T_VehicleIcon_Buggy'
	MinimapIconTexture=Texture2D'TS_VH_Buggy.Materials.T_RadarBlip_Buggy'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_Buggy_Weapon',
                GunSocket=("FireL", "FireR"),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-400,
				bSeatVisible=true,
                SeatBone=b_Driver,
                SeatSocket=DriverSocket,
                SeatOffset=(X=0,Y=0,Z=0),
                SeatRotation=(Pitch=0,Yaw=0),
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-400,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Buggy.Materials.PhysMat_BuggyDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Buggy.Materials.PhysMat_Buggy'
	
    RecoilTriggerTag = "FireRight", "FireLeft"
    VehicleEffects(0)=(EffectStartTag="FireRight",EffectEndTag="STOP_FireRight",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Buggy.Effects.P_MuzzleFlash',EffectSocket="FireR")
    VehicleEffects(1)=(EffectStartTag="FireLeft",EffectEndTag="STOP_FireLeft",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Buggy.Effects.P_MuzzleFlash',EffectSocket="FireL")
	VehicleEffects(2)=(EffectStartTag="FireRight",EffectEndTag="STOP_FireRight",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.P_ShellCasing_Looping',EffectSocket="ShellCasingSocket")
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSteam01)
    VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=Exhaust01)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

	DamageMorphTargets(0)=(InfluenceBone=MT_F,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_L,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_R,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_B,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=4.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=4.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=4.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=4.0)
	
//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'TS_VH_Buggy.Sounds.SC_Buggy_Engine'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
    
    Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'TS_VH_Buggy.Sounds.SC_Buggy_Fire_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'TS_VH_Buggy.Sounds.SC_Buggy_Fire_Stop'

    EnterVehicleSound=SoundCue'TS_VH_Buggy.Sounds.SC_Buggy_Start'
    ExitVehicleSound=SoundCue'TS_VH_Buggy.Sounds.SC_Buggy_Stop'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Small'

    SquealThreshold=0.1
    SquealLatThreshold=0.02
    LatAngleVolumeMult = 30.0
    EngineStartOffsetSecs=2.0
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

	Begin Object class=TS_Vehicle_Buggy_Wheel Name=FL_Wheel
		BoneName="b_Wheel_FL"
		SkelControlName="Wheel_FL_Cont"
		SteerFactor=1
	End Object
	Wheels(0)=FL_Wheel
	
	Begin Object class=TS_Vehicle_Buggy_Wheel Name=FR_Wheel
		BoneName="b_Wheel_FR"
		SkelControlName="Wheel_FR_Cont"
		SteerFactor=1
	End Object
	Wheels(1)=FR_Wheel
	
	Begin Object class=TS_Vehicle_Buggy_Wheel Name=RL_Wheel
		BoneName="b_Wheel_RL"
		SkelControlName="Wheel_RL_Cont"
		WheelRadius=36
		LongSlipFactor=2.4
		LatSlipFactor=2.4
		HandbrakeLongSlipFactor=0.4
		HandbrakeLatSlipFactor=0.4
	End Object
	Wheels(2)=RL_Wheel
	
	Begin Object class=TS_Vehicle_Buggy_Wheel Name=RR_Wheel
		BoneName="b_Wheel_RR"
		SkelControlName="Wheel_RR_Cont"
		WheelRadius=36
		LongSlipFactor=2.4
		LatSlipFactor=2.4
		HandbrakeLongSlipFactor=0.4
		HandbrakeLatSlipFactor=0.4
	End Object
	Wheels(3)=RR_Wheel
}