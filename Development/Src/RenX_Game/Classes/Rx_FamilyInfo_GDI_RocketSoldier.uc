class Rx_FamilyInfo_GDI_RocketSoldier extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.044f
	HealPointsMultiplier    = 0.0088f
	PointsForKill           = 8.5f //20
	
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.95
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_RocketSoldier'
	
	//StartWeapons[0] = class'Rx_Weapon_MissileLauncher'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_GDI_RocketSoldier'
}
