class Rx_FamilyInfo_Nod_FlameTrooper extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

//	DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 100 //125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.05

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Soldier.Mesh.SK_CH_Nod_Soldier_Red'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_FlameThrower'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	ImmuneTo[0] = class'Rx_DmgType_Burn'
	ImmuneTo[1] = class'Rx_DmgType_FireBleed'
	ImmuneTo[2] = class'Rx_DmgType_FlameTank'
	ImmuneTo[3] = class'Rx_DmgType_FlameThrower'

	InvManagerClass = class'Rx_InventoryManager_Nod_FlameTrooper' 
}
