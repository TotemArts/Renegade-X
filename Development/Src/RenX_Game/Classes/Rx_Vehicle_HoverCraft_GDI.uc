/*********************************************************
*
* File: Rx_Vehicle_HoverCraft_GDI.uc
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
class Rx_Vehicle_HoverCraft_GDI extends Rx_Vehicle
	placeable;
	
	
	
simulated function vector GetEffectLocation(int SeatIndex)
{

    local vector SocketLocation;
   local name FireTriggerTag;

    if ( Seats[SeatIndex].GunSocket.Length <= 0 )
        return Location;

   FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}



// special for mammoth
simulated event GetBarrelLocationAndRotation(int SeatIndex, out vector SocketLocation, optional out rotator SocketRotation)
{
    if (Seats[SeatIndex].GunSocket.Length > 0)
    {
        Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)], SocketLocation, SocketRotation);
    }
    else
    {
        SocketLocation = Location;
        SocketRotation = Rotation;
    }
}

simulated function int GetBarrelIndex(int SeatIndex)
{
   local int OldBarrelIndex;
   OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
   if (Weapon == none)
      return OldBarrelIndex;

   return (Weapon.CurrentFireMode == 0 ? OldBarrelIndex % 2 : (OldBarrelIndex % 2) + 2);
}



DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


	Health=1200
	bLightArmor=false
	MaxDesireability=0.2
	MomentumMult=0.7
	bSeparateTurretFocus=true
	bTakeWaterDamageWhileDriving=false
	bHasHandbrake=false
	bTurnInPlace=true
	bCanStrafe=true
	bCanFlip=true
	bFollowLookDir=true
	GroundSpeed=600
	AirSpeed=2000
	MaxSpeed=800
	HornIndex=1
	COMOffset=(x=0.0,y=0.0,z=0.0)

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	CustomGravityScaling=0.8
	WaterDamage=0.0
	
	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20

	Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=150.0
		WheelSuspensionDamping=4.0
		WheelSuspensionBias=0.0
		MaxThrustForce=3000.0
		MaxReverseForce=2000.0
		LongDamping=10.0
		MaxStrafeForce=1000.0
		DirectionChangeForce=4000.0
		StopThreshold=20
		LatDamping=15.0
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=80000.0
		TurnTorqueMax=120000.0
		TurnDamping=100
		MaxYawRate=100000.0
		PitchTorqueFactor=-8000.0
		PitchTorqueMax=18000.0
		PitchDamping=30.0
		RollTorqueTurnFactor=-16000.0
		RollTorqueStrafeFactor=8000.0
		RollTorqueMax=50000.0
		RollDamping=30.0
		MaxRandForce=10000.0
		RandForceInterval=0.4
		bAllowZThrust=false
	End Object
	SimObj=SimObject
	Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'RX_VH_HoverCraft.Mesh.SK_VH_HoverCraft'
		AnimTreeTemplate=AnimTree'RX_VH_HoverCraft.Anims.AT_VH_HoverCraft'
		PhysicsAsset=PhysicsAsset'RX_VH_HoverCraft.Mesh.SK_VH_HoverCraft_Physics'
		//MorphSets[0]=MorphTargetSet'RX_VH_Humvee.Mesh.MT_VH_Humvee'
	End Object

	DrawScale=1.0


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


	Seats(0)={(GunClass=class'Rx_Vehicle_Hovercraft_GDI_Weapon',
				GunSocket=("FireCannonL","FireCannonR","FireL","FireR"),
				TurretVarPrefix="",
				CameraTag=CamView3P,
				CameraBaseOffset=(X=-75,Z=0),
				CameraOffset=-1500,
				SeatIconPos=(X=0.5,Y=0.33),
				MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				)}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


	BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'
	BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'

	DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_HoverCraft.Materials.PhysMat_HoverCraft_Driving'
	DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_HoverCraft.Materials.PhysMat_HoverCraft'

	VehicleEffects(0)=(EffectStartTag="FireR",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireR")
	VehicleEffects(1)=(EffectStartTag="FireL",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireL")
	
	VehicleEffects(2)=(EffectStartTag="FireCannonR",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireCannonR")
	VehicleEffects(3)=(EffectStartTag="FireCannonL",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireCannonL")
	
	VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
	VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke02)
	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_R_1)
	VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_R_3)
	VehicleEffects(8)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_L_1)
	VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_L_3)
	VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_FanDistortion',EffectSocket=Fan_Left)
	VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_FanDistortion',EffectSocket=Fan_Right)
	
	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	MaxGroundEffectDist=256.0
	GroundEffectIndices=(12,13)
	WaterGroundEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Manta_Water_Effects'



//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

	Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'RX_VH_HoverCraft.Sounds.SC_HoverCraft_Idle'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound);
	
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	ExplosionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Explode'
    CollisionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
    EnterVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_startCue'
	ExitVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_StopCue'

	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0
	EngineStartOffsetSecs=0.5
	EngineStopOffsetSecs=0.5


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

	Begin Object Class=UTHoverWheel Name=RFThruster
		BoneName="b_Base"
		BoneOffset=(X=850.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=RFThruster

	Begin Object Class=UTHoverWheel Name=LFThruster
		BoneName="b_Base"
		BoneOffset=(X=850.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=LFThruster

	Begin Object Class=UTHoverWheel Name=RMThruster
		BoneName="b_Base"
		BoneOffset=(X=0.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=RMThruster
	
	Begin Object Class=UTHoverWheel Name=LMThruster
		BoneName="b_Base"
		BoneOffset=(X=0.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(3)=LMThruster

	Begin Object Class=UTHoverWheel Name=RRThruster
		BoneName="b_Base"
		BoneOffset=(X=-850.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(4)=RRThruster
	
	Begin Object Class=UTHoverWheel Name=LRThruster
		BoneName="b_Base"
		BoneOffset=(X=-850.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(5)=LRThruster
	
	Begin Object Class=UTHoverWheel Name=CThruster
		BoneName="b_Base"
		BoneOffset=(X=-0.0,Y=-0.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(6)=CThruster
	
}