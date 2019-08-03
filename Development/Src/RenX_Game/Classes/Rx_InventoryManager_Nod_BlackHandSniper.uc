class Rx_InventoryManager_Nod_BlackHandSniper extends Rx_InventoryManager_Adv_NOD;

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_SniperRifle_Nod' //2
	//PrimaryWeapons[1] = class'Rx_Weapon_SmokeGrenade_Rechargeable' //5
	SidearmWeapons[0] = class'Rx_Weapon_SMG_Nod' //class'Rx_Weapon_HeavyPistol' //1
	
	AvailableSidearmWeapons(0) = class'Rx_Weapon_SMG_Nod' //class'Rx_Weapon_HeavyPistol'
	
	AvailableAbilityWeapons(0) = class'Rx_WeaponAbility_SmokeGrenade' 
}
