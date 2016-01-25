class Rx_InventoryManager_GDI_Hotwire extends Rx_InventoryManager_Adv_GDI;

function int GetPrimaryWeaponSlots() { return 3; }

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_RepairGunAdvanced' //2
	PrimaryWeapons[1] = class'Rx_Weapon_RemoteC4' //4
	
	SidearmWeapons[0] = class'Rx_Weapon_HeavyPistol' //1
	AvailableSidearmWeapons(0) = class'Rx_Weapon_HeavyPistol' //1
 	
	PrimaryWeapons[2] = class'Rx_Weapon_TimedC4_Multiple' //3
 	ExplosiveWeapons[0] = class'Rx_Weapon_ProxyC4'  //5
	

	
	AvailableExplosiveWeapons(0) = class'Rx_Weapon_ProxyC4'	
	
	// 	AvailableExplosiveWeapons(1) = class'Rx_Weapon_TimedC4_Multiple'
	// 	PrimaryWeapons[2] = class'Rx_Weapon_ProxyC4'
	// 	ExplosiveWeapons[0] = class'Rx_Weapon_TimedC4_Multiple' 
	//AvailableExplosiveWeapons(1) = class'Rx_Weapon_ATMine'
}
