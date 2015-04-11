class Rx_InventoryManager_Nod_Engineer extends Rx_InventoryManager_Basic;

function int GetPrimaryWeaponSlots() { return 2; }

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_RepairGun'
	PrimaryWeapons[1] = class'Rx_Weapon_RemoteC4'
}
