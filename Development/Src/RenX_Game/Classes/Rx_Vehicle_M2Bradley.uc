/*********************************************************
*
* File: Rx_Vehicle_M2Bradley.uc
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
class Rx_Vehicle_M2Bradley extends Rx_Vehicle_Treaded
    placeable;


var SkeletalMeshComponent AntennaMeshM;
var SkeletalMeshComponent AntennaMeshR;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;

var GameSkelCtrl_Recoil    Recoil_L, Recoil_R, Recoil_Rocket_R, Recoil_Rocket_L;


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


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    Super.PostInitAnimTree(SkelComp);



    if (SkelComp == Mesh)
    {
        Recoil_R = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil') );
        Recoil_L = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil') );

        Recoil_Rocket_R = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Rocket') );
        Recoil_Rocket_L = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Rocket') );
    }
}


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
   local Name FireTriggerTag;

   Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);

   //`Log("VehicleWeaponFireEffects called",, '_Mammoth_Debug');
   FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   if(Weapon != None) {
       if (Weapon.CurrentFireMode == 0)
       {
           switch(FireTriggerTag)
          {
          case 'FireR':
             Recoil_L.bPlayRecoil = TRUE;
             break;
    
          case 'FireL':
             Recoil_R.bPlayRecoil = TRUE;
             break;
          }
       }
       else
       {
          switch(FireTriggerTag)
          {
          case 'AltFireL':
             Recoil_Rocket_L.bPlayRecoil = TRUE;
             break;
    
          case 'AltFireR':
             Recoil_Rocket_R.bPlayRecoil = TRUE;
             break;
          }
       }
   }
}



/** This bit here will attach all of the seperate antennas and towing rings that jiggle about when the vehicle moves **/
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(AntennaMeshM,'Antenna_M');
	Mesh.AttachComponentToSocket(AntennaMeshR,'Antenna_R');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshM.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('Beam'));


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



DefaultProperties
{

    Begin Object Name=CollisionCylinder
    CollisionHeight=160.0
    CollisionRadius=200.0
    Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=600
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.1 //0.25
	LookForwardDist=200
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=0
    COMOffset=(x=10.0,y=0.0,z=-30.0)
    bSecondaryFireTogglesFirstPerson=false
	
	SprintTrackTorqueFactorDivident=1.1//1.035

/************************/
/*Veterancy Multipliers*/
/***********************/

//VP Given on death (by VRank)
	VPReward(0) = 6 //7 
	VPReward(1) = 8// 9 
	VPReward(2) = 10 //12 
	VPReward(3) = 13// 15 
	
	VPCost(0) = 30
	VPCost(1) = 60
	VPCost(2) = 120

	Vet_HealthMod(0)=1 //600
	Vet_HealthMod(1)=1.125 //675
	Vet_HealthMod(2)=1.25 //750
	Vet_HealthMod(3)= 1.375 //825
		
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1.05
	Vet_SprintSpeedMod(2)=1.1
	Vet_SprintSpeedMod(3)=1.2
		
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)= 0.05
	Vet_SprintTTFD(2)= 0.10
	Vet_SprintTTFD(3)= 0.15

	Heroic_MuzzleFlash=ParticleSystem'RX_VH_M2Bradley.Effects.P_MuzzleFlash_Gun'

	BarrelLength(0)=400
	BarrelLength(1)=100
	BarrelLength(2)=100
	BarrelLength(3)=100
	BarrelLength(4)=100
	BarrelLength(5)=100

/**********************/
	
    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=75
        WheelSuspensionDamping=4.0
        WheelSuspensionBias=0.1

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
        EngineDamping=4.0
        InsideTrackTorqueFactor=0.375
        TurnInPlaceThrottle=0.285 //0.225
        TurnMaxGripReduction=0.995 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=11000 //15000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_M2Bradley.Mesh.SK_VH_M2Bradley'
        AnimTreeTemplate=AnimTree'RX_VH_M2Bradley.Anims.AT_VH_M2Bradley'
        PhysicsAsset=PhysicsAsset'RX_VH_M2Bradley.Mesh.SK_VH_M2Bradley_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_M2Bradley.Mesh.MT_VH_M2Bradley'
    End Object

    DrawScale=1.0
    
    Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshM
		SkeletalMesh=SkeletalMesh'RX_VH_LightTank.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_LightTank.Anims.AT_Antenna'
		MorphSets[0]=MorphTargetSet'RX_VH_M2Bradley.Mesh.MT_VH_M2Bradley'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshM=SAntennaMeshM
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshR=SAntennaMeshR
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_M2Bradley.Mesh.SK_VH_M2Bradley'

	VehicleIconTexture=Texture2D'RX_VH_M2Bradley.UI.T_VehicleIcon_M2Bradley'
	MinimapIconTexture=Texture2D'RX_VH_M2Bradley.UI.T_RadarBlip_M2Bradley'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_M2Bradley_Weapon',
                GunSocket=("FireL", "FireR", "AltFireL", "AltFireR"),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
				SeatBone=b_Root,
				SeatSocket=VH_Death,
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-400,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-400,
                )}
               
	Seats(2)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-400,
                )}
