class Rx_FamilyInfo_Nod_Sakura extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.142857f
	HealPointsMultiplier    = 0.028571f
	PointsForKill           = 40.0f //55 total points for kill
	MaxHealth               = 100
	MaxArmor               	= 200
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 0.9
	bFemale					= true; //halo2pac

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Sakura.Mesh.SK_CH_Sakura'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.01
	BaseTranslationOffset=7.0
	
	CameraHeightModifier = -2.0
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Female' 
	
	//StartWeapons[0] = class'Rx_Weapon_RamjetRifle'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_Sakura' 
}
