class Rx_FamilyInfo_Nod_Raveshaw extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 43.75f //Gives 60 points in total. 
	MaxHealth               = 100
	MaxArmor               	= 200
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0 //1.05
	Role 					= ROLE_Defense


	CharacterMesh=SkeletalMesh'RX_CH_Nod_Raveshaw.Mesh.SK_CH_Raveshaw'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_Raveshaw'
	
	DefaultMeshScale=1.05
	BaseTranslationOffset=8.0
	
	CameraHeightModifier = -1.5
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost		= 1000
	bHighTier				= true
	PT_Damage			= 6
	PT_Range			= 4
	PT_RateOfFire		= 2
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Railgun'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_Nod_Raveshaw' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	
	VPCost(0) = 25
	VPCost(1) = 50
	VPCost(2) = 110
	
	VPReward(0)=5
	VPReward(1)=6
	VPReward(2)=8
	VPReward(3)=12
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=25
	Vet_HealthMod(2)=50
	Vet_HealthMod(3)=100
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.025
	Vet_SprintSpeedMod(2)=0.05
	Vet_SprintSpeedMod(3)=0.075
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthLarge');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourHeavy');
	PTString="Buy Char - PIC"
}
