/*********************************************************
*
* File: RxVehicle_FlameTank.uc
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
class Rx_Vehicle_FlameTank extends Rx_Vehicle_Treaded
    placeable;


    
    
/** Flame sounds */
var() AudioComponent FlameAmbient;
var() SoundCue FlameBeginSound;
var() SoundCue FlameStopSound;
var   SoundCue Snd_FlameAmbient_Heroic;

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    VehicleEvent('FlameLeft');
    VehicleEvent('FlameRight');

    if (!FlameAmbient.bWasPlaying)
    {
        PlaySound(FlameBeginSound, TRUE, FALSE, FALSE, Location, FALSE);
        FlameAmbient.Play();
    }
}

simulated function VehicleWeaponStoppedFiring(bool bViaReplication, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
            VehicleEvent('STOP_FlameLeft');
            VehicleEvent('STOP_FlameRight');
        }
    }

    PlaySound(FlameStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FlameAmbient.Stop();
}

function bool ValidEnemyForVehicle(Pawn NewEnemy)
{
	if(NewEnemy.Physics == PHYS_Flying 
		&& (Abs(Normalize(rotation).Pitch - rotator(location - NewEnemy.location).Pitch) > 5000)) {
		//loginternal("1");
		return false;	
	} 
	if(VSize(location - NewEnemy.location) < Weapon.MaxRange()) {
		//loginternal("2");
		return true;	
	}
	if(UTBot(Controller).FindPathToward(NewEnemy) == None) {
		//loginternal("3");
		return false;	
	}
	return true;
}

simulated function SetHeroicMuzzleFlash(bool SetTrue)
 {
	super.SetHeroicMuzzleFlash(SetTrue);
	if(SetTrue) FlameAmbient.SoundCue=Snd_FlameAmbient_Heroic;
	else
	FlameAmbient.SoundCue=FlameAmbient.default.SoundCue; 
 }

DefaultProperties
{



//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=800
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.4
	LookForwardDist=350
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=-10.0,y=0.0,z=-60.0)
	bSecondaryFireTogglesFirstPerson=true
	
	SprintTrackTorqueFactorDivident=0.975
	
	BarrelLength(0)=150
	BarrelLength(1)=150
	
/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16 
	
	VPCost(0) = 30
	VPCost(1) = 70
	VPCost(2) = 150

Vet_HealthMod(0)=1 //800
Vet_HealthMod(1)=1.125 //900 
Vet_HealthMod(2)=1.25 //1000
Vet_HealthMod(3)=1.375 //1100
	
Vet_SprintSpeedMod(0)=1
Vet_SprintSpeedMod(1)=1.05
Vet_SprintSpeedMod(2)=1.10
Vet_SprintSpeedMod(3)=1.15
	
// +X as opposed to *X
Vet_SprintTTFD(0)=0
Vet_SprintTTFD(1)=0.05//0
Vet_SprintTTFD(2)=0.1
Vet_SprintTTFD(3)=0.15



/**********************/

Snd_FlameAmbient_Heroic=SoundCue'RX_VH_FlameTank.Sounds.SC_FlameTank_Fire_Heroic'
	
	
    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=80
        WheelSuspensionDamping=4.0
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
        WheelLatAsymptoteSlip=1.4
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=3
        InsideTrackTorqueFactor=0.35
        TurnInPlaceThrottle=0.25
        TurnMaxGripReduction=0.995
        TurnGripScaleRate=0.8
        MaxEngineTorque=6000
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_FlameTank.Mesh.SK_VH_FlameTank'
        AnimTreeTemplate=AnimTree'RX_VH_FlameTank.Anims.AT_VH_FlameTank'
        PhysicsAsset=PhysicsAsset'RX_VH_FlameTank.Mesh.SK_VH_FlameTank_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_FlameTank.Mesh.MT_VH_FlameTank'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_FlameTank.Mesh.SK_PTVH_FlameTank'


	VehicleIconTexture=Texture2D'RX_VH_FlameTank.UI.T_VehicleIcon_FlameTank'
	MinimapIconTexture=Texture2D'RX_VH_FlameTank.UI.T_MinimapIcon_FlameTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_FlameTank_Weapon',
                GunSocket=(Fire01,Fire02),
                TurretControls=("TurretPitch","TurretRotate"),
                TurretVarPrefix="",
                GunPivotPoints=("MainTurretYaw"),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraOffset=-460,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-460,
                )}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_FlameTank.Materials.PhysMat_FlameTank_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_FlameTank.Materials.PhysMat_FlameTank'

