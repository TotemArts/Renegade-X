class Rx_FamilyInfo_Nod_BlackHandSniper extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.1f
	HealPointsMultiplier    = 0.02f
	PointsForKill           = 22.5 // 35
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_None
	SpeedMultiplier			= 0.9
	

	CharacterMesh=SkeletalMesh'RX_CH_Nod_BHS.Mesh.SK_CH_BlackHandSniper'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_BlackHandSniper'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 500
	bHighTier			= true
	bIsSniper			= true
	PT_Damage			= 5
	PT_Range			= 6
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 2
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SniperRifle'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_Nod_BlackHandSniper' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
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
