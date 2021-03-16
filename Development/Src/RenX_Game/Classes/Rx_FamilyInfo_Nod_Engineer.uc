class Rx_FamilyInfo_Nod_Engineer extends Rx_FamilyInfo_Nod;

static function bool IsEngi()
{
	return true;
}

static function bool CanPickupDeployedActor(class<Rx_Weapon_DeployedActor> Deployed)
{
	return Deployed == class'Rx_Weapon_DeployedRemoteC4';
}

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.03f
	HealPointsMultiplier    = 0.006f
	PointsForKill           = 5.0f
	MaxHealth               = 100
	MaxArmor               	= 75
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 0.95 //0.85

	/*PT Block Info*/
	/*------------*/
	bHighTier			= false
	PT_Damage			= 1
	PT_Range			= 2
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun'
	/*---------------*/
	
	CharacterMesh=SkeletalMesh'rx_ch_engineer.Mesh.SK_CH_Engineer_Nod'
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	//StartWeapons[0] = class'Rx_Weapon_RepairGun'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_RemoteC4'
	//StartWeapons[4] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_Engineer' 
	
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
	
	Role = ROLE_Defense
	PTString="Buy Char - Engi"
}
