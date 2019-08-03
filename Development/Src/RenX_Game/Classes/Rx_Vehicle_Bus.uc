class Rx_Vehicle_Bus extends Rx_Vehicle
    placeable;

/** Firing sounds */
var AudioComponent FiringAmbient;
var SoundCue FiringStopSound;

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

reliable server function ServerChangeSeat(int RequestedSeat)
{
	if ( RequestedSeat == 1 && Driver != None)
		return;
	super.ServerChangeSeat(RequestedSeat);
}

DefaultProperties
{

// in order to tweak these parameters, I always use "edit actor trace" in the PIE to adjust these values on the fly. Remember to write them down and put them in here later

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\
    Health=600
    bLightArmor=True
    MaxDesireability=0.8
    MomentumMult=0.3
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.0 		// 0.1
	LookForwardDist=0
    bHasHandbrake=true
    GroundSpeed=800
    AirSpeed=700
    MaxSpeed=1000 // 1500
    HornIndex=1
    COMOffset=(x=10.0,y=0.0,z=-55.0)
    bUsesBullets = false
    bOkAgainstBuildings=false
    bSecondaryFireTogglesFirstPerson=true
	
	
	/********Veterancy*******/
	
	//VP Given on death (by VRank)
	VPReward(0) = 8
	VPReward(1) = 10 
	VPReward(2) = 12
	VPReward(3) = 16

	VPCost(0) = 20
	VPCost(1) = 40
	VPCost(2) = 60
	
	Vet_HealthMod(0)=1 //600
	Vet_HealthMod(1)=1.083334 //650 
	Vet_HealthMod(2)=1.166667 //700
	Vet_HealthMod(3)=1.333334 //800
	
	Vet_SprintSpeedMod(0)=1.0
	Vet_SprintSpeedMod(1)=1.1
	Vet_SprintSpeedMod(2)=1.2
	Vet_SprintSpeedMod(3)=1.3
	
	/**************************/
		
		
		
		
	CustomGravityScaling=1.20

    HeavySuspensionShiftPercent=0.75f;
    bLookSteerOnNormalControls=true
    bLookSteerOnSimpleControls=true
    LookSteerSensitivity=2.2
    LookSteerDamping=0.07
    ConsoleSteerScale=1.1
    DeflectionReverseThresh=-0.3
	
	
    Begin Object Class=UDKVehicleSimCar Name=SimObject
        WheelSuspensionStiffness=350.0 // Controls the stiffness of the suspension spring for the wheels. There is no particular range on this value, but we have used values between 20.0 and 500.0.
        WheelSuspensionDamping=4.0 // Controls the damping of the suspension spring for the wheels. The larger this number, the less oscillation you will get on the suspension. Again, there is no particular range for this number, but we have used values between 1.0 and 75.0.
        WheelSuspensionBias=0.1 // Offset applied to the equilibrium position for the wheel suspension.
        ChassisTorqueScale=2.0
        MaxBrakeTorque=4.0
        StopThreshold=100

        MaxSteerAngleCurve=(Points=((InVal=0,OutVal=60),(InVal=675.0,OutVal=35.0), (InVal=750.0,OutVal=20.0))) // InVal is speed, OutVal is steering angle
        SteerSpeed=100 // the speed at which the steering happens, so how quickly the wheels can turn to steer

        LSDFactor=0.4

        // TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0),(InVal=0.0,OutVal=130.0),(InVal=950.0,OutVal=130.0),(InVal=1050.0,OutVal=10.0),(InVal=1150.0,OutVal=0.0)))
        TorqueVSpeedCurve=(Points=((InVal=-700.0,OutVal=0.0),(InVal=0.0,OutVal=130.0),(InVal=900.0,OutVal=10.0)))

        // EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=549.0,OutVal=3500.0),(InVal=550.0,OutVal=1000.0),(InVal=849.0,OutVal=4500.0),(InVal=850.0,OutVal=1500.0),(InVal=1100.0,OutVal=5000.0)))
        EngineRPMCurve=(Points=((InVal=-500.0,OutVal=3500.0),(InVal=0.0,OutVal=1500.0),(InVal=800.0,OutVal=4500.0), (InVal=1000.0,OutVal=6000.0)))

        EngineBrakeFactor=0.3 // the higher the number the faster the stop
        ThrottleSpeed=1.0
        WheelInertia=0.6 // The mass of the wheels. Used by PhysX to determine the wheel velocity that wheel torques can achieve. How 'heavy' and hard to turn the wheels are.
        NumWheelsForFullSteering=4
        SteeringReductionFactor=0.0
        SteeringReductionMinSpeed=800.0 // 1100
        SteeringReductionSpeed=1000.0 // 1400
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
        WheelLatAsymptoteValue=4.0

        bAutoDrive=false
        AutoDriveSteer=0.1
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Bus.Mesh.SK_VH_Bus' 
        AnimTreeTemplate=AnimTree'RX_VH_Bus.Anims.AT_VH_Bus'
        PhysicsAsset=PhysicsAsset'RX_VH_Bus.Mesh.SK_VH_Bus_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_Bus.Mesh.MT_VH_Bus'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Bus.Mesh.SK_VH_Bus'
	VehicleIconTexture=Texture2D'RX_VH_APC_Nod.UI.T_VehicleIcon_APC_Nod'
	MinimapIconTexture=Texture2D'RX_VH_APC_Nod.UI.T_MinimapIcon_APC_Nod'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_Bus_Weapon',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-350,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=DriverSocket,
                SeatOffset=(X=54,Y=296,Z=-25),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0), // https://wiki.beyondunreal.com/Legacy:Rotator (a full circle is 65536 RUUs)
				SeatBone=b_Root,
                MuzzleFlashLightClass=none,
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger1",
                CameraTag=CamViewP1,
                CameraBaseOffset=(Z=0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket1,
                SeatOffset=(X=41,Y=150,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
				
    Seats(2)={( GunClass=none,
				TurretVarPrefix="Passenger2",
                CameraTag=CamViewP2, // Camview3P
                CameraBaseOffset=(Z=0), //-20
                CameraOffset=0, //-350
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket2,
                SeatOffset=(X=69,Y=150,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
				
    Seats(3)={( GunClass=none,
				TurretVarPrefix="Passenger3",
                CameraTag=CamviewP3, 
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket3,
                SeatOffset=(X=-71,Y=150,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(4)={( GunClass=none,
				TurretVarPrefix="Passenger4",
                CameraTag=CamViewP4,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket4,
                SeatOffset=(X=69,Y=100,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(5)={( GunClass=none,
				TurretVarPrefix="Passenger5",
                CameraTag=CamViewP5,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket5,
                SeatOffset=(X=-71,Y=-54,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(6)={( GunClass=none,
				TurretVarPrefix="Passenger6",
                CameraTag=CamViewP6,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket6,
                SeatOffset=(X=69,Y=-50,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(7)={( GunClass=none,
				TurretVarPrefix="Passenger7",
                CameraTag=CamViewP7,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket7,
                SeatOffset=(X=-71,Y=50,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(8)={( GunClass=none,
				TurretVarPrefix="Passenger8",
                CameraTag=CamViewP8,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket8,
                SeatOffset=(X=69,Y=-4,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(9)={( GunClass=none,
				TurretVarPrefix="Passenger9",
                CameraTag=CamViewP9,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket9,
                SeatOffset=(X=-71,Y=-4,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(10)={( GunClass=none,
				TurretVarPrefix="Passenger10",
                CameraTag=CamViewP10,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket10,
                SeatOffset=(X=69,Y=-55,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(11)={( GunClass=none,
				TurretVarPrefix="Passenger11",
                CameraTag=CamViewP11,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket11,
                SeatOffset=(X=-71,Y=-55,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(12)={( GunClass=none,
				TurretVarPrefix="Passenger12",
                CameraTag=CamViewP12,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket12,
                SeatOffset=(X=69,Y=-153,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(13)={( GunClass=none,
				TurretVarPrefix="Passenger13",
                CameraTag=CamViewP13,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket13,
                SeatOffset=(X=-71,Y=-153,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(14)={( GunClass=none,
				TurretVarPrefix="Passenger14",
                CameraTag=CamViewP14,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket14,
                SeatOffset=(X=-43,Y=100,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(15)={( GunClass=none,
				TurretVarPrefix="Passenger15",
                CameraTag=CamViewP15,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket15,
                SeatOffset=(X=-43,Y=-50,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(16)={( GunClass=none,
				TurretVarPrefix="Passenger16",
                CameraTag=CamViewP16,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket16,
                SeatOffset=(X=-43,Y=-4,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(17)={( GunClass=none,
				TurretVarPrefix="Passenger17",
                CameraTag=CamViewP17,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket17,
                SeatOffset=(X=41,Y=-153,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(18)={( GunClass=none,
				TurretVarPrefix="Passenger18",
                CameraTag=CamViewP18,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket18,
                SeatOffset=(X=41,Y=100,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
								
    Seats(19)={( GunClass=none,
				TurretVarPrefix="Passenger19",
                CameraTag=CamViewP19,
                CameraBaseOffset=(Z=-0),
                CameraOffset=-0,
				bSeatVisible=true,
                SeatIconPos=(X=0.5,Y=0.33),
				SeatSocket=PassengerSocket19,
                SeatOffset=(X=41,Y=50,Z=-15),
                SeatRotation=(Pitch=0,Yaw=16384,Roll=0),
				SeatBone=b_Root,
                )}
				
	DrivingAnim=H_M_Seat_Apache

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Bus.Materials.PhysMat_BusDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Bus.Materials.PhysMat_Bus'
   
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustLeft)
    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=ExhaustRight)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

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
        SoundCue=SoundCue'RX_VH_Bus.Sounds.SC_Bus_Fire_Looping'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Bus.Sounds.SC_Bus_Fire_Stop'

    EnterVehicleSound=SoundCue'RX_VH_Humvee.Sounds.humvee_start_cue'
    ExitVehicleSound=SoundCue'RX_VH_Humvee.Sounds.humvee_stop_cue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'

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
	
	/*
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
	*/

//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

    Begin Object class=Rx_Vehicle_Bus_Wheel Name=RRWheel
      BoneName="wheel_rearright"
      SkelControlName="Rt_Rear_Control"
	  LongSlipFactor=1.0 // was 2.0
      LatSlipFactor=1.0 // was 2.0
      HandbrakeLongSlipFactor=0.35
      HandbrakeLatSlipFactor=0.35
   End Object
   Wheels(0)=RRWheel

   Begin Object class=Rx_Vehicle_Bus_Wheel Name=LRWheel
      BoneName="wheel_rearleft"
      SkelControlName="Lt_Rear_Control"
	  LongSlipFactor=1.0 // was 2.0
      LatSlipFactor=1.0 // was 2.0
      HandbrakeLongSlipFactor=0.35
      HandbrakeLatSlipFactor=0.35
   End Object
   Wheels(1)=LRWheel

   Begin Object class=Rx_Vehicle_Bus_Wheel Name=RFWheel
      BoneName="wheel_frontright"
      SkelControlName="Rt_Front_Control"
      SteerFactor=1.00
	  LongSlipFactor=1.0 // was 2.0
      LatSlipFactor=1.0	  // was 2.0
   End Object
   Wheels(2)=RFWheel

   Begin Object class=Rx_Vehicle_Bus_Wheel Name=LFWheel
      BoneName="wheel_frontleft"
      SkelControlName="Lt_Front_Control"
      SteerFactor=1.00
	  LongSlipFactor=1.0 // was 2.0
      LatSlipFactor=1.0 // was 2.0
   End Object
   Wheels(3)=LFWheel
}