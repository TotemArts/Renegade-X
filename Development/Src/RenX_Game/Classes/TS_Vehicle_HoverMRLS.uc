/*********************************************************
*
* File: TS_Vehicle_HoverMRLS.uc
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
class TS_Vehicle_HoverMRLS extends Rx_Vehicle
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
		WheelSuspensionStiffness=24.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=360.0
		MaxReverseForce=300.0
		LongDamping=0.6
		MaxStrafeForce=180.0
		DirectionChangeForce=450.0
		LatDamping=1.2
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
        SkeletalMesh=SkeletalMesh'TS_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS'
        AnimTreeTemplate=AnimTree'TS_VH_HoverMRLS.Anim.AT_VH_HoverMRLS'
        PhysicsAsset=PhysicsAsset'TS_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS_Physics'
		MorphSets[0]=MorphTargetSet'TS_VH_HoverMRLS.Mesh.MT_VH_HoverMRLS'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_HoverMRLS.Mesh.SK_VH_HoverMRLS'
	
	VehicleIconTexture=Texture2D'TS_VH_HoverMRLS.Materials.T_VehicleIcon_HoverMRLS'
	MinimapIconTexture=Texture2D'TS_VH_HoverMRLS.Materials.T_RadarBlip_HoverMRLS'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_HoverMRLS_Weapon',
                GunSocket=(Fire_L,Fire_R),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-24),
                CameraOffset=-660,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={(	CameraTag=CamView3P,
				TurretVarPrefix="Passenger",
                CameraBaseOffset=(Z=-24),
                CameraOffset=-660,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_HoverMRLS.Materials.PhysMat_HoverMRLS_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_HoverMRLS.Materials.PhysMat_HoverMRLS'

    RecoilTriggerTag = "TurretFire01", "TurretFire02"
    VehicleEffects(0)=(EffectStartTag=TurretFire02,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket=Fire_L)
    VehicleEffects(1)=(EffectStartTag=TurretFire01,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket=Fire_R)
	
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSteam01)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks01))
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
	VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire02)


	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Snow')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_WhiteSand')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_YellowSand')
	DefaultWheelPSCTemplate=ParticleSystem'TS_VH_HoverMRLS.Wheel.P_FX_Wheel_Dirt'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=b_Root,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=b_Turret_Yaw,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage2))
    DamageMorphTargets(6)=(InfluenceBone=b_Wheel_FL,MorphNodeName=MorphNodeW_Ch_L,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=b_Wheel_FR,MorphNodeName=MorphNodeW_Ch_R,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

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
		BoneOffset=(X=100.0,Y=-80.0,Z=-240.0)
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
		BoneOffset=(X=-100.0,Y=-80.0,Z=-240.0)
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
		BoneOffset=(X=100.0,Y=80.0,Z=-240.0)
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
		BoneOffset=(X=-100.0,Y=80.0,Z=-240.0)
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
		BoneOffset=(X=220.0,Y=-100.0,Z=-240.0)
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
		BoneOffset=(X=-220.0,Y=-100.0,Z=-240.0)
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
		BoneOffset=(X=220.0,Y=100.0,Z=-240.0)
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
		BoneOffset=(X=-220.0,Y=100.0,Z=-240.0)
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
