class Rx_FamilyInfo_GDI_Havoc extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.142857f
	HealPointsMultiplier    = 0.028571f
	PointsForKill           = 30.0f
	MaxHealth               = 100
	MaxArmor               	= 175
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 0.9

	CharacterMesh=SkeletalMesh'RX_CH_GDI_Havoc.Mesh.SK_CH_Havoc'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_RamjetRifle'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_GDI_Havoc'
}
