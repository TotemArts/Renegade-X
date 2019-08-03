class Rx_FamilyInfo_Nod_ChemicalTrooper extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	// TODO: TEMP DATA  Needs Adjustment
	//DamagePointsMultiplier  = 0.036f
	HealPointsMultiplier    = 0.0072f
	PointsForKill           = 7.5f	//20
	MaxHealth               = 100
	MaxArmor               	= 150
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0
	

	/*PT Block Info*/
	/*------------*/
	bHighTier			= false
	BasePurchaseCost	= 200 ;//250
	PT_Damage			= 4
	PT_Range			= 2
	PT_RateOfFire		= 4
	PT_MagazineCapacity = 3
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ChemicalThrower'
	/*---------------*/
	
	
	CharacterMesh=SkeletalMesh'RX_CH_Nod_BHS.Mesh.SK_CH_ChemicalTrooper'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_ChemicalTrooper'
	
	//StartWeapons[0] = class'Rx_Weapon_ChemicalThrower'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	ImmuneTo[0] = class'Rx_DmgType_Tiberium'
	ImmuneTo[1] = class'Rx_DmgType_TiberiumBleed'
	ImmuneTo[2] = class'Rx_DmgType_ChemicalThrower'
	ImmuneTo[3]	= class'Rx_DmgType_Tiberium_Blue'
	ImmuneTo[4]	= class'Rx_DmgType_TiberiumAutoRifle'
	
	
	
	InvManagerClass = class'Rx_InventoryManager_Nod_ChemicalTrooper' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 15
	VPCost(1) = 30
	VPCost(2) = 60
	
	
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
	PTString="Buy Char - AdvShotgun"
}
