class Rx_FamilyInfo_GDI_McFarland extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"
	// TODO: TEMP DATA  Needs Adjustment
	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 10.0f
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.075

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_McFarland'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.0
	BaseTranslationOffset=8.0
	
	CameraHeightModifier = -3.0
	
	/*
	StartWeapons[0] = class'Rx_Weapon_FlakCannon'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_McFarland'
}
