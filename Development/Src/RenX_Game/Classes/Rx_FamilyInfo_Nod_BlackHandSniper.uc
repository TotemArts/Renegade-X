class Rx_FamilyInfo_Nod_BlackHandSniper extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.1f
	HealPointsMultiplier    = 0.02f
	PointsForKill           = 0.0f
	MaxHealth               = 200

	CharacterMesh=SkeletalMesh'RX_CH_Nod_BHS.Mesh.SK_CH_BlackHandSniper'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_SniperRifle_Nod'	
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_BlackHandSniper' 
}
