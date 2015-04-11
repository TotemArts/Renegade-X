class Rx_FamilyInfo_Nod_Mendoza extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 0.0f
	MaxHealth               = 250

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Mendoza.Mesh.SK_CH_Mendoza'
	
	DefaultMeshScale=1.1
	BaseTranslationOffset=14.0
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	InvManagerClass = class'Rx_InventoryManager_Nod_Mendoza' 
}
