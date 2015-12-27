class Rx_FamilyInfo_Nod_ChemicalTrooper extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	// TODO: TEMP DATA  Needs Adjustment
	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 10.0f	
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0

	CharacterMesh=SkeletalMesh'RX_CH_Nod_BHS.Mesh.SK_CH_ChemicalTrooper'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_ChemicalThrower'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	ImmuneTo[0] = class'Rx_DmgType_Tiberium'
	ImmuneTo[1] = class'Rx_DmgType_TiberiumBleed'
	ImmuneTo[2] = class'Rx_DmgType_ChemicalThrower'

	InvManagerClass = class'Rx_InventoryManager_Nod_ChemicalTrooper' 
}
