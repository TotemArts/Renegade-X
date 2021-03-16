/*********************************************************
*
* File: RA2_Vehicle_ApocalypseTank.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class RA2_Vehicle_ApocalypseTank extends Rx_Vehicle_Treaded
    placeable;

    
var GameSkelCtrl_Recoil    Recoil_R, Recoil_L, Recoil_MPL_01, Recoil_MPL_02, Recoil_MPL_03, Recoil_MPL_04, Recoil_MPL_05, Recoil_MPL_06, Recoil_MPR_01, Recoil_MPR_02, Recoil_MPR_03, Recoil_MPR_04, Recoil_MPR_05, Recoil_MPR_06;
var protected byte ShotCounts, AltShotCounts;
var class<UTDamageType>	RammingDamageType; 
var int MinRammingSpeed; 


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

    


function init_() {
    SetTimer(0.5f, true, 'regenerateHealth'); 
}
 
//Is it really OP to regenerate 2 health per second back to full?? I.. don't think so, at all. 
function regenerateHealth()
{
	if(bTakingDamage) return; 
    //if(Health  < HealthMax/2) {
    if(Health  < HealthMax) {    
		Health += RegenerationRate+(VRank*0.5);
    }
	if(Health > HealthMax) Health=HealthMax; 
}
    
simulated function SetHeroicMuzzleFlash(bool SetTrue)
 {
	 local int i; 
	 
	 for(i=0;i<VehicleEffects.Length;i++)
	 {
		 if((VehicleEffects[i].EffectStartTag=='PrimaryFire_Right' || VehicleEffects[i].EffectStartTag=='PrimaryFire_Left') && VehicleEffects[i].EffectRef != none) 
		 {
			 if(SetTrue) VehicleEffects[i].EffectRef.SetTemplate(Heroic_MuzzleFlash);
			 else
			VehicleEffects[i].EffectRef.SetTemplate(default.VehicleEffects[i].EffectTemplate);
			//break;
		 }
	 }
 }


 //Damage vehicles infront of you (Mostly fron Raninto() )
simulated function TryBladeHit( Actor Other )
{
	local float Speed;
	local Vector Momentum;
	local class<UDKEmitCameraEffect> CameraEffect;
	local bool bEnemyIsInfrontOfMe;		
	
	if( Pawn(Other) == none || Other == Instigator || Other.Role != ROLE_Authority || WorldInfo.GRI.OnSameTeam(self, Other) )
		return;
	
	
	
	Speed = VSize(Velocity);

	if (Speed > MinRammingSpeed)
	{
		bEnemyIsInfrontOfMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,rotation,Other.location) > 220;
 
		if(!bEnemyIsInfrontOfMe)
		{
			return; 
		}
		
		Momentum = Velocity * 0.25 * Pawn(Other).Mass;
		if ( RanOverSound != None )
			PlaySound(RanOverSound);

		Other.TakeDamage(Speed, GetCollisionDamageInstigator(), Other.Location, Momentum, RammingDamageType);

		if (Pawn(Other).Health <= 0 && UTPlayerController(Controller) != none)
		{
			CameraEffect = RammingDamageType.static.GetDeathCameraEffectInstigator(UTPawn(Other));
			if (CameraEffect != None)
			{
				UTPlayerController(Controller).ClientSpawnCameraEffect(CameraEffect);
			}
		}
	}
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
							   const out CollisionImpactData Collision, int ContactIndex ) {
	local float HisOrientationToMe;
	local float MyOrientationToHim;

	if(UTVehicle(HitComponent.Owner) != None )
		TryBladeHit(OtherComponent.Owner);  

	/*Super call to from Rx_Vehicle*/
	if(OtherComponent == None || VSize(Velocity - OtherComponent.Owner.Velocity) > 250) {
		super(UTVehicle).RigidBodyCollision(HitComponent,OtherComponent,Collision,ContactIndex);
	}


	if(bStationary == false && Rx_Vehicle_Harvester(HitComponent.owner) == None && UTVehicle(HitComponent.owner) != None 
	&& OtherComponent != None 
	&& UTVehicle(OtherComponent.owner) != None 
	&& (Rx_Bot(Controller) != None || (Rx_VehRolloutController(Controller) != None && AIController(UTVehicle(OtherComponent.owner).Controller) != None)) )
	{
		HisOrientationToMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,Rotation,OtherComponent.owner.location);
		MyOrientationToHim = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(OtherComponent.owner.location,OtherComponent.owner.rotation,location);
		
		if(HisOrientationToMe > 0.2)
		{ // meaning hes in front of me
			if(HisOrientationToMe > MyOrientationToHim)
			{ // meaning hes more in front of me then im in front of him -> so i wait
				if(UTBot(Controller) != None)
				{
					UTBot(Controller).MoveTarget = None;
					Rx_Bot(Controller).setShouldWait(UTVehicle(Controller.Pawn));
				} 
				else
				{
					Rx_VehRolloutController(Controller).setShouldWait(UTVehicle(Controller.Pawn));
				}
				UTVehicle(Controller.Pawn).bStationary = true;	
			}	
		}
	}	
}


