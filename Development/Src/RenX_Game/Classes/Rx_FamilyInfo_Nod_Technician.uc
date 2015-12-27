class Rx_FamilyInfo_Nod_Technician extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.083333f
	HealPointsMultiplier    = 0.016667f
	PointsForKill           = 20.0f
	MaxHealth               = 100
	MaxArmor               	= 100
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.9

	CharacterMesh=SkeletalMesh'RX_CH_Technician.Meshes.SK_CH_Technician'
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	//StartWeapons[0] = class'Rx_Weapon_RepairGunAdvanced'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4_Multiple'
	//StartWeapons[3] = class'Rx_Weapon_RemoteC4'
	//StartWeapons[4] = class'Rx_Weapon_ProxyC4'	
	//StartWeapons[5] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_Technician' 
}
