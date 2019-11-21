/*********************************************************
*
* File: RxDefence_GunEmplacement.uc
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
class Rx_Defence_GunEmplacement extends Rx_Defence_Emplacement
	placeable;
	
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;
var	repnotify bool bPlayingAmbientFireSound; 

var GameSkelCtrl_Recoil    Recoil_R1, Recoil_R2, Recoil_Gattling;

var int missleBayToggle;

replication{
	if(bNetDirty && !bNetOwner)
		bPlayingAmbientFireSound; 
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bPlayingAmbientFireSound')
	{
		if(bPlayingAmbientFireSound)
			FiringAmbient.Play();
		else
		{
			PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
			FiringAmbient.Stop();
		}
			
	}
	else
		super.ReplicatedEvent(VarName); 
}


/** added recoil */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh && Mesh != none)
		Recoil_Gattling = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Gattling') );
		
		Recoil_R1 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_R1') );
		Recoil_R2 = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_R2') );
}

/**
 * An interface for causing various events on the vehicle.
 * also recoil is called here
 */
simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (RecoilTriggerTag == EventTag && Recoil != none)
		Recoil.bPlayRecoil = true;
}


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

    if(missleBayToggle == 1)
        missleBayToggle = 1;

    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}

simulated function int GetBarrelIndex(int SeatIndex)
{
    local int OldBarrelIndex;
    
    OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
    if (Weapon == none)
        return OldBarrelIndex;

    return (Weapon.CurrentFireMode == 0 ? 0 : missleBayToggle);
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    local Name FireTriggerTag;
	
	Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);
	
	//VehicleEvent('GattlingGun');

	FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   if(Weapon != None) {
	   
       if (Weapon.CurrentFireMode == 0)
       {
		  
		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
		}
		   
          switch(FireTriggerTag)
          {
          case 'GattlingGun':
             Recoil_Gattling.bPlayRecoil = TRUE;
             break;
          }
       }
       else
       {
          switch(FireTriggerTag)
          {
          case 'FireR1':
             Recoil_R1.bPlayRecoil = TRUE;
             break;
    
          case 'FireR2':
             Recoil_R2.bPlayRecoil = TRUE;
             break;    
          }
       }
   }
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
    if(SeatIndex == 0) {
        super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
	}
	
	if(ROLE == ROLE_Authority && Weapon.CurrentFireMode == 0)
	{
		bPlayingAmbientFireSound = true; 
	}
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	//`log("Stopped firing"); 
    if(SeatIndex == 0) {
        super.VehicleWeaponStoppedFiring(bViaReplication,SeatIndex);
    }
    
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
            VehicleEvent('STOP_GattlingGun');
        }
    }
	
	
	if (Weapon != none && Weapon.CurrentFireMode == 0)
	{
		PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
		FiringAmbient.Stop();
	}
	
	if(ROLE == ROLE_Authority &&  Weapon.CurrentFireMode == 0)
	{
		bPlayingAmbientFireSound = false; 
	}
}


	
defaultproperties
{
    MaxDesireability = 1.0
	
	missleBayToggle = 1;

	Health=400
	bLightArmor=true

	RespawnTime=90.0
	
	GroundSpeed=0
	AirSpeed=0
	MaxSpeed=0
	
	COMOffset=(x=0.0,y=0.0,z=0.0)
	
	AIPurpose=AIP_Defensive
	bTurnInPlace=True
	bFollowLookDir=True
	Physics=PHYS_None
    bIgnoreEncroachers=True
    bHardAttach=True
    bCollideWorld=False
	// bSeperatePawn = True
	bAttachDriver=true
	bDriverIsVisible=true
	
    bRotateCameraUnderVehicle=false
    CameraLag=0.2
    LookForwardDist=0.0
	DefaultFOV=55



//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'RX_DEF_GunEmplacement.Mesh.SK_DEF_GunEmplacement'
		AnimTreeTemplate=AnimTree'RX_DEF_GunEmplacement.Anims.AT_DEF_GunEmplacement'
		PhysicsAsset=PhysicsAsset'RX_DEF_GunEmplacement.Mesh.SK_DEF_GunEmplacement_Physics'
		Translation=(X=0.0,Y=0.0,Z=-12.0)
	End Object

	DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_DEF_GunEmplacement.UI.T_VehicleIcon_GunEmplacement'
	MinimapIconTexture=Texture2D'RX_DEF_GunEmplacement.UI.T_MinimapIcon_GunEmplacement'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


	Seats(0)={( GunClass=class'Rx_Defence_GunEmplacement_Weapon',
				GunSocket=("FireL","FireR1","FireR2"),
                TurretControls=(TurretPitch,TurretRotate),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=0,Z=0),
                CameraOffset=-300,
                bSeatVisible=true,
                SeatBone=b_Driver,
                SeatSocket=DriverSocket,
                SeatOffset=(X=-10,Y=0,Z=10),
                SeatRotation=(Pitch=0,Yaw=0),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				)}
	
	DrivingAnim=H_M_Seat_Apache


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


	BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'
	BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'

	DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium_Driving'
	DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium'

	RecoilTriggerTag = "GattlingGun","FireR1","FireR2"
	VehicleEffects(0)=(EffectStartTag="FireR1",EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_Single',EffectSocket="FireR1")
	VehicleEffects(1)=(EffectStartTag="FireR2",EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_Single',EffectSocket="FireR2")
	VehicleEffects(2)=(EffectStartTag="GattlingGun",EffectEndTag="STOP_GattlingGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="FireL")
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death
	
//========================================================\\
// *************** Vehicle Audio Properties ************* \\
//========================================================\\

    Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
	
	FiringStopSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Stop'
	bTeamLocked = true
}