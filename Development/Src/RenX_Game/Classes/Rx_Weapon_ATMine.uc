class Rx_Weapon_ATMine extends Rx_Weapon_Beacon;


/**simulated function WeaponEmpty()
{
	if(AmmoCount <= 0) {
		Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
		if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
			Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
		}
		Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
	} 
	super.WeaponEmpty();
}*/

function bool Deploy()
{
	if ( super.Deploy() )
	{
		if (Rx_PRI(Pawn(Owner).Controller.PlayerReplicationInfo) != None)
			Rx_PRI(Pawn(Owner).Controller.PlayerReplicationInfo).AddATMine(Rx_Weapon_DeployedATMine(DeployedActor));
		return true;
	}
	return false;
}

//simulated function PerformRefill();
simulated function PerformRefill()
{
	CurrentAmmoInClip=default.ClipSize;
	AmmoCount = MaxAmmoCount;
}


/**
 * Access to HUD and Canvas. Set bRenderOverlays=true to receive event.
 * Event called every frame when the item is in the InventoryManager
 *
 * @param   HUD H
 */
simulated function ActiveRenderOverlays( HUD H )
{
   local Canvas C;
   local float PanX, PanY, PosX, PosY;

   super(Rx_Weapon).ActiveRenderOverlays(H);
   C = H.Canvas;

   if (LastPos != Owner.Location || !bShowLoadPanel || C == none)
      return;

   // get the draw values
   PanX = C.SizeX * PanelWidth;
   PanY = C.SizeY * PanelHeight;
   // draw the loadpanel border
   //C.DrawColor = Rx_Hud(H).TeamColors[Owner.GetTeamNum()];
   C.SetDrawColor (0, 100, 255, 255); //(255,64,64,255);
   PosX = C.SizeX * 0.5f - PanX * 0.5f;
   PosY = C.SizeY/2 - PanY; //- 300;
   C.SetPos(PosX, PosY);
   C.DrawBox(PanX, PanY);
   // draw the text
   C.SetPos(PosX+3, PosY+3);
   
  // C.DrawText("Planting.....");
   // draw the loadpanel anim
   C.DrawColor.A = 128;
   C.SetPos(PosX + 1, PosY + 1);
   C.DrawRect(PanX * CurrentProgress - 2, PanY - 2);
}




DefaultProperties
{
	DeployedActorClass=class'Rx_Weapon_DeployedATMine'

	PanelWidth  = 0.15f
    PanelHeight = 0.033f
	
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_ATMine.Mesh.SK_WP_ATMine_1P'
		AnimSets(0)=AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object
	
	ArmsAnimSet = AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_Arms'

	AttachmentClass = class'Rx_Attachment_ATMine'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_ATMine'
	
	PlayerViewOffset=(X=10.0,Y=0.0,Z=-2.5)
	FireOffset=(X=25,Y=0,Z=-5)
	
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
	
	TossMag=0

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0)=1.0
	ReloadTime(1)=0.0
	
	EquipTime=1.0
//	PutDownTime=0.5

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.0
	Spread(1)=0.0
	
	ClipSize = 2
	InitalNumClips = 1
	MaxClips = 1

	bRemoveWhenDepleted=false   // We must retain the weapon in our inventory during the super deploy call, so that the deploy in this class can update the AT mine counters.
	SecondsNeedLoad=1
	bBlockDeployCloseToOwnBase=false
	bAffectedByNoDeployVolume=false
	
	bDisplayCrosshair=false
	
	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

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

	InventoryGroup=4
	GroupWeight=1
	InventoryMovieGroup=35

	WeaponIconTexture=Texture2D'RX_WP_ATMine.UI.T_WeaponIcon_ATMine'
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false
}
