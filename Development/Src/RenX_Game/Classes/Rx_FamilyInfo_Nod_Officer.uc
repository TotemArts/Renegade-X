class Rx_FamilyInfo_Nod_Officer extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 10.0f
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.1

	CharacterMesh=SkeletalMesh'rx_ch_nod_officer.Mesh.SK_CH_Officer_Nod'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	InvManagerClass = class'Rx_InventoryManager_Nod_Officer' 
}
