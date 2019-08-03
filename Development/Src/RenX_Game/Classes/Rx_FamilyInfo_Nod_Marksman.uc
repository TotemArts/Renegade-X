class Rx_FamilyInfo_Nod_Marksman extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.020f
	HealPointsMultiplier    = 0.004f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 75
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.0
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Soldier.Mesh.SK_CH_Nod_Soldier_Black'
	
	//StartWeapons[0] = class'Rx_Weapon_MarksmanRifle_Nod'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 0
	bHighTier			= false
	PT_Damage			= 3
	PT_Range			= 6
	PT_RateOfFire		= 3
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MarksmanRifle'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_Nod_Marksman' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 5
	VPCost(1) = 15
	VPCost(2) = 30
	
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

	PowerUpClasses.Add(class'Rx_Pickup_HealthSmall');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourLight');
	PTString="Buy Char - Marksman"
}
