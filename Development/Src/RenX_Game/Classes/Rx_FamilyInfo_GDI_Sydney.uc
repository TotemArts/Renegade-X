class Rx_FamilyInfo_GDI_Sydney extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428
	PointsForKill           = 30.0f
	MaxHealth               = 100
	MaxArmor               	= 250
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.9
	bFemale					= true; //halo2pac

	CharacterMesh=SkeletalMesh'rx_ch_gdi_sydney.Mesh.SK_CH_Sydney'
	
	DefaultMeshScale=1.01
	BaseTranslationOffset=7.0
	
	CameraHeightModifier = -2.0
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Female' 

	InvManagerClass = class'Rx_InventoryManager_GDI_Sydney'
}
