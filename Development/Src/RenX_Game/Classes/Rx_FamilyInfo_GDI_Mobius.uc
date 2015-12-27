class Rx_FamilyInfo_GDI_Mobius extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 30.0f
	MaxHealth               = 100
	MaxArmor               	= 250
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.0

	CharacterMesh=SkeletalMesh'rx_ch_gdi_mobius.Mesh.SK_CH_Mobius_New'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_VoltAutoRifle_GDI'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_GDI_Mobius'
}
