class Rx_FamilyInfo_Nod_Technician extends Rx_FamilyInfo_Nod;

static function bool IsEngi()
{
	return true;
}

static function bool CanPickupDeployedActor(class<Rx_Weapon_DeployedActor> Deployed)
{
	return true;
}

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	//DamagePointsMultiplier  = 0.083333f
	HealPointsMultiplier    = 0.016667f
	PointsForKill           = 12.25f //Total 25
	MaxHealth               = 100
	MaxArmor               	= 125
	Armor_Type 				= A_FLAK
	SpeedMultiplier			= 1.0 /*0.9 set back to 1.0 for the sake of some map design issues. Besides, they got nerfed where it hurt already. Right in the sidearm*/
	Role 					= ROLE_Defense
	/*PT Block Info*/
	/*------------*/
	bHighTier			= true
	BasePurchaseCost	= 350
	PT_Damage			= 1
	PT_Range			= 2
	PT_RateOfFire		= 1
	PT_MagazineCapacity = 6
	PT_Icon				= Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun'
	
	/*---------------*/

	CharacterMesh=SkeletalMesh'RX_CH_Technician.Meshes.SK_CH_Technician'
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_Nod_Technician'
	
	
	ArmMeshPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default" //"RX_CH_GDI_Havoc.Mesh.M_Havoc_Arms"
	ArmSkinPackageName="RX_CH_Arms" //"RX_CH_GDI_Havoc"
	
	
	//StartWeapons[0] = class'Rx_Weapon_RepairGunAdvanced'
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4_Multiple'
	//StartWeapons[3] = class'Rx_Weapon_RemoteC4'
	//StartWeapons[4] = class'Rx_Weapon_ProxyC4'	
	//StartWeapons[5] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_Technician' 
	
	/***********/
	/*Veterancy*/
	/***********/
	
	VPCost(0) = 15
	VPCost(1) = 35
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
	
	
	PTString="Buy Char - AdvEngi"
}
