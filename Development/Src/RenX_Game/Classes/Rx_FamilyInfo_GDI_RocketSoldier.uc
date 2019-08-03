class Rx_FamilyInfo_GDI_RocketSoldier extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.044f
	HealPointsMultiplier    = 0.0088f
	PointsForKill           = 8.5f //20
	
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.95
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_RocketSoldier'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_RocketSoldier'
	
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

	InvManagerClass = class'Rx_InventoryManager_GDI_RocketSoldier'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 15
	VPCost(1) = 30
	VPCost(2) = 55
	
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
	Vet_SprintSpeedMod(1)=0.025
	Vet_SprintSpeedMod(2)=0.05
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	PTString="Buy Char - Rocket"
}
