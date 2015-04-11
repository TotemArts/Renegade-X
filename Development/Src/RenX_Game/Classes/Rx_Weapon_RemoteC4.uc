class Rx_Weapon_RemoteC4 extends Rx_Weapon_Deployable;

/** List of deployed actors for detonation purposes */
var array<Rx_Weapon_DeployedRemoteC4> Remotes;
var repnotify bool bDetonatedRemotes;
var bool bCanPlaceRemoteRightNow;

replication
{
	if( bNetDirty && bNetOwner && Role == ROLE_Authority)
		bDetonatedRemotes;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bDetonatedRemotes' )
	{
		if ( bDetonatedRemotes && AmmoCount == 0)
		{
			WeaponEmpty();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

function bool Deploy()
{
	if(super.Deploy()) {
	
		if (Rx_PRI(Pawn(Owner).Controller.PlayerReplicationInfo) != None)
			Rx_PRI(Pawn(Owner).Controller.PlayerReplicationInfo).AddRemoteC4(Rx_Weapon_DeployedRemoteC4(DeployedActor));
	
		Remotes.AddItem(Rx_Weapon_DeployedRemoteC4(DeployedActor));
		return true;
	}
	
	return false;
}

simulated function CustomFire()
{
	if(CurrentFireMode == 0) {
		super.CustomFire();
		bCanPlaceRemoteRightNow=false;
		SetTimer(1.5,false,'SetCanPlaceRemoteAgain');
	}
}

function SetCanPlaceRemoteAgain() 
{
	bCanPlaceRemoteRightNow = true;
}

function DetonateCharges()
{
	local Rx_Weapon_DeployedRemoteC4 D;

	if (bDebugWeapon)
	{
		LogInternal("---"@self$"."$GetStateName()$".CustomFire()"@Role@Remotes.Length);
		ScriptTrace();
	}

	if( Role == ROLE_Authority && Remotes.Length > 0 )
	{
		foreach Remotes(D)
		{
			if( D != None ) {
				if(D.bDestroyed == false) {
					D.Explosion();
				}
			}
		}
	}
	Remotes.Length = 0;
}

function ConsumeAmmo( byte FireModeNum ) {
	if(FireModeNum == 0) {
		super.ConsumeAmmo(FireModeNum);
	}
}

simulated function FireAmmunition()
{
	if(CurrentFireMode == 0 && !bCanPlaceRemoteRightNow) {
		return;
	} else {
		if(CurrentFireMode == 0 && Role == Role_Authority) {
			bDetonatedRemotes = false;
		}
		super.FireAmmunition();
	}
}

simulated function WeaponEmpty()
{
	if(bDetonatedRemotes && AmmoCount == 0) {
		super.WeaponEmpty();
			Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
// 		if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
// 			Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
// 		}
		if (Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon == self.Class) {
			Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
		}
		
	} else {
		bForceHidden = true;
		Mesh.SetHidden(true);
	}
}

simulated function bool HasAnyAmmo() {
	return AmmoCount > 0 || Remotes.Length > 0 || !bDetonatedRemotes;
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount ) {
	if(FireModeNum == 1) {
		return true;
	} else {
		return super.HasAmmo(FireModeNum,Amount);
	}
}

simulated function StartFire(byte FireModeNum)
{
	if(FireModeNum == 1)
		ServerDetonateRemotes();
	else	
		super.StartFire(FireModeNum);
}

reliable server function ServerDetonateRemotes()
{
	if(Remotes.Length > 0) {
		DetonateCharges();	
	}
	bDetonatedRemotes = true;
	if(!HasAnyAmmo()) {
		super.WeaponEmpty();
	}	
}

DefaultProperties
{
	DeployedActorClass=class'Rx_Weapon_DeployedRemoteC4'

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RemoteC4.Mesh.SK_RemoteC4_1P'
		AnimSets(0)=AnimSet'RX_WP_RemoteC4.Anims.AS_RemoteC4_Weapon'
		Animations=MeshSequenceA
		FOV=50.0
		Scale=1.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_RemoteC4.Anims.AS_RemoteC4_Arms'

	AttachmentClass = class'Rx_Attachment_RemoteC4'
	
	PlayerViewOffset=(X=16.0,Y=0.0,Z=-3.0)
	FireOffset=(X=10,Y=0,Z=-10)
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = -100.0
	MaxRecoil = -50.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 10.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 2.0
	RecoilSpread = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.015
	RecoilSpreadDeclineSpeed = 0.25

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=0.5
	FireInterval(1)=0.5
	
	EquipTime=0.75
//	PutDownTime=0.5
	
	ReloadTime(0) = 0.5
    ReloadTime(1) = 0.5

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

    Spread(0)=0.0
	Spread(1)=0.0
	
	ClipSize = 1
	InitalNumClips = 2
	MaxClips = 2
	
	//AmmoCount=2
	//MaxAmmoCount=2
	
	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	bCanPlaceRemoteRightNow=true

	WeaponFireSnd[0]=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'
	WeaponFireSnd[1]=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'

	WeaponPutDownSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(1)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

	InventoryGroup=4
	GroupWeight=1
	InventoryMovieGroup=24
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RemoteC4'
}
