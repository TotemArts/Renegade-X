class Rx_FamilyInfo_GDI_Sydney extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.157142f 
	HealPointsMultiplier    = 0.031428
	PointsForKill           = 52.5f //70
	MaxHealth               = 100
	MaxArmor               	= 200//250
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0 //0.9
	bFemale					= true; //halo2pac
	Role 					= ROLE_Defense

	

	CharacterMesh=SkeletalMesh'rx_ch_gdi_sydney.Mesh.SK_CH_Sydney'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Sydney'
	
	DefaultMeshScale=1.01
	BaseTranslationOffset=7.0
	
	CameraHeightModifier = -2.0
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Female' 

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 1000
	bHighTier			= true
	PT_Damage			= 5
	PT_Range			= 3
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 1
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_PIC'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_GDI_Sydney'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 25
	VPCost(1) = 50
	VPCost(2) = 120
	
	
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
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthLarge');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourHeavy');

	PTString="Buy Char - PIC"
}