DefaultProperties
{



//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=1500
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.2 //0.55
	LookForwardDist=400
    GroundSpeed=400
    MaxSpeed=6000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=-50.0,y=0.0,z=20.0)
	bRotateCameraUnderVehicle=true
	bAlwaysRegenerate = true
	
	RegenerationRate = 2 
	
	BarrelLength(0)=450
	BarrelLength(1)=30
	BarrelLength(2)=30
	BarrelLength(3)=30
	BarrelLength(4)=30
	BarrelLength(5)=30

	MinRammingSpeed	= 100 
	RammingDamageType = class'RA2_DmgType_ApocalypseTank_Ram' 
	
	/************************/
	/*Veterancy Multipliers*/
	/***********************/

	//VP Given on death (by VRank)
		VPReward(0) = 12 
		VPReward(1) = 15 
		VPReward(2) = 20 
		VPReward(3) = 30 
		
		VPCost(0) = 50
		VPCost(1) = 110
		VPCost(2) = 220

	Vet_HealthMod(0)=1 //1200
	Vet_HealthMod(1)=1.125 //1350
	Vet_HealthMod(2)=1.25 //1500
	Vet_HealthMod(3)=1.4583333334 //1750
		
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1
	Vet_SprintSpeedMod(2)=1
	Vet_SprintSpeedMod(3)=1
		
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)=0.0
	Vet_SprintTTFD(2)=0.0
	Vet_SprintTTFD(3)=0.0

	/**********************/

	Heroic_MuzzleFlash=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash_Heroic'
	
    Begin Object Class=SVehicleSimTank Name=SimObject

	
        bClampedFrictionModel=true

        WheelSuspensionStiffness=100
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
        MaxEngineTorque=3075//3875
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RA2_VH_ApocalypseTank.Meshes.RA2_VH_ApocalypseTank'
        AnimTreeTemplate=AnimTree'RA2_VH_ApocalypseTank.Animations.AT_VH_ApocalypseTank'
        PhysicsAsset=PhysicsAsset'RA2_VH_ApocalypseTank.Meshes.RA2_VH_ApocalypseTank_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RA2_VH_ApocalypseTank.Meshes.RA2_VH_ApocalypseTank'

	VehicleIconTexture=Texture2D'RA2_VH_ApocalypseTank.Textures.T_VehicleIcon_ApocalypseTank'
	MinimapIconTexture=Texture2D'RA2_VH_ApocalypseTank.Textures.T_Minimapicon_ApocalypseTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

    Begin Object Name=CollisionCylinder
      //CollisionHeight=380.0
      CollisionRadius=208.0
      Translation=(X=0.0,Y=0.0,Z=0.0)
      End Object
    CylinderComponent=CollisionCylinder
    
    Seats(0)={(GunClass=class'RA2_Vehicle_ApocalypseTank_Weapon',
                GunSocket=("FireSocket_Left", "Firesocket_Right", "MFR_01", "MFL_01", "MFR_02", "MFL_02", "MFR_03", "MFL_03", "MFR_04", "MFL_04", "MFR_05", "MFL_05", "MFR_06", "MFL_06"),//("FireSocket_Left", "Firesocket_Right"),
                TurretControls=(TurretPitch,TurretRotate),
				TurretVarPrefix="",
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=20),
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraOffset=-650,
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


    LeftTeadIndex     = 0
    RightTreadIndex   = 1

    DrivingPhysicalMaterial=PhysicalMaterial'RA2_VH_ApocalypseTank.Materials.PhysMat_ApocalypseTank_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RA2_VH_ApocalypseTank.Materials.PhysMat_ApocalypseTank'

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

	VehicleEffects(22)=(EffectStartTag="EngineStart",EffectEndTag="EngineStop",bRestartRunning=False,EffectTemplate=ParticleSystem'RA2_VH_ApocalypseTank.Particles.P_ApocalypseTank_Exhaust',EffectSocket="Heateffect_mid")
	VehicleEffects(23)=(EffectStartTag="EngineStart",EffectEndTag="EngineStop",bRestartRunning=False,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffect_right1")
	VehicleEffects(24)=(EffectStartTag="EngineStart",EffectEndTag="EngineStop",bRestartRunning=False,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffect_right2")
	VehicleEffects(25)=(EffectStartTag="EngineStart",EffectEndTag="EngineStop",bRestartRunning=False,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffect_left1")
	VehicleEffects(26)=(EffectStartTag="EngineStart",EffectEndTag="EngineStop",bRestartRunning=False,EffectTemplate=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Exhaust',EffectSocket="ExhaustEffect_left2")

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

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RA2_VH_ApocalypseTank.Sounds.ApocalypseTank_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RA2_VH_ApocalypseTank.Sounds.ApocalypseTank_startCue'
    ExitVehicleSound=SoundCue'RA2_VH_ApocalypseTank.Sounds.ApocalypseTank_StopCue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_01
        BoneName="Wheel_RB1_01"
        SkelControlName="Wheel_RB1_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=Wheel_RB1_01

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_02
        BoneName="Wheel_RB1_02"
        SkelControlName="Wheel_RB1_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=Wheel_RB1_02

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_03
        BoneName="Wheel_RB1_03"
        SkelControlName="Wheel_RB1_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(2)=Wheel_RB1_03

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_04
        BoneName="Wheel_RB1_04"
        SkelControlName="Wheel_RB1_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(3)=Wheel_RB1_04

    
    
    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_05
        BoneName="Wheel_RB1_05"
        SkelControlName="Wheel_RB1_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=Wheel_RB1_05

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_06
        BoneName="Wheel_RB1_06"
        SkelControlName="Wheel_RB1_06_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=Wheel_RB1_06

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_07
        BoneName="Wheel_RB1_07"
        SkelControlName="Wheel_RB1_07_Cont"
        Side=SIDE_Right
    End Object
    Wheels(6)=Wheel_RB1_07

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_08
        BoneName="Wheel_RB1_08"
        SkelControlName="Wheel_RB1_08_Cont"
        Side=SIDE_Right
    End Object
    Wheels(7)=Wheel_RB1_08

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_09
        BoneName="Wheel_RB1_09"
        SkelControlName="Wheel_RB1_09_Cont"
        Side=SIDE_Right
    End Object
    Wheels(8)=Wheel_RB1_09

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_10
        BoneName="Wheel_RB1_10"
        SkelControlName="Wheel_RB1_10_Cont"
        Side=SIDE_Right
    End Object
    Wheels(9)=Wheel_RB1_10

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB1_11
        BoneName="Wheel_RB1_11"
        SkelControlName="Wheel_RB1_11_Cont"
        Side=SIDE_Right
    End Object
    Wheels(10)=Wheel_RB1_11

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB2_01
        BoneName="Wheel_RB2_01"
        SkelControlName="Wheel_RB2_01_Cont"
        Side=SIDE_Right
    End Object
    Wheels(11)=Wheel_RB2_01

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB2_02
        BoneName="Wheel_RB2_02"
        SkelControlName="Wheel_RB2_02_Cont"
        Side=SIDE_Right
    End Object
    Wheels(12)=Wheel_RB2_02

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB2_03
        BoneName="Wheel_RB2_03"
        SkelControlName="Wheel_RB2_03_Cont"
        Side=SIDE_Right
    End Object
    Wheels(13)=Wheel_RB2_03

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB2_04
        BoneName="Wheel_RB2_04"
        SkelControlName="Wheel_RB2_04_Cont"
        Side=SIDE_Right
    End Object
    Wheels(14)=Wheel_RB2_04

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RB2_05
        BoneName="Wheel_RB2_05"
        SkelControlName="Wheel_RB2_05_Cont"
        Side=SIDE_Right
    End Object
    Wheels(15)=Wheel_RB2_05
	
    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RT1_Front
        BoneName="Wheel_RT1_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(16)=Wheel_RT1_Front

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RT1_Rear
        BoneName="Wheel_RT1_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(17)=Wheel_RT1_Rear

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RT2_Front
        BoneName="Wheel_RT2_Front"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(18)=Wheel_RT2_Front

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_RT2_Rear
        BoneName="Wheel_RT2_Rear"
        SkelControlName="Wheel_RT_Cont"
        Side=SIDE_Right
    End Object
    Wheels(19)=Wheel_RT2_Rear
	
	
	

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_01
        BoneName="Wheel_LB1_01"
        SkelControlName="Wheel_LB1_01_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(20)=Wheel_LB1_01

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_02
        BoneName="Wheel_LB1_02"
        SkelControlName="Wheel_LB1_02_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(21)=Wheel_LB1_02

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_03
        BoneName="Wheel_LB1_03"
        SkelControlName="Wheel_LB1_03_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(22)=Wheel_LB1_03

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_04
        BoneName="Wheel_LB1_04"
        SkelControlName="Wheel_LB1_04_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(23)=Wheel_LB1_04

    
    
    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_05
        BoneName="Wheel_LB1_05"
        SkelControlName="Wheel_LB1_05_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(24)=Wheel_LB1_05

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_06
        BoneName="Wheel_LB1_06"
        SkelControlName="Wheel_LB1_06_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(25)=Wheel_LB1_06

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_07
        BoneName="Wheel_LB1_07"
        SkelControlName="Wheel_LB1_07_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(26)=Wheel_LB1_07

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_08
        BoneName="Wheel_LB1_08"
        SkelControlName="Wheel_LB1_08_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(27)=Wheel_LB1_08

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_09
        BoneName="Wheel_LB1_09"
        SkelControlName="Wheel_LB1_09_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(28)=Wheel_LB1_09

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_10
        BoneName="Wheel_LB1_10"
        SkelControlName="Wheel_LB1_10_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(29)=Wheel_LB1_10

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB1_11
        BoneName="Wheel_LB1_11"
        SkelControlName="Wheel_LB1_11_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(30)=Wheel_LB1_11

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB2_01
        BoneName="Wheel_LB2_01"
        SkelControlName="Wheel_LB2_01_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(31)=Wheel_LB2_01

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB2_02
        BoneName="Wheel_LB2_02"
        SkelControlName="Wheel_LB2_02_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(32)=Wheel_LB2_02

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB2_03
        BoneName="Wheel_LB2_03"
        SkelControlName="Wheel_LB2_03_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(33)=Wheel_LB2_03

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB2_04
        BoneName="Wheel_LB2_04"
        SkelControlName="Wheel_LB2_04_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(34)=Wheel_LB2_04

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LB2_05
        BoneName="Wheel_LB2_05"
        SkelControlName="Wheel_LB2_05_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(35)=Wheel_LB2_05
	
    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LT1_Front
        BoneName="Wheel_LT1_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(36)=Wheel_LT1_Front

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LT1_Rear
        BoneName="Wheel_LT1_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(37)=Wheel_LT1_Rear

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LT2_Front
        BoneName="Wheel_LT2_Front"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(38)=Wheel_LT2_Front

    Begin Object Class=RA2_Vehicle_ApocalypseTank_Wheel Name=Wheel_LT2_Rear
        BoneName="Wheel_LT2_Rear"
        SkelControlName="Wheel_LT_Cont"
        Side=SIDE_LEFT
    End Object
    Wheels(39)=Wheel_LT2_Rear
	

    
	
	
	
	
	
	
	
	
    

}
