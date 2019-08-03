class Rx_FamilyInfo_GDI_Patch extends Rx_FamilyInfo_GDI;

DefaultProperties
{
    FamilyID="GDI"
    Faction="GDI"
	// TODO: TEMP DATA  Needs Adjustment
	//DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 26.25f //40
	
	MaxHealth               = 100
	MaxArmor               	= 175
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.125 //1.175
	
	
    CharacterMesh=SkeletalMesh'rx_ch_gdi_patch.Mesh.SK_CH_patch'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Patch'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 450
	bHighTier			= true
	PT_Damage			= 3
	PT_Range			= 5
	PT_RateOfFire		= 4
	PT_MagazineCapacity = 3
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TacticalRifle'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_GDI_Patch'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 25
	VPCost(1) = 45 
	VPCost(2) = 80
	
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
	PTString="Buy Char - Patch"
}
