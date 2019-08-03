class Rx_FamilyInfo_Nod_Soldier extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f //15 solid points
	MaxHealth               = 100
	MaxArmor               	= 100
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Soldier.Mesh.SK_CH_Nod_Soldier'
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	/*PT Block Info*/
	/*------------*/
	bHighTier			= false
	BasePurchaseCost	= 0 
	PT_Damage			= 2
	PT_Range			= 4
	PT_RateOfFire		= 5
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Autorifle'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_Nod_Soldier' 
	
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
	PTString="Buy Char - Soldier"
}
