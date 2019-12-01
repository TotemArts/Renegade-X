class Rx_FamilyInfo_GDI_Mobius extends Rx_FamilyInfo_GDI;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	//DamagePointsMultiplier  = 0.157142f
	HealPointsMultiplier    = 0.031428f
	PointsForKill           = 52.5f //70
	MaxHealth               = 100
	MaxArmor               	= 250 //250
	Armor_Type 				= A_Kevlar
	SpeedMultiplier			= 1.0
	Role = ROLE_Offense

	

	CharacterMesh=SkeletalMesh'rx_ch_gdi_mobius.Mesh.SK_CH_Mobius_New'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Mobius'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 1000
	bHighTier			= true
	PT_Damage			= 3
	PT_Range			= 2
	PT_RateOfFire		= 6
	PT_MagazineCapacity = 5
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_VoltAutoRifle'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Mobius'
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPReward(0)=5
	VPReward(1)=6
	VPReward(2)=8
	VPReward(3)=12
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=50
	Vet_HealthMod(2)=100
	Vet_HealthMod(3)=150
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0.05
	Vet_SprintSpeedMod(2)=0.075
	Vet_SprintSpeedMod(3)=0.1
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthLarge');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourHeavy');
	PTString="Buy Char - Destroyer"
}
