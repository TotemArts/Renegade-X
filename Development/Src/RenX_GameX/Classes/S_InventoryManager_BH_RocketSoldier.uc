class S_InventoryManager_BH_RocketSoldier extends Rx_InventoryManager_Adv_NOD;

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_MissileLauncher' //2
	PrimaryWeapons[1] = class'Rx_Weapon_ATMine' //5
	SidearmWeapons[0] = class'S_Weapon_SMG_BH' //1
	
	
	//Minor Customization
	AvailableSidearmWeapons(0) = class'S_Weapon_SMG_BH'
	
	//AvailableExplosiveWeapons(2) = class'Rx_Weapon_ATMine'
}
