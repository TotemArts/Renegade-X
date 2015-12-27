class Rx_FamilyInfo_GDI_Grenadier extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 100
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.9

	CharacterMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Grenadier'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/** one1: Obsolete.
	 *  
	StartWeapons[0] = class'Rx_Weapon_GrenadeLauncher'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	/** one1: Added. */
	InvManagerClass = class'Rx_InventoryManager_GDI_Grenadier'
}
