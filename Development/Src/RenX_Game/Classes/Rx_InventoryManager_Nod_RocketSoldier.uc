class Rx_InventoryManager_Nod_RocketSoldier extends Rx_InventoryManager_Adv_NOD;

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_MissileLauncher' //2
	PrimaryWeapons[1] = class'Rx_Weapon_ATMine' //5
	SidearmWeapons[0] = class'Rx_Weapon_SMG_NOD' //1
	
	
	//Minor Customization
	AvailableSidearmWeapons(0) = class'Rx_Weapon_SMG_NOD'
	
	//AvailableExplosiveWeapons(2) = class'Rx_Weapon_ATMine'
}