//    VehicleEffects(0)=(EffectStartTag="FlameLeft",EffectEndTag="STOP_FlameLeft",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.FX_FlameThrower_Full',EffectSocket="Fire01")
//    VehicleEffects(1)=(EffectStartTag="FlameRight",EffectEndTag="STOP_FlameRight",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.FX_FlameThrower_Full',EffectSocket="Fire02")
//	VehicleEffects(0)=(EffectStartTag="FlameLeft",EffectEndTag="STOP_FlameLeft",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.FX_FlameThrower_Semi',EffectSocket="Fire01")
//	VehicleEffects(1)=(EffectStartTag="FlameRight",EffectEndTag="STOP_FlameRight",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.FX_FlameThrower_Semi',EffectSocket="Fire02")
	VehicleEffects(2)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_IgnitionFlame',EffectSocket="FlameSocket_L")
    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_IgnitionFlame',EffectSocket="FlameSocket_R")
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke02)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks01)
    VehicleEffects(9)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks02)
    VehicleEffects(10)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(11)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire02)

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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_FlameTank.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_Front,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
	DamageMorphTargets(1)=(InfluenceBone=MT_Rear,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
	DamageMorphTargets(2)=(InfluenceBone=MT_Turret_Front,MorphNodeName=MorphNodeW_Turret_Front,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=MT_Turret_Left,MorphNodeName=MorphNodeW_Turret_Left,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(4)=(InfluenceBone=MT_Turret_Right,MorphNodeName=MorphNodeW_Turret_Right,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(5)=(InfluenceBone=MT_Turret_Rear,MorphNodeName=MorphNodeW_Turret_Rear,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_MediumTank.Sounds.Med_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_StopCue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'
    
    Begin Object Class=AudioComponent name=FlameAmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_FlameTank.Sounds.SC_FlameTank_Fire'
    End Object
    FlameAmbient=FlameAmbientSoundComponent
    Components.Add(FlameAmbientSoundComponent)

    FlameBeginSound=SoundCue'RX_VH_FlameTank.Sounds.SC_FlameTank_Fire_Start'
    FlameStopSound=SoundCue'RX_VH_FlameTank.Sounds.SC_FlameTank_Fire_End'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_01
        BoneName="Wheel_RB_01"
        SkelControlName="Wheel_RB_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=RB_Wheel_01

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_02
        BoneName="Wheel_RB_02"
        SkelControlName="Wheel_RB_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=RB_Wheel_02

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_03
        BoneName="Wheel_RB_03"
        SkelControlName="Wheel_RB_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=RB_Wheel_03

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_04
        BoneName="Wheel_RB_04"
        SkelControlName="Wheel_RB_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=RB_Wheel_04

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_05
        BoneName="Wheel_RB_05"
        SkelControlName="Wheel_RB_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RB_Wheel_05

     Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=RB_Wheel_06
        BoneName="Wheel_RB_06"
        SkelControlName="Wheel_RB_06_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=RB_Wheel_06


    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_01
        BoneName="Wheel_LB_01"
        SkelControlName="Wheel_LB_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(6)=LB_Wheel_01

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_02
        BoneName="Wheel_LB_02"
        SkelControlName="Wheel_LB_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=LB_Wheel_02

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_03
        BoneName="Wheel_LB_03"
        SkelControlName="Wheel_LB_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=LB_Wheel_03

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_04
        BoneName="Wheel_LB_04"
        SkelControlName="Wheel_LB_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=LB_Wheel_04

    Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_05
        BoneName="Wheel_LB_05"
        SkelControlName="Wheel_LB_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=LB_Wheel_05

     Begin Object Class=Rx_Vehicle_FlameTank_Wheel Name=LB_Wheel_06
        BoneName="Wheel_LB_06"
        SkelControlName="Wheel_LB_06_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=LB_Wheel_06

}
