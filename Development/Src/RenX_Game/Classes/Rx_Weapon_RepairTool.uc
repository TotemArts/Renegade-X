class Rx_Weapon_RepairTool extends Rx_Weapon_RepairGun;

var float RechargeRate, RechargeTime;
var bool bRecharging;  

replication 
{
	if(ROLE == ROLE_AUTHORITY && bNetDirty)
		bRecharging; 
}

auto simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		local PlayerController PC;

		if ( Instigator != None )
		{
		  PC = PlayerController(Instigator.Controller);
		  if ( PC != None && LocalPlayer(PC.Player)!= none )
		  {
			  PC.SetFOV(PC.DefaultFOV);
		  }
		}

		//Always recharge when put away. 
		if(!IsTimerActive('SetRechargeTimer') && CurrentAmmoInClip != default.ClipSize)
		{	
			
			SetTimer( RechargeTime , false, 'SetRechargeTimer');
			
		}
		
		Super.BeginState(PreviousStateName);
	}

	
	
	/**
	 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
	 */
	simulated function bool bReadyToFire()
	{
		return false;
	}
}



simulated function PerformRefill()
{} 

simulated function StartFire(byte FireModeNum)
{
	if(bRecharging && AmmoCount <= 0) return;
	
	
	if(IsTimerActive('RechargeTimer')) ClearTimer('RechargeTimer') ; 
	if(IsTimerActive('SetRechargeTimer')) ClearTimer('SetRechargeTimer');
	
	bRecharging = false; 
	
	
	super.StartFire(FireModeNum);
}

simulated function ConsumeRepairAmmo(int ActualHealAmount)
{
	if (ShotCost[0] <= 0)
		return;
	CurrentAmmoInClip = Max(CurrentAmmoInClip-ShotCost[0],0);
	AddAmmo(-ShotCost[0]); //AddAmmo(-ActualHealAmount);
}

simulated function EndFire(Byte FireModeNum)
{
	if(!IsTimerActive('SetRechargeTimer'))
	{
		
			SetTimer(RechargeTime,true,'SetRechargeTimer');
	}	
	super.EndFire(FireModeNum);
}


simulated function WeaponEmpty()
{
	if(AmmoCount <= 0) {
		if(!bRecharging || !IsTimerActive('SetRechargeTimer'))
		{
		SetTimer(RechargeTime,true,'SetRechargeTimer');
		bRecharging = true;
		}
	} 
	
	super.WeaponEmpty();
}

simulated function SetRechargeTimer()
{

	if(!IsTimerActive('RechargeTimer')) SetTimer(RechargeRate/10,true,'RechargeTimer');
	else
	return;
}

simulated function RechargeTimer()
{
	if(CurrentAmmoInClip < default.ClipSize) 
	{
	CurrentAmmoInClip+=RechargeRate;
	AddAmmo(RechargeRate);
	}
	else
	{
	bRecharging = false; 
	if(IsTimerActive('RechargeTimer')) ClearTimer('RechargeTimer') ; 
	CurrentAmmoInClip = default.ClipSize;
	}
}


simulated function int GetReserveAmmo()
{
	return default.ClipSize;
}

simulated function bool ShouldRefire()
{
	if(bKeepFiring)
		return true;
	
	if(IsTimerActive('RechargeTimer'))
	{ 
	ClearTimer('RechargeTimer') ; 
	
	}
	
	if(IsTimerActive('SetRechargeTimer')) ClearTimer('SetRechargeTimer');
	
	return super.ShouldRefire();
}	

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairTool_1P'
		AnimSets(0)=AnimSet'RX_WP_Pistol.Anims.AS_MachinePistol_1P'
		Animations=MeshSequenceA
		Scale=2.5
		FOV=55.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Pistol.Anims.AS_MachinePistol_Arms'

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_Back'
		Scale=1.0
	End Object
	
	PlayerViewOffset=(X=16.0,Y=3.0,Z=-4.0)
	
	LeftHandIK_Offset=(X=1,Y=8,Z=1)
	RightHandIK_Offset=(X=2,Y=-2,Z=-5)

	AttachmentClass = class'Rx_Attachment_RepairTool'

	WeaponRange=350.0
	
	ShotCost(0)=1
	ClipSize = 250//350//400
	FireInterval(0)=+0.3
	FireInterval(1)=+0.3
	

	HealAmount = 15
	MinHealAmount = 1
	MineDamageModifier  = 1.5
	RechargeTime = 5.0f
	RechargeRate = 1.0f
	
	StartAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire_Start'
	EndAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire_Stop'
	WeaponFireSnd[0]=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire'
	WeaponFireSnd[1]=None
	
	InventoryGroup=6
	InventoryMovieGroup=37

	WeaponIconTexture=Texture2D'RX_WP_RepairGun.UI.T_WeaponIcon_RepairTool'

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_1P_Small'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_RepairBeam'
	
	BeamTemplate[0]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam_Small'
	BeamSockets[0]=MuzzleFlashSocket    
	BeamTemplate[1]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam_Small'
	BeamSockets[1]=MuzzleFlashSocket    

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RepairTool'

}
