class Rx_FamilyInfo_GDI_Grenadier extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 125 //100
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0//0.95

	CharacterMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Grenadier'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 0; //250;
	bHighTier			= false
	PT_Damage			= 4
	PT_Range			= 3
	PT_RateOfFire		= 2
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_GrenadeLauncher'
	/*---------------*/

	/** one1: Added. */
	InvManagerClass = class'Rx_InventoryManager_GDI_Grenadier'
	
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
	PTString="Buy Char - BasicAT"
}
