class Rx_FamilyInfo_GDI_Patch extends Rx_FamilyInfo;

DefaultProperties
{
    FamilyID="GDI"
    Faction="GDI"
	// TODO: TEMP DATA  Needs Adjustment
	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 20.0f
	
	MaxHealth               = 100
	MaxArmor               	= 175
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.15
	
    CharacterMesh=SkeletalMesh'rx_ch_gdi_patch.Mesh.SK_CH_patch'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	InvManagerClass = class'Rx_InventoryManager_GDI_Patch'
}
