class Rx_FamilyInfo_Nod_Raveshaw extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 30.0f
	MaxHealth               = 100
	MaxArmor               	= 250
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Raveshaw.Mesh.SK_CH_Raveshaw'

	DefaultMeshScale=1.05
	BaseTranslationOffset=8.0
	
	CameraHeightModifier = -1.5
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	InvManagerClass = class'Rx_InventoryManager_Nod_Raveshaw' 
}
