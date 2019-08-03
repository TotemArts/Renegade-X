class Rx_InventoryManager_GDI_Havoc extends Rx_InventoryManager_Adv_GDI;

DefaultProperties
{
	PrimaryWeapons[0] 	= 	class'Rx_Weapon_RamjetRifle' //2
	
	//PrimaryWeapons[1] = class'Rx_Weapon_SmokeGrenade_Rechargeable' //5
	
	SidearmWeapons[0] = class'Rx_Weapon_Carbine' //1
	
	
	AvailableSidearmWeapons(0) = class'Rx_Weapon_Carbine'

	//	AvailableSidearmWeapons(2) = class'Rx_Weapon_HeavyPistol'
	//SidearmWeapons[1] = class'Rx_Weapon_HeavyPistol'	
	//PrimaryWeapons[1]	=	class'Rx_Weapon_TimedC4_Multiple'
	//AvailableExplosiveWeapons(1) = class'Rx_Weapon_Grenade'
	
	//ExplosiveWeapons[0] = class'Rx_Weapon_RemoteC4'//class'Rx_Weapon_TimedC4_Multiple' 
	//AvailableExplosiveWeapons(1) = class'Rx_Weapon_RemoteC4'//class'Rx_Weapon_TimedC4_Multiple'
	
	AvailableAbilityWeapons(0) = class'Rx_WeaponAbility_SmokeGrenade' 
}
