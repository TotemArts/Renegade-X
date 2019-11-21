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
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairTool_Back'
		Scale=1.0
	End Object
	
	PlayerViewOffset=(X=16.0,Y=3.0,Z=-4.0)
	
	LeftHandIK_Offset=(X=-3.511200,Y=-4.500000,Z=0.230000)
	LeftHandIK_Rotation=(Pitch=-3094,Yaw=0,Roll=2366)
	LeftHandIK_Relaxed_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Offset=(X=2,Y=-2,Z=-5)
	RightHandIK_Relaxed_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Relaxed_Rotation=(Pitch=0,Yaw=0,Roll=0)
	
	bUseHandIKWhenRelax=false	
	bOverrideLeftHandAnim=true
	LeftHandAnim=H_M_Hands_Closed

	AttachmentClass = class'Rx_Attachment_RepairTool'

	WeaponRange=500 //350.0
	
	ShotCost(0)=1
	ClipSize = 350//250//350//400
	FireInterval(0)=+0.3
	FireInterval(1)=+0.3
	

	HealAmount = 18 //15
	MinHealAmount = 1
	MineDamageModifier  = 1.75 //1.5
	RechargeTime = 5.0f
	RechargeRate = 1.0f
	
	StartAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire_Start'
	EndAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire_Stop'
	WeaponFireSnd[0]=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairTool_Fire'
	WeaponFireSnd[1]=None
	
	InventoryGroup=6
	InventoryMovieGroup=37

	WeaponIconTexture=Texture2D'RX_WP_RepairGun.UI.T_WeaponIcon_RepairTool'
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairTool'

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

	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.11111 //17
	Vet_DamageModifier(2)=1.22222 //1.1.2667 //19
	Vet_DamageModifier(3)=1.33333 //1.4 //21
	
	/**********************/
	
	bUseClientAmmo = false ;

	Price = 200
}
