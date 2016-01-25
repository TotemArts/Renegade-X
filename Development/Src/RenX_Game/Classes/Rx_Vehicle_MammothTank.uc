
class Rx_Vehicle_MammothTank extends Rx_Vehicle_Treaded
    placeable;

    
var GameSkelCtrl_Recoil    Recoil_R, Recoil_L, Recoil_MPL_01, Recoil_MPL_02, Recoil_MPL_03, Recoil_MPL_04, Recoil_MPL_05, Recoil_MPL_06, Recoil_MPR_01, Recoil_MPR_02, Recoil_MPR_03, Recoil_MPR_04, Recoil_MPR_05, Recoil_MPR_06;
var protected byte ShotCounts, AltShotCounts;


var SkeletalMeshComponent AntennaMeshL;
var SkeletalMeshComponent AntennaMeshR;
var SkeletalMeshComponent TowRopeMesh;
var SkeletalMeshComponent TowRopeMeshL;
var SkeletalMeshComponent TowRopeMeshR;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
	return Velocity;
}


simulated function vector GetEffectLocation(int SeatIndex)
{

    local vector SocketLocation;
   local name FireTriggerTag;

    if ( Seats[SeatIndex].GunSocket.Length <= 0 )
        return Location;

   //`Log("GetEffectLocation called",, '_Mammoth_Debug');

   FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    //if (Weapon.CurrentFireMode == 0)
    //   ShotCount = ShotCounts >= 255 ? 0 : ShotCounts + 1;
   //  else
   //     AltShotCounts = AltShotCounts >= 255 ? 0 : AltShotCounts + 1;
    return SocketLocation;
}

// special for mammoth
simulated event GetBarrelLocationAndRotation(int SeatIndex, out vector SocketLocation, optional out rotator SocketRotation)
{
   //`Log("GetBarrelLocationAndRotation called",, '_Mammoth_Debug');
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
   //`Log("GetBarrelIndex called",, '_Mammoth_Debug');
   OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
   if (Weapon == none)
      return OldBarrelIndex;

   return (Weapon.CurrentFireMode == 0 ? OldBarrelIndex % 2 : (OldBarrelIndex % 12) + 2);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    Super.PostInitAnimTree(SkelComp);



    if (SkelComp == Mesh)
    {
        Recoil_R = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Right') );
        Recoil_L = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Left') );

        Recoil_MPR_01 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_01') );
        Recoil_MPR_02 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_02') );
        Recoil_MPR_03 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_03') );
        Recoil_MPR_04 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_04') );
        Recoil_MPR_05 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_05') );
        Recoil_MPR_06 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_MR_06') );
        Recoil_MPL_01 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_01') );
        Recoil_MPL_02 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_02') );
        Recoil_MPL_03 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_03') );
        Recoil_MPL_04 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_04') );
        Recoil_MPL_05 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_05') );
        Recoil_MPL_06 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_ML_06') );
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
          case 'FireSocket_Right':
             Recoil_L.bPlayRecoil = TRUE;
             break;
    
          case 'Firesocket_Left':
             Recoil_R.bPlayRecoil = TRUE;
             break;
          }
       }
       else
       {
          switch(FireTriggerTag)
          {
          case 'MFR_01':
             Recoil_MPR_01.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_01':
             Recoil_MPL_01.bPlayRecoil = TRUE;
             break;
    
          case 'MFR_02':
             Recoil_MPR_02.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_02':
             Recoil_MPL_02.bPlayRecoil = TRUE;
             break;
    
          case 'MFR_03':
             Recoil_MPR_03.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_03':
             Recoil_MPL_03.bPlayRecoil = TRUE;
             break;
    
          case 'MFR_04':
             Recoil_MPR_04.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_04':
             Recoil_MPL_04.bPlayRecoil = TRUE;
             break;
    
          case 'MFR_05':
             Recoil_MPR_05.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_05':
             Recoil_MPL_05.bPlayRecoil = TRUE;
             break;
    
          case 'MFR_06':
             Recoil_MPR_06.bPlayRecoil = TRUE;
             break;
    
          case 'MFL_07':
             Recoil_MPL_06.bPlayRecoil = TRUE;
             break;
    
          }
       }
   }
}

    
    
