class Rx_InventoryManager_GDI_Sydney extends Rx_InventoryManager_Adv_GDI;

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_PersonalIonCannon' //2
	PrimaryWeapons[1] = class'Rx_Weapon_EMPGrenade_Rechargeable' //5
	PrimaryWeapons[2] = class'Rx_Weapon_ATMine' //4
	
	SidearmWeapons[0] = class'Rx_Weapon_HeavyPistol'//1
	ExplosiveWeapons[0] = class'Rx_Weapon_TimedC4' //3


	
	//Minor Customization
	AvailableSidearmWeapons(0) = class'Rx_Weapon_HeavyPistol'
}
