class Rx_FamilyInfo_Nod_Officer extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 9.75 //20 points
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.1
	

	CharacterMesh=SkeletalMesh'rx_ch_nod_officer.Mesh.SK_CH_Officer_Nod'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_Officer'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
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
	
	InvManagerClass = class'Rx_InventoryManager_Nod_Officer' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 10
	VPCost(1) = 25
	VPCost(2) = 50
	
	
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
