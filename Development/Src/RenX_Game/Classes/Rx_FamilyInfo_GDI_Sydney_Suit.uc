class Rx_FamilyInfo_GDI_Sydney_Suit extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.157142f 
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 43.75f //Gives 60 points in total. 
	MaxHealth               = 100
	MaxArmor               	= 400 //250
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.95 //0.9
	bFemale					= true; //halo2pac
	

	PhysAsset=PhysicsAsset'RX_CH_GDI_MobiusSuit.Mesh.SK_Suit_Physics'
	CharacterMesh=SkeletalMesh'RX_CH_GDI_MobiusSuit.Mesh.SK_CH_MobiusSuit_Sydney'	//SkeletalMesh'rx_ch_gdi_sydney.Mesh.SK_CH_Sydney'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Sydney'
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost		= 1000
	bHighTier				= true
	PT_Damage			= 6
	PT_Range			= 4
	PT_RateOfFire		= 2
	PT_MagazineCapacity = 1
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_PIC'
	/*---------------*/
	
	DefaultMeshScale=1.1
	BaseTranslationOffset=12.0
	
	CameraHeightModifier = -3.5
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Heavy_Female' 

	InvManagerClass = class'Rx_InventoryManager_GDI_Sydney_Suit'
	
	ImmuneTo[0] = class'Rx_DmgType_Tiberium'
	ImmuneTo[1] = class'Rx_DmgType_TiberiumBleed'
	ImmuneTo[2] = class'Rx_DmgType_ChemicalThrower'
	ImmuneTo[3]	= class'Rx_DmgType_Tiberium_Blue'
	ImmuneTo[4]	= class'Rx_DmgType_TiberiumAutoRifle'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 25
	VPCost(1) = 50
	VPCost(2) = 110
	
	VPReward(0)=8
	VPReward(1)=10
	VPReward(2)=12
	VPReward(3)=14
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=50
	Vet_HealthMod(2)=100
	Vet_HealthMod(3)=150
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.025
	Vet_SprintSpeedMod(2)=0.05
	Vet_SprintSpeedMod(3)=0.075
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthLarge');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourHeavy');

	PTString="Buy Char - Epic"
}
