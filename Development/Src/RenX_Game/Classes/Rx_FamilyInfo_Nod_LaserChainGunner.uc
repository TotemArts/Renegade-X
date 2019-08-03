class Rx_FamilyInfo_Nod_LaserChainGunner extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"
	
	// TODO: TEMP DATA  Needs Adjustment
	DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 30.0f	//45
	MaxHealth               = 100
	MaxArmor               	= 250
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.85 //0.8 //0.75
	JumpMultiplier			= 0.8 //0.70 Just high enough to get off of the
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup_Heavy' 
	
	CharacterMesh=SkeletalMesh'RX_CH_Nod_BHS.Mesh.SK_CH_LaserChainGunner'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_BlackHandHeavy'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	DefaultMeshScale=1.15
	BaseTranslationOffset=14.0
	
	CameraHeightModifier = 3
	
	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 450
	bHighTier			= true
	PT_Damage			= 3
	PT_Range			= 4
	PT_RateOfFire		= 6
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserChaingun'
	/*---------------*/

	InvManagerClass = class'Rx_InventoryManager_Nod_LaserChainGunner' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPReward(0)=4
	VPReward(1)=5
	VPReward(2)=7
	VPReward(3)=10
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=75
	Vet_HealthMod(2)=150
	Vet_HealthMod(3)=225
	
	//+X
	Vet_SprintSpeedMod(0)=0.0
	Vet_SprintSpeedMod(1)=0.025
	Vet_SprintSpeedMod(2)=0.05
	Vet_SprintSpeedMod(3)=0.075
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthMedium');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourMedium');
	PTString="Buy Char - Heavy"
}
