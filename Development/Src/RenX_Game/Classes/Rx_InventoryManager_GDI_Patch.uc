class Rx_InventoryManager_GDI_Patch extends Rx_InventoryManager_Adv_GDI;

DefaultProperties
{
    PrimaryWeapons[0] = class'Rx_Weapon_TacticalRifle' //2
	//PrimaryWeapons[1] = class'TS_Weapon_AutoRifle_GDI'
	//PrimaryWeapons[1] = class'Rx_Weapon_Grenade_Rechargeable' //5
	//PrimaryWeapons[1] = class'Rx_Weapon_SmokeGrenade_Rechargeable'
	SidearmWeapons[0] = class'Rx_Weapon_HeavyPistol' //1
	
	AvailableSidearmWeapons(0) = class'Rx_Weapon_HeavyPistol'

	//AvailableAbilityWeapons(0)=class'Rx_WeaponAbility_TacRifleGrenade'
	//AvailableAbilityWeapons(0) = class'Rx_WeaponAbility_EMPGrenade' 
}