/*                 
	Seats(3)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-400,
                )}
*/

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_LightTank.Materials.MI_VH_Burnout'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_LightTank.Materials.MI_VH_Burnout'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_M2Bradley.Materials.PhysMat_M2Bradley_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_M2Bradley.Materials.PhysMat_M2Bradley'

    RecoilTriggerTag = "FireL", "FireR", "AltFireL", "AltFireR"
    VehicleEffects(0)=(EffectStartTag="FireL",EffectTemplate=ParticleSystem'RX_VH_M2Bradley.Effects.P_MuzzleFlash_Gun',EffectSocket="FireL")
    VehicleEffects(1)=(EffectStartTag="FireR",EffectTemplate=ParticleSystem'RX_VH_M2Bradley.Effects.P_MuzzleFlash_Gun',EffectSocket="FireR")
	VehicleEffects(2)=(EffectStartTag="AltFireL",EffectTemplate=ParticleSystem'RX_VH_M2Bradley.Effects.P_MuzzleFlash_Rocket',EffectSocket="AltFireL")
	VehicleEffects(3)=(EffectStartTag="AltFireR",EffectTemplate=ParticleSystem'RX_VH_M2Bradley.Effects.P_MuzzleFlash_Rocket',EffectSocket="AltFireR")
	
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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_M2Bradley.Effects.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Front,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=150,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Left,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=75,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_Right,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=75,DamagePropNames=(Damage2))
    DamageMorphTargets(3)=(InfluenceBone=MT_Back,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=150,DamagePropNames=(Damage3))
    DamageMorphTargets(4)=(InfluenceBone=MT_Turret,MorphNodeName=MorphNodeW_Top,LinkedMorphNodeName=none,Health=150,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=4.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=4.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=4.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=4.0)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_LightTank.Sounds.Light_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'RX_VH_LightTank.Sounds.Light_startCue'
    ExitVehicleSound=SoundCue'RX_VH_LightTank.Sounds.Light_StopCue'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_01
        BoneName="b_Wheel_R_01"
        SkelControlName="Wheel_R_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=R_Wheel_01

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_02
        BoneName="b_Wheel_R_02"
        SkelControlName="Wheel_R_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=R_Wheel_02

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_03
        BoneName="b_Wheel_R_03"
        SkelControlName="Wheel_R_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=R_Wheel_03
	
	Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_04
        BoneName="b_Wheel_R_04"
        SkelControlName="Wheel_R_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=R_Wheel_04

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_05
        BoneName="b_Wheel_R_05"
        SkelControlName="Wheel_R_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=R_Wheel_05

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_06
        BoneName="b_Wheel_R_06"
        SkelControlName="Wheel_R_06_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=R_Wheel_06
	
	Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_07
        BoneName="b_Wheel_R_06"
        SkelControlName="Wheel_R_06_Cont"
        Side=SIDE_Right
    End Object
    Wheels(6)=R_Wheel_07

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=R_Wheel_08
        BoneName="b_Wheel_R_07"
        SkelControlName="Wheel_R_07_Cont"
        Side=SIDE_Right
    End Object
    Wheels(7)=R_Wheel_08
	
	
	
	Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_01
        BoneName="b_Wheel_L_01"
        SkelControlName="Wheel_L_01_Cont"
        Side=SIDE_Left
    End Object
    Wheels(8)=L_Wheel_01

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_02
        BoneName="b_Wheel_L_02"
        SkelControlName="Wheel_L_02_Cont"
        Side=SIDE_Left
    End Object
    Wheels(9)=L_Wheel_02

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_03
        BoneName="b_Wheel_L_03"
        SkelControlName="Wheel_L_03_Cont"
        Side=SIDE_Left
    End Object
    Wheels(10)=L_Wheel_03
	
	Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_04
        BoneName="b_Wheel_L_04"
        SkelControlName="Wheel_L_04_Cont"
        Side=SIDE_Left
    End Object
    Wheels(11)=L_Wheel_04

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_05
        BoneName="b_Wheel_L_05"
        SkelControlName="Wheel_L_05_Cont"
        Side=SIDE_Left
    End Object
    Wheels(12)=L_Wheel_05

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_06
        BoneName="b_Wheel_L_06"
        SkelControlName="Wheel_L_06_Cont"
        Side=SIDE_Left
    End Object
    Wheels(13)=L_Wheel_06
	
	Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_07
        BoneName="b_Wheel_L_06"
        SkelControlName="Wheel_L_06_Cont"
        Side=SIDE_Left
    End Object
    Wheels(14)=L_Wheel_07

    Begin Object class=Rx_Vehicle_M2Bradley_Wheel Name=L_Wheel_08
        BoneName="b_Wheel_L_07"
        SkelControlName="Wheel_L_07_Cont"
        Side=SIDE_Left
    End Object
    Wheels(15)=L_Wheel_08

}
