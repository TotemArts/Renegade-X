class Rx_FamilyInfo_GDI_Gunner extends Rx_FamilyInfo;

DefaultProperties
{
	CameraHeightModifier = 3

	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.12667f
	HealPointsMultiplier    = 0.02533f
	PointsForKill           = 20.0f
	MaxHealth               = 100
	MaxArmor               	= 200
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.9

	CharacterMesh=SkeletalMesh'RX_CH_GDI_Gunner.Mesh.SK_CH_Gunner_NewRig'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.15
	BaseTranslationOffset=14.0
	
	/*
	StartWeapons[0] = class'Rx_Weapon_RocketLauncher'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Gunner'
}
