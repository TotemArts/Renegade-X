class Rx_FamilyInfo_GDI_McFarland extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"
	// TODO: TEMP DATA  Needs Adjustment
	//DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 8.75f //20
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.05//1.1
	

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_McFarland'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_McFarland'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.0
	BaseTranslationOffset=8.0
	
	CameraHeightModifier = -3.0
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 200; //250;
	bHighTier			= false
	PT_Damage			= 5
	PT_Range			= 2
	PT_RateOfFire		= 3
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FlakCannon'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_GDI_McFarland'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 15
	VPCost(1) = 30
	VPCost(2) = 60
	
	VPReward(0)=3
	VPReward(1)=4
	VPReward(2)=5
	VPReward(3)=8
	
	
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
	PTString="Buy Char - AdvShotgun"
}
