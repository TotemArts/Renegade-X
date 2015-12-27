class Rx_FamilyInfo_GDI_Hotwire extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.083333f
	HealPointsMultiplier    = 0.016667f
	PointsForKill           = 20.0f
	MaxHealth               = 100
	MaxArmor               	= 100
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.9
	bFemale					= true; //halo2pac

	CharacterMesh=SkeletalMesh'rx_ch_gdi_hotwire.Mesh.SK_CH_Hotwire_New'
	
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
}
