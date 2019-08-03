class Rx_FamilyInfo_Nod_FlameTrooper extends Rx_FamilyInfo_Nod;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

//	DamagePointsMultiplier  = 0.025f
	HealPointsMultiplier    = 0.005f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 100 //125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.05

	CharacterMesh=SkeletalMesh'RX_CH_Nod_Soldier.Mesh.SK_CH_Nod_Soldier_Red'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_Flamethrower'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_FlameThrower'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	ImmuneTo[0] = class'Rx_DmgType_Burn'
	ImmuneTo[1] = class'Rx_DmgType_FireBleed'
	ImmuneTo[2] = class'Rx_DmgType_FlameTank'
	ImmuneTo[3] = class'Rx_DmgType_FlameThrower'

	/*PT Block Info*/
	/*------------*/
	BasePurchaseCost	= 0
	bHighTier			= false
	PT_Damage			= 3
	PT_Range			= 2
	PT_RateOfFire		= 6
	PT_MagazineCapacity = 3
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FlameThrower'
	/*---------------*/
	
	InvManagerClass = class'Rx_InventoryManager_Nod_FlameTrooper' 
	
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
	Vet_SprintSpeedMod(2)=0.1
	Vet_SprintSpeedMod(3)=0.125
	
	/******************/

	PowerUpClasses.Add(class'Rx_Pickup_HealthSmall');
	PowerUpClasses.Add(class'Rx_Pickup_ArmourLight');
	PTString="Buy Char - BasicAT"
}
