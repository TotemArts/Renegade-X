class Rx_FamilyInfo_GDI_Officer extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 7.5f //20
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.0
	Role 					= ROLE_Offense

	CharacterMesh=SkeletalMesh'rx_ch_gdi_officer.Mesh.SK_CH_Officer_New'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost		= 175
	bHighTier				= false
	PT_Damage			= 2
	PT_Range			= 3
	PT_RateOfFire		= 6
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Chaingun'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_GDI_Officer'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 15
	VPCost(1) = 30
	VPCost(2) = 70
	
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
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	PTString="Buy Char - Officer"
}
