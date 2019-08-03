class Rx_FamilyInfo_GDI_Soldier extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 100
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.0

	CharacterMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Soldier'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Soldier'
	
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
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

	/** one1: Added. */
	InvManagerClass = class'Rx_InventoryManager_GDI_Soldier'
	
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