simulated function PostBeginPlay() {

    super.PostBeginPlay();
    init_();
	
	Mesh.AttachComponentToSocket(AntennaMeshL,'AntennaSocket_Left');
	Mesh.AttachComponentToSocket(AntennaMeshR,'AntennaSocket_Right');
	Mesh.AttachComponentToSocket(TowRopeMesh,'TowingRopeSocket');
	Mesh.AttachComponentToSocket(TowRopeMeshL,'TowingRopeSocket_L');
	Mesh.AttachComponentToSocket(TowRopeMeshR,'TowingRopeSocket_R');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshL.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMeshR.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRopeMesh.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRopeMeshL.FindSkelControl('Beam'));
	AntennaBeamControl = UTSkelControl_CantileverBeam(TowRopeMeshR.FindSkelControl('Beam'));


	if(AntennaBeamControl != none)
	{
		AntennaBeamControl.EntireBeamVelocity = GetVelocity;
	}
}

function init_() {
    SetTimer(0.5f, true, 'regenerateHealth'); 
}
 

function regenerateHealth()
{
    if(Health  < HealthMax/2) {
        Health += 1;
    }
}
    


DefaultProperties
{



//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=1200
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.2 //0.55
	LookForwardDist=400
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-40.0)
	bRotateCameraUnderVehicle=true

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=175
        WheelSuspensionDamping=2.0
        WheelSuspensionBias=0.1

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.1
        WheelLongExtremumValue=1.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
        WheelLatExtremumSlip=0.35		// 0.05 	// 0.35     // 20 degrees
        WheelLatExtremumValue=2.0		// 0.9
        WheelLatAsymptoteSlip=1.4     	// 80 degrees
        WheelLatAsymptoteValue=2.0		// 0.9

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=3
        InsideTrackTorqueFactor=0.4
        TurnInPlaceThrottle=0.35
        TurnMaxGripReduction=0.995 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=3875//3750
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_VH_Mammoth'
        AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_VH_MammothTank'
        PhysicsAsset=PhysicsAsset'RX_VH_MammothTank.Mesh.SK_VH_Mammoth_Physics'
        MorphSets[0]=MorphTargetSet'RX_VH_MammothTank.Mesh.MT_VH_MammothTank'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_PTVH_MammothTank'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshL
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_Antenna_Left'
		AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_Antinna_Left'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshL=SAntennaMeshL
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_Antenna_Right'
		AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_Antinna_Right'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMeshR=SAntennaMeshR
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMesh
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_TowingRope'
		AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_TowingRope'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRopeMesh=STowRingMesh
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshL
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_TowingRope_L'
		AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_TowingRope_L'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRopeMeshL=STowRingMeshL
	
	Begin Object Class=SkeletalMeshComponent Name=STowRingMeshR
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_TowingRope_R'
		AnimTreeTemplate=AnimTree'RX_VH_MammothTank.Anims.AT_TowingRope_R'
		LightEnvironment = MyLightEnvironment
	End Object
	TowRopeMeshR=STowRingMeshR

	VehicleIconTexture=Texture2D'RX_VH_MammothTank.UI.T_VehicleIcon_MammothTank'
	MinimapIconTexture=Texture2D'RX_VH_MammothTank.UI.T_MinimapIcon_MammothTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

    Begin Object Name=CollisionCylinder
      //CollisionHeight=380.0
      CollisionRadius=208.0
      Translation=(X=0.0,Y=0.0,Z=0.0)
      End Object
    CylinderComponent=CollisionCylinder
    
    Seats(0)={(GunClass=class'Rx_Vehicle_MammothWeapon',
                GunSocket=("FireSocket_Left", "Firesocket_Right", "MFR_01", "MFL_01", "MFR_02", "MFL_02", "MFR_03", "MFL_03", "MFR_04", "MFL_04", "MFR_05", "MFL_05", "MFR_06", "MFL_06"),//("FireSocket_Left", "Firesocket_Right"),
                TurretControls=(TurretPitch,TurretRotate),
				TurretVarPrefix="",
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=20),
                CameraOffset=-600,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}

	Seats(1)={(GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=20),
                CameraOffset=-600,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    //Seats(1)={( GunClass=none,   
    //            CameraTag=CamView3P,
    //            CameraBaseOffset=(Z=20),
    //            CameraOffset=-600,
    //            )}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 2
    RightTreadIndex   = 1

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MammothTank.Materials.PhysMat_Mammoth_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MammothTank.Materials.PhysMat_Mammoth'

    RecoilTriggerTag = "Recoil_Right", "Recoil_Left"
    VehicleEffects(0)=(EffectStartTag="PrimaryFire_Right",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireSocket_Right")
    VehicleEffects(1)=(EffectStartTag="PrimaryFire_Left",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireSocket_Left")
    
    VehicleEffects(2)=(EffectStartTag="MissileFire01",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_01")
    VehicleEffects(3)=(EffectStartTag="MissileFire02",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_01")
    VehicleEffects(4)=(EffectStartTag="MissileFire03",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_02")
    VehicleEffects(5)=(EffectStartTag="MissileFire04",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_02")
    VehicleEffects(6)=(EffectStartTag="MissileFire05",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_03")
    VehicleEffects(7)=(EffectStartTag="MissileFire06",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_03")
    VehicleEffects(8)=(EffectStartTag="MissileFire07",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_04")
    VehicleEffects(9)=(EffectStartTag="MissileFire08",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_04")
    VehicleEffects(10)=(EffectStartTag="MissileFire09",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_05")
    VehicleEffects(11)=(EffectStartTag="MissileFire10",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_05")
    VehicleEffects(12)=(EffectStartTag="MissileFire11",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFR_06")
    VehicleEffects(13)=(EffectStartTag="MissileFire12",EffectTemplate=ParticleSystem'RX_VH_MammothTank.Effects.MuzzleFlash_Missiles',EffectSocket="MFL_06")


    VehicleEffects(14)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)
    VehicleEffects(15)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke02)
    VehicleEffects(16)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSpark01)
    VehicleEffects(17)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSpark02)
    VehicleEffects(18)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSpark01)
    VehicleEffects(19)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSpark02)
    VehicleEffects(20)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
    VehicleEffects(21)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire02)

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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death

    DamageMorphTargets(0)=(InfluenceBone=MT_Ch_F,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_Ch_FL,MorphNodeName=MorphNodeW_Ch_FL,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(2)=(InfluenceBone=MT_Ch_FR,MorphNodeName=MorphNodeW_Ch_FR,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=MT_Ch_B,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(4)=(InfluenceBone=MT_Ch_BL,MorphNodeName=MorphNodeW_Ch_BL,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(5)=(InfluenceBone=MT_Ch_BR,MorphNodeName=MorphNodeW_Ch_BR,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(6)=(InfluenceBone=MT_TU_BL,MorphNodeName=MorphNodeW_Tu_BL,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=MT_TU_BR,MorphNodeName=MorphNodeW_Tu_BR,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage3))
    DamageMorphTargets(8)=(InfluenceBone=MT_TU_FR,MorphNodeName=MorphNodeW_Tu_FR,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage4))
    DamageMorphTargets(9)=(InfluenceBone=MT_TU_FL,MorphNodeName=MorphNodeW_Tu_FL,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_stopCue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FR_01
        BoneName="FR_Wheel_01"
        SkelControlName="Wheel_FR_Cont_01"
        Side=SIDE_Right
    End Object
    Wheels(0)=Wheel_FR_01

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FR_02
        BoneName="FR_Wheel_02"
        SkelControlName="Wheel_FR_Cont_02"
        Side=SIDE_Right
    End Object
    Wheels(1)=Wheel_FR_02

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FR_03
        BoneName="FR_Wheel_03"
        SkelControlName="Wheel_FR_Cont_03"
        Side=SIDE_Right
    End Object
    Wheels(2)=Wheel_FR_03

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FR_04
        BoneName="FR_Wheel_04"
        SkelControlName="Wheel_FR_Cont_04"
        Side=SIDE_Right
    End Object
    Wheels(3)=Wheel_FR_04

    
    
    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RR_01
        BoneName="RR_Wheel_01"
        SkelControlName="Wheel_RR_Cont_01"
        Side=SIDE_Right
    End Object
    Wheels(4)=Wheel_RR_01

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RR_02
        BoneName="RR_Wheel_02"
        SkelControlName="Wheel_RR_Cont_02"
        Side=SIDE_Right
    End Object
    Wheels(5)=Wheel_RR_02

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RR_03
        BoneName="RR_Wheel_03"
        SkelControlName="Wheel_RR_Cont_03"
        Side=SIDE_Right
    End Object
    Wheels(6)=Wheel_RR_03

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RR_04
        BoneName="RR_Wheel_04"
        SkelControlName="Wheel_RR_Cont_04"
        Side=SIDE_Right
    End Object
    Wheels(7)=Wheel_RR_04

    
    
    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FL_01
        BoneName="FL_Wheel_01"
        SkelControlName="Wheel_FL_Cont_01"
        Side=SIDE_Left
    End Object
    Wheels(8)=Wheel_FL_01

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FL_02
        BoneName="FL_Wheel_02"
        SkelControlName="Wheel_FL_Cont_02"
        Side=SIDE_Left
    End Object
    Wheels(9)=Wheel_FL_02

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FL_03
        BoneName="FL_Wheel_03"
        SkelControlName="Wheel_FL_Cont_03"
        Side=SIDE_Left
    End Object
    Wheels(10)=Wheel_FL_03

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FL_04
        BoneName="FL_Wheel_04"
        SkelControlName="Wheel_FL_Cont_04"
        Side=SIDE_Left
    End Object
    Wheels(11)=Wheel_FL_04
    
    

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RL_01
        BoneName="RL_Wheel_01"
        SkelControlName="Wheel_RL_Cont_01"
        Side=SIDE_Left
    End Object
    Wheels(12)=Wheel_RL_01

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RL_02
        BoneName="RL_Wheel_02"
        SkelControlName="Wheel_RL_Cont_02"
        Side=SIDE_Left
    End Object
    Wheels(13)=Wheel_RL_02

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RL_03
        BoneName="RL_Wheel_03"
        SkelControlName="Wheel_RL_Cont_03"
        Side=SIDE_Left
    End Object
    Wheels(14)=Wheel_RL_03

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RL_04
        BoneName="RL_Wheel_04"
        SkelControlName="Wheel_RL_Cont_04"
        Side=SIDE_Left
    End Object
    Wheels(15)=Wheel_RL_04



    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FR_05
        BoneName="FR_Wheel_05"
        SkelControlName="Wheel_R_Cont"
        Side=SIDE_Right
    End Object
    Wheels(16)=Wheel_FR_05

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RR_05
        BoneName="RR_Wheel_05"
        SkelControlName="Wheel_R_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=Wheel_RR_05

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_FL_05
        BoneName="FL_Wheel_05"
        SkelControlName="Wheel_L_Cont"
        Side=SIDE_Left
    End Object
    Wheels(18)=Wheel_FL_05

    Begin Object Class=Rx_Vehicle_MammothTank_Wheel Name=Wheel_RL_05
        BoneName="RL_Wheel_05"
        SkelControlName="Wheel_L_Cont"
        Side=SIDE_Left
    End Object
    Wheels(19)=Wheel_RL_05
}
