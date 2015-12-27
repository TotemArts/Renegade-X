class Rx_FamilyInfo_Nod_Engineer extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.03f
	HealPointsMultiplier    = 0.006f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 50
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.85

	CharacterMesh=SkeletalMesh'rx_ch_engineer.Mesh.SK_CH_Engineer_Nod'
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	//StartWeapons[0] = class'Rx_Weapon_RepairGun'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_RemoteC4'
	//StartWeapons[4] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_Engineer' 
}
