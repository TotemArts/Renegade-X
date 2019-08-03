/*********************************************************
*
* File: TS_Vehicle_Wolverine.uc
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
class TS_Vehicle_Wolverine extends Rx_Vehicle_Treaded
    placeable;

	
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;
	
var GameSkelCtrl_Recoil    Recoil_Barrel, Recoil_Cannon;

var SkeletalMeshComponent AntennaMesh;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(AntennaMesh,'AntennaSocket');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMesh.FindSkelControl('Beam'));


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
}


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    VehicleEvent('Fire_Right');
	VehicleEvent('Fire_Left');
    
    if (!FiringAmbient.bWasPlaying)
    {
        FiringAmbient.Play();
    }
}
    
simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
    }
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponStoppedFiring(bViaReplication,SeatIndex);
    }
    
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
            VehicleEvent('STOP_Fire_Right');
			VehicleEvent('STOP_Fire_Left');
        }
    }

    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
}



    
DefaultProperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    bRotateCameraUnderVehicle=true
    bSecondaryFireTogglesFirstPerson=true
    Health=350
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.4
    LookForwardDist=200
    GroundSpeed=300
    MaxSpeed=500
    LeftStickDirDeadZone=0.1
    TurnTime=18
    ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-55.0)

	bStayUpright=true
	StayUprightRollResistAngle=15.0
	StayUprightPitchResistAngle=15.0
	StayUprightStiffness=2000
	StayUprightDamping=25
	
	UprightLiftStrength=50.0
	UprightTorqueStrength=50.0
	
	CustomGravityScaling=2.0

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=60
        WheelSuspensionDamping=20.0
        WheelSuspensionBias=0.0

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.5
        WheelLongExtremumValue=2.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
           WheelLatExtremumSlip=0.5 //0.35     // 20 degrees
        WheelLatExtremumValue=4.0
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=5
        InsideTrackTorqueFactor=0.35
        TurnInPlaceThrottle=0.35
        TurnMaxGripReduction=0.995
        TurnGripScaleRate=0.8
        MaxEngineTorque=5000
        End Object
    SimObj=SimObject
    Components.Add(SimObject)

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TS_VH_Wolverine.Mesh.SK_VH_Wolverine_Reborn'
        AnimTreeTemplate=AnimTree'TS_VH_Wolverine.Anims.AT_VH_Wolverine_Reborn'
		AnimSets.Add(AnimSet'TS_VH_Wolverine.Anims.AS_VH_Wolverine_Reborn')
        PhysicsAsset=PhysicsAsset'TS_VH_Wolverine.Mesh.SK_VH_Wolverine_Reborn_Physics'
		MorphSets[0]=MorphTargetSet'TS_VH_Wolverine.Mesh.MT_VH_Wolverine_Reborn'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'TS_VH_Wolverine.Mesh.SK_VH_Wolverine_Reborn'
	
	VehicleIconTexture=Texture2D'TS_VH_Wolverine.Materials.T_VehicleIcon_Wolverine'
	MinimapIconTexture=Texture2D'TS_VH_Wolverine.Materials.T_RadarBlip_Wolverine'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMesh
		SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
		LightEnvironment = MyLightEnvironment
		Scale=0.6
	End Object
	AntennaMesh=SAntennaMesh

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_Wolverine_Weapon',
                GunSocket=("Fire_L", "Fire_R"),
                TurretControls=(TurretPitch,TurretRotate),
				TurretVarPrefix="",
                GunPivotPoints=(b_Turret_Pitch,b_Turret_Yaw),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=0,Z=-0),
                CameraOffset=-450,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_Wolverine.Materials.PhysMat_Wolverine_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_Wolverine.Materials.PhysMat_Wolverine'

    RecoilTriggerTag = "Fire_Right", "Fire_Left"
    VehicleEffects(0)=(EffectStartTag="Fire_Left",EffectEndTag="STOP_Fire_Left",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Wolverine.Effects.P_MuzzleFlash_Gun',EffectSocket="Fire_L")
	VehicleEffects(1)=(EffectStartTag="Fire_Right",EffectEndTag="STOP_Fire_Right",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Wolverine.Effects.P_MuzzleFlash_Gun',EffectSocket="Fire_R")
	VehicleEffects(2)=(EffectStartTag="Fire_Left",EffectEndTag="STOP_Fire_Left",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Wolverine.Effects.P_ShellCasing',EffectSocket="ShellEjectSocket_L")
	VehicleEffects(3)=(EffectStartTag="Fire_Right",EffectEndTag="STOP_Fire_Right",bRestartRunning=false,EffectTemplate=ParticleSystem'TS_VH_Wolverine.Effects.P_ShellCasing',EffectSocket="ShellEjectSocket_R")
	
	VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSteam01)
	VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
	VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks03)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSpark01))
    VehicleEffects(9)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)

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
	
	DamageMorphTargets(0)=(InfluenceBone=b_Turret_Base,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
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
        SoundCue=SoundCue'TS_VH_Wolverine.Sounds.SC_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'TS_VH_Titan.Sounds.SC_Start'
    ExitVehicleSound=SoundCue'TS_VH_Titan.Sounds.SC_Stop'
	
	TireSoundList(0)=(MaterialType=Dirt,Sound=None)
	TireSoundList(1)=(MaterialType=Foliage,Sound=None)
	TireSoundList(2)=(MaterialType=Grass,Sound=None)
	TireSoundList(3)=(MaterialType=Metal,Sound=None)
	TireSoundList(4)=(MaterialType=Mud,Sound=None)
	TireSoundList(5)=(MaterialType=Snow,Sound=None)
	TireSoundList(6)=(MaterialType=Stone,Sound=None)
	TireSoundList(7)=(MaterialType=Water,Sound=None)
	TireSoundList(8)=(MaterialType=Wood,Sound=None)
	
	Begin Object Name=ScorpionTireSound
		SoundCue=none
	End Object
	TireAudioComp=ScorpionTireSound
		
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'TS_VH_Wolverine.Sounds.SC_Fire_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Stop'

//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RFThruster
		BoneName="b_Root"
		BoneOffset=(X=70.0,Y=70.0,Z=-210.0)
		WheelRadius=40
		SuspensionTravel=140
		Side=SIDE_Right
	End Object
	Wheels(0)=RFThruster

	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LFThruster
		BoneName="b_Root"
		BoneOffset=(X=70.0,Y=-70.0,Z=-210.0)
		WheelRadius=40
		SuspensionTravel=140
		Side=SIDE_Left
	End Object
	Wheels(1)=LFThruster
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=RRThruster
		BoneName="b_Root"
		BoneOffset=(X=-70.0,Y=70.0,Z=-210.0)
		WheelRadius=40
		SuspensionTravel=140
		Side=SIDE_Right
	End Object
	Wheels(2)=RRThruster
	
	Begin Object Class=Rx_Vehicle_MediumTank_Wheel Name=LRThruster
		BoneName="b_Root"
		BoneOffset=(X=-70.0,Y=-70.0,Z=-210.0)
		WheelRadius=40
		SuspensionTravel=140
		Side=SIDE_Left
	End Object
	Wheels(3)=LRThruster

	/************************/
	/*Veterancy Multipliers*/
	/***********************/

	//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16 

	Vet_HealthMod(0)=1.0 //350
	Vet_HealthMod(1)=1.142858 //400 
	Vet_HealthMod(2)=1.285715 //450
	Vet_HealthMod(3)=1.4285715 //500
		
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1.05
	Vet_SprintSpeedMod(2)=1.10
	Vet_SprintSpeedMod(3)=1.15
		
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)=0.05
	Vet_SprintTTFD(2)=0.10
	Vet_SprintTTFD(3)=0.15

/**********************/

}
