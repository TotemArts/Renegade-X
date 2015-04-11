class Rx_FamilyInfo_GDI_Officer extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 0.0f
	MaxHealth               = 150

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_Officer_New'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	InvManagerClass = class'Rx_InventoryManager_GDI_Officer'
}
