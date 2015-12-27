class Rx_InventoryManager_Nod_Technician extends Rx_InventoryManager_Adv_NOD;

function int GetPrimaryWeaponSlots() { return 3; }

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_RepairGunAdvanced' //2
	PrimaryWeapons[1] = class'Rx_Weapon_RemoteC4' //4

 	PrimaryWeapons[2] = class'Rx_Weapon_TimedC4_Multiple' //3
 	ExplosiveWeapons[0] = class'Rx_Weapon_ProxyC4' //6
	
	AvailableExplosiveWeapons(0) = class'Rx_Weapon_ProxyC4'	

// 	PrimaryWeapons[2] = class'Rx_Weapon_ProxyC4'
// 	ExplosiveWeapons[0] = class'Rx_Weapon_TimedC4_Multiple'
 //AvailableExplosiveWeapons(1) = class'Rx_Weapon_Grenade'
//AvailableExplosiveWeapons(2) = class'Rx_Weapon_ATMine'			
}
