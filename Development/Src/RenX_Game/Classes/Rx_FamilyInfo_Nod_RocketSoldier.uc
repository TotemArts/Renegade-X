class Rx_FamilyInfo_Nod_RocketSoldier extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.044f
	HealPointsMultiplier    = 0.0088f
	PointsForKill           = 9.75f // Solid 20
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.05
	
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	CharacterMesh=SkeletalMesh'rx_ch_nod_officer.Mesh.SK_CH_RocketOfficer_Nod'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_RocketOfficer'
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 225
	bHighTier			= false
	PT_Damage			= 4
	PT_Range			= 6
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 1
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MissileLauncher'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_Nod_RocketSoldier' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 10
	VPCost(1) = 25
	VPCost(2) = 50
	
	VPReward(0)=3
	VPReward(1)=4
	VPReward(2)=5
	VPReward(3)=8
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=25
	Vet_HealthMod(2)=50
	Vet_HealthMod(3)=100
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	PTString="Buy Char - Rocket"
}
