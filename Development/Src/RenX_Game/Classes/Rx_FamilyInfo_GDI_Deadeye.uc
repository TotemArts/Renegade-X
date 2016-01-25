class Rx_FamilyInfo_GDI_Deadeye extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.1f
    HealPointsMultiplier    = 0.02f
    PointsForKill           = 22.5f //30
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 0.9

	CharacterMesh=SkeletalMesh'rx_ch_gdi_deadeye.Mesh.SK_CH_Deadeye'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*
	StartWeapons[0] = class'Rx_Weapon_SniperRifle_GDI'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Deadeye'
}
