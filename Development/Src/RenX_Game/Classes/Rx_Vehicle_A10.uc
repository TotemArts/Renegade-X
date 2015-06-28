/*********************************************************
*
* File: Rx_Vehicle_A10.uc
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
class Rx_Vehicle_A10 extends Rx_Vehicle_Air_Jet
    placeable;

	
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;
	
var int missleBayToggle;

//================================================
// COPIED from RxVehicle_MammothTank
// Attribute of a multi weapon vehicle, this code correctly identifies 
// the propper firing socket
//================================================
simulated function vector GetEffectLocation(int SeatIndex)
{
    local vector SocketLocation;
    local name FireTriggerTag;

    if ( Seats[SeatIndex].GunSocket.Length <= 0 )
        return Location;

    //toggle missle bays
    if(missleBayToggle == 1)
        missleBayToggle = 2;
    else
        missleBayToggle = 1;

    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}

//Modified from the mammoth source to use missleBayToggle
//which switches between the 2 available missle bays
simulated function int GetBarrelIndex(int SeatIndex)
{
    local int OldBarrelIndex;
    
    OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
    if (Weapon == none)
        return OldBarrelIndex;

    return (Weapon.CurrentFireMode == 0 ? 0 : missleBayToggle);
}


//================================================
// COPIED from RxVehicle_Apache
// Using looping + end sounds for firing
//================================================

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    if (Weapon.CurrentFireMode == 0)
	{
		VehicleEvent('GattlingGunFire');

		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
		}
	}
	else if (Weapon.CurrentFireMode == 1)
	{
		if (GetBarrelIndex(SeatIndex) == 2)
		{
			VehicleEvent('MissileFireLeft');
		}
		else if (GetBarrelIndex(SeatIndex) == 1)
		{
			VehicleEvent('MissileFireRight');
		}

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
            VehicleEvent('STOP_GunFire');
        }
    }

    if (Weapon.CurrentFireMode == 0)
	{
		PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
	}
	
    FiringAmbient.Stop();
}

    

DefaultProperties
{

    missleBayToggle = 1;

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\



    BaseEyeheight=0 //30
    Eyeheight=0 //30
    PushForce=50000.0
    LookForwardDist=0 //500.0
    bRotateCameraUnderVehicle=true
    bLimitCameraZLookingUp=false
    bStayUpright=true //false
    UprightLiftStrength=30 //30.0
    UprightTorqueStrength=30 //30.0
    StayUprightRollResistAngle=5 //0 //5.0
    StayUprightPitchResistAngle=5 //5.0
    StayUprightStiffness=600 //1200
    StayUprightDamping=20 //20
    CollisionDamageMult=0.005

    Health=600
    bLightArmor=true
    MomentumMult=0.7
    bCanFlip=true
    bSeparateTurretFocus=false //true
    CameraLag=0.1 //0.05
    AirSpeed=3000.0
    MaxSpeed=2000
    HornIndex=1
    COMOffset=(x=-50.0,y=0.0,z=0.0)
    bUsesBullets = true
    
	MaxDesireability = 0 // todo: reactivate when flying AI is fixed    
    
    Begin Object Name=SimObject
        MaxThrustForce=1600.0
        MaxReverseForce=0.0
        LongDamping=0.1
        MaxStrafeForce=0.0
        LatDamping=0.7
        MaxRiseForce=1000.0
        UpDamping=0.0
        TurnTorqueFactor=5000.0
        TurnTorqueMax=10000.0
        TurnDamping=1.0 //1.2
        MaxYawRate=1.5
        PitchTorqueFactor=0 //-1000.0
        PitchTorqueMax=0 //2000.0
        PitchDamping=3.0
        RollTorqueTurnFactor=3000 //6000.0
        RollTorqueStrafeFactor=3000 //2000.0
        RollTorqueMax=1300 //6000.0
        RollDamping=0.5 //1.2
        MaxRandForce=0.0
        RandForceInterval=1.5
        StopThreshold=100
        bShouldCutThrustMaxOnImpact=false
    End Object
    SimObj=SimObject
    Components.Add(SimObject)

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object Name=CollisionCylinder
      CollisionHeight=200.0
      CollisionRadius=340.0
      Translation=(X=0.0,Y=0.0,Z=0.0)
      End Object
    CylinderComponent=CollisionCylinder
    
    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_A-10.Mesh.SK_VH_A-10_Gameplay'
        AnimTreeTemplate=AnimTree'RX_VH_A-10.Anim.AT_VH_A-10_Gameplay'
        PhysicsAsset=PhysicsAsset'RX_VH_A-10.Mesh.SK_VH_A-10_Gameplay_Physics'
    End Object

    DrawScale=1.0


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_A10_Weapon',
                GunSocket=("GattlingGunSocket","Missile_Left_Socket","Missile_Right_Socket"),
                TurretControls=(GattlingTurret,MissileLeft,MissileRight),
                GunPivotPoints=(GattlingGun,Missile_L,Missile_R),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=0,Z=70),
                CameraOffset=-800,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_A-10.Materials.MI_A-10_BO'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_A-10.Materials.MI_A-10_BO'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_A-10.Materials.PhysMat_A-10_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_A-10.Materials.PhysMat_A-10'

    RecoilTriggerTag = "GattlingGunFire"
	VehicleEffects(0)=(EffectStartTag="GattlingGunFire",EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_MuzzleFlash_Gun',EffectSocket="GattlingGunSocket")
    VehicleEffects(1)=(EffectStartTag="MissileFireLeft",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Left_Socket")
    VehicleEffects(2)=(EffectStartTag="MissileFireRight",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Right_Socket")
    
    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet',EffectSocket=Jet_L)
    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet',EffectSocket=Jet_R)
    VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip',EffectSocket=WingTip_L)
    VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip',EffectSocket=WingTip_R)
    
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=DamageSmoke01)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=DamageSmoke02)
    VehicleEffects(9)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_A-10.Effects.P_EngineFire',EffectSocket=DamageSmoke03)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_A-10.Sounds.SC_A-10_Engine'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    // Scrape sound.
    Begin Object Class=AudioComponent Name=BaseScrapeSound
        SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
    End Object
    ScrapeSound=BaseScrapeSound
    Components.Add(BaseScrapeSound);

    ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'
    CollisionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Collision'
	
    EnterVehicleSound=SoundCue'RX_VH_A-10.Sounds.SC_A-10_Engine_Start'
    ExitVehicleSound=SoundCue'RX_VH_A-10.Sounds.SC_A-10_Engine_Stop'

    EngineStartOffsetSecs=3.4
    EngineStopOffsetSecs=2.47
	
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_A-10.Sounds.SC_A-10_Gun_Looping'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_A-10.Sounds.SC_A-10_Gun_End'

	VehicleIconTexture=Texture2D'RX_VH_A-10.UI.T_VehicleIcon_A10'
	MinimapIconTexture=Texture2D'RX_VH_A-10.UI.T_MinimapIcon_A10'
}