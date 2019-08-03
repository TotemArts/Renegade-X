class Rx_Weapon_TimedC4 extends Rx_Weapon_Deployable;

/**
simulated function WeaponEmpty();

		if(AmmoCount <= 0) {
	Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
		if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
 			Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
 		}
		if (Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon == self.Class) {
			Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
		}
	} 
	super.WeaponEmpty();
*/

// function bool Deploy()
// {
// 	
// 	if(super(Rx_Weapon_Deployable).Deploy()) {
// 		if (AmmoCount <= 0) {	
// 			//Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
// 			if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
// 				Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
// 			}
// 			Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
// 		}
// 		return true;
// 	}
// 	return false;
// 
// // 	if (AmmoCount <= 0) {
// // 		Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
// // 		if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
// // 			Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
// // 		}
// // 		Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
// // 	}
// // 	return super.Deploy();
// }

function bool CanAttack(Actor Other)
{
	local Vector Dummy1, Dummy2;


	if((Other.IsA('Vehicle') || Other.IsA('Rx_BuildingAttachment')) && VSize(Other.location - Instigator.GetWeaponStartTraceLocation()) <= 200 && Rx_Bot(Instigator.Controller).LineOfSightTo(Other)
		&& Trace(Dummy1,Dummy2,Other.Location,Instigator.Location,,,,TRACEFLAG_Bullet) == Other)
		return true;
	else
		return false;
}

DefaultProperties
{
	DeployedActorClass=class'Rx_Weapon_DeployedTimedC4'

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TimedC4.Mesh.SK_WP_TimedC4_1P' //SkeletalMesh'RX_WP_TimedC4.Mesh.SK_WP_Timed_1P'
		AnimSets(0)=AnimSet'RX_WP_TimedC4.Anims.AS_WP_TimedC4_1P' //AnimSet'RX_WP_TimedC4.Anims.K_WP_Timed_1P'
		PhysicsAsset=PhysicsAsset'RX_WP_TimedC4.Mesh.SK_WP_TimedC4_1P_Physics'
		Animations=MeshSequenceA
		Scale=1.0
		FOV=50.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_TimedC4.Anims.AS_WP_TimedC4_Arms' //AnimSet'RX_WP_TimedC4.Anims.K_WP_Timed_1P_Arms'

	AttachmentClass = class'Rx_Attachment_TimedC4'
	
	FireOffset=(X=0,Y=2.5,Z=-8)
	
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
	FireInterval(0)=+0.75
	FireInterval(1)=+0.0
	
	EquipTime=0.6
//	PutDownTime=0.35
	
	//AmmoCount=1
	//MaxAmmoCount=1
	
	ClipSize = 1
	InitalNumClips = 1
	MaxClips = 1

	PlayerViewOffset=(X=15.0,Y=-1.0,Z=-3.0)

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.0
	Spread(1)=0.0
	
	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	WeaponFireSnd[0]=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'
	WeaponFireSnd[1]=None

	WeaponPutDownSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(1)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

	InventoryGroup=3.1
	GroupWeight=1
	InventoryMovieGroup=23

	WeaponIconTexture=Texture2D'RX_WP_TimedC4.UI.T_WeaponIcon_TimedC4'

	//DroppedPickupClass = class'RxDroppedPickup_AutoRifle'

	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.1
	CurrentRating=+0.3
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false
	bOkAgainstBuildings=true
	bOkAgainstVehicles=true

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TimedC4'
}
