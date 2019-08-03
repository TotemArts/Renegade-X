class Rx_InventoryManager_Nod_Engineer extends Rx_InventoryManager_Basic;

function int GetPrimaryWeaponSlots() { return 2; }

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_RepairGun' //2
	PrimaryWeapons[1] = class'Rx_Weapon_RemoteC4' //4
	
	SidearmWeapons[0] = class'Rx_Weapon_Pistol'// class'Rx_Weapon_HeavyPistol' //1
	AvailableSidearmWeapons(0) = class'Rx_Weapon_Pistol' //class'Rx_Weapon_HeavyPistol' //1
}
