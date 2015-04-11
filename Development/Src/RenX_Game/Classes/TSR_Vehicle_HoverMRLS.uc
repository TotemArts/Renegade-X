/*********************************************************
*
* File: TSR_Vehicle_HoverMRLS.uc
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
class TSR_Vehicle_HoverMRLS extends Rx_Vehicle
    placeable;

	
DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=400
	bLightArmor=True
	MaxDesireability=0.4
	MomentumMult=0.7
	bSeparateTurretFocus=true
	bTakeWaterDamageWhileDriving=false
	bHasHandbrake=false
	bTurnInPlace=true
	bCanStrafe=true
	bCanFlip=true
	bFollowLookDir=false
	GroundSpeed=400
	AirSpeed=2000
	MaxSpeed=800
	HornIndex=1
	COMOffset=(x=0.0,y=0.0,z=0.0)

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	CustomGravityScaling=0.6
	WaterDamage=0.0
	
	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20

	Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=20.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=300.0
		MaxReverseForce=250.0
		LongDamping=0.5
		MaxStrafeForce=150.0
		DirectionChangeForce=375.0
		LatDamping=1.0
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=2500.0
		TurnTorqueMax=500.0
		TurnDamping=0.25
		MaxYawRate=10000.0
		PitchTorqueFactor=500.0
		PitchTorqueMax=2000
		PitchDamping=0.3
		RollTorqueTurnFactor=750.0
		RollTorqueStrafeFactor=200.0
		RollTorqueMax=500.0
		RollDamping=0.2
		MaxRandForce=500.0
		RandForceInterval=0.3
		bAllowZThrust=false
		StopThreshold=10
	End Object
	SimObj=SimObject
	Components.Add(SimObject)



//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TSR_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS'
        AnimTreeTemplate=AnimTree'TSR_VH_HoverMRLS.Anim.AT_VH_HoverMRLS'
        PhysicsAsset=PhysicsAsset'TSR_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TSR_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TSR_Vehicle_HoverMRLS_Weapon',
                GunSocket=(Fire_L,Fire_R),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-550,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={(	CameraTag=CamView3P,
				TurretVarPrefix="Passenger",
                CameraBaseOffset=(Z=20),
                CameraOffset=-550,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'TSR_VH_HoverMRLS.Materials.PhysMat_HoverMRLS_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TSR_VH_HoverMRLS.Materials.PhysMat_HoverMRLS'

    RecoilTriggerTag = "TurretFire01", "TurretFire02"
    VehicleEffects(0)=(EffectStartTag=TurretFire02,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket=Fire_L)
    VehicleEffects(1)=(EffectStartTag=TurretFire01,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket=Fire_R)

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Snow')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_WhiteSand')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_YellowSand')
	DefaultWheelPSCTemplate=ParticleSystem'TSR_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'RX_VH_HoverCraft.Sounds.SC_HoverCraft_Idle'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound);
    
    EnterVehicleSound=SoundCue'RX_VH_MRLS.Sounds.MRLS_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MRLS.Sounds.MRLS_stopCue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object Class=UTHoverWheel Name=FLThruster
		BoneName="b_Root"
		BoneOffset=(X=100.0,Y=-80.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=FLThruster

	Begin Object Class=UTHoverWheel Name=RLThruster
		BoneName="b_Root"
		BoneOffset=(X=-100.0,Y=-80.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=RLThruster

	Begin Object Class=UTHoverWheel Name=FRThruster
		BoneName="b_Root"
		BoneOffset=(X=100.0,Y=80.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=FRThruster
	
	Begin Object Class=UTHoverWheel Name=RRThruster
		BoneName="b_Root"
		BoneOffset=(X=-100.0,Y=80.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(3)=RRThruster
	
	
	
	
	
	Begin Object Class=UTHoverWheel Name=FLThrusterFar
		BoneName="b_Root"
		BoneOffset=(X=220.0,Y=-100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(4)=FLThrusterFar

	Begin Object Class=UTHoverWheel Name=RLThrusterFar
		BoneName="b_Root"
		BoneOffset=(X=-220.0,Y=-100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(5)=RLThrusterFar

	Begin Object Class=UTHoverWheel Name=FRThrusterFar
		BoneName="b_Root"
		BoneOffset=(X=220.0,Y=100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(6)=FRThrusterFar
	
	Begin Object Class=UTHoverWheel Name=RRThrusterFar
		BoneName="b_Root"
		BoneOffset=(X=-220.0,Y=100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=250
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(7)=RRThrusterFar
	
}
