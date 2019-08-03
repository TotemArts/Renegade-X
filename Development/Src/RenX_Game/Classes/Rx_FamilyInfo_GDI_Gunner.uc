class Rx_FamilyInfo_GDI_Gunner extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	CameraHeightModifier = 3

	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.12667f
	HealPointsMultiplier    = 0.02533f
	PointsForKill           = 30.0f //45
	MaxHealth               = 100
	MaxArmor               	= 200
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.95 //0.9
	

	CharacterMesh=SkeletalMesh'RX_CH_GDI_Gunner.Mesh.SK_CH_Gunner_NewRig'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Gunner'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.15
	BaseTranslationOffset=14.0
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 400
	bHighTier			= true
	PT_Damage			= 5
	PT_Range			= 6
	PT_RateOfFire		= 2
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RocketLauncher'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Gunner'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 25
	VPCost(1) = 45
	VPCost(2) = 75
	
	VPReward(0)=4
	VPReward(1)=5
	VPReward(2)=7
	VPReward(3)=10
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=50
	Vet_HealthMod(2)=100
	Vet_HealthMod(3)=150
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	PTString="Buy Char - Heavy"
}
