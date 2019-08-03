class Rx_FamilyInfo_GDI_Hotwire extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.083333f
	HealPointsMultiplier    = 0.016667f
	PointsForKill           = 12.25f //25
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0
	bFemale					= true; //halo2pac
	
	/*PT Block Info*/
	/*------------*/
	bHighTier			= true
	BasePurchaseCost	= 350
	PT_Damage			= 1
	PT_Range			= 2
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun'
	
	/*---------------*/

	CharacterMesh=SkeletalMesh'rx_ch_gdi_hotwire.Mesh.SK_CH_Hotwire_New'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_HotWire'
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	DefaultMeshScale=1.01
	BaseTranslationOffset=7.0
	
	CameraHeightModifier = -2.0
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Female' 
	
	/*
	StartWeapons[0] = class'Rx_Weapon_RepairGunAdvanced'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4_Multiple'
	StartWeapons[3] = class'Rx_Weapon_RemoteC4'
	StartWeapons[4] = class'Rx_Weapon_ProxyC4'
	StartWeapons[5] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Hotwire'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 20
	VPCost(1) = 40
	VPCost(2) = 90
	
	VPReward(0)=3
	VPReward(1)=4
	VPReward(2)=5
	VPReward(3)=8
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=25
	Vet_HealthMod(2)=50
	Vet_HealthMod(3)=75
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	
	Role = ROLE_Defense
	PTString="Buy Char - AdvEngi"
}
