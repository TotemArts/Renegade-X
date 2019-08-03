class Rx_FamilyInfo_Nod_StealthBlackHand extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.12667f
	HealPointsMultiplier    = 0.02533f
	PointsForKill           = 27.5f //40
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_Lazarus
	SpeedMultiplier			= 1.1 // +10%, +7.5%, +5%
	

	CharacterMesh=SkeletalMesh'RX_CH_Nod_SBH.Mesh.SK_CH_StealthBlackHand'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_SBH'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 400
	bHighTier			= true
	PT_Damage			= 4
	PT_Range			= 4
	PT_RateOfFire		= 4
	PT_MagazineCapacity = 3
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserRifle'
	/*---------------*/
	
	
	InvManagerClass = class'Rx_InventoryManager_Nod_StealthBlackHand' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 20
	VPCost(1) = 35
	VPCost(2) = 70
	
	VPReward(0)=4
	VPReward(1)=5
	VPReward(2)=7
	VPReward(3)=10
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=25
	Vet_HealthMod(2)=50
	Vet_HealthMod(3)=75
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.025
	Vet_SprintSpeedMod(2)=0.05
	Vet_SprintSpeedMod(3)=0.075
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	
	bIsStealth = True
	PTString="Buy Char - SBH"
}
