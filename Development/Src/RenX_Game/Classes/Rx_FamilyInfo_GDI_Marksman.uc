class Rx_FamilyInfo_GDI_Marksman extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.020f
	HealPointsMultiplier    = 0.004f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 75
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"

	CharacterMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Shotgunner'
	
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

	InvManagerClass = class'Rx_InventoryManager_GDI_Marksman'
	
	/***********/
	/*Veterancy*/
	/***********/
	
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
