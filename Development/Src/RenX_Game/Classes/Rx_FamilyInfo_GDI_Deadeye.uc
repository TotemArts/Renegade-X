class Rx_FamilyInfo_GDI_Deadeye extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.1f
    HealPointsMultiplier    = 0.02f
    PointsForKill           = 22.5f //30
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_None
	SpeedMultiplier			= 0.9

	/*PT Block Info*/
	/*------------*/
	bHighTier			= true
	bIsSniper			= true
	BasePurchaseCost	= 500
	PT_Damage			= 5
	PT_Range			= 6
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SniperRifle'
	
	/*---------------*/
	
	CharacterMesh=SkeletalMesh'rx_ch_gdi_deadeye.Mesh.SK_CH_Deadeye'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_DeadEye'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*
	StartWeapons[0] = class'Rx_Weapon_SniperRifle_GDI'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Deadeye'

	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 20
	VPCost(1) = 40
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
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');

	PTString="Buy Char - Sniper"
}
