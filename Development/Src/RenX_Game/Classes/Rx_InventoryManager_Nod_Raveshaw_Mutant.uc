class Rx_InventoryManager_Nod_Raveshaw_Mutant extends Rx_InventoryManager_Adv_NOD;

DefaultProperties
{
	PrimaryWeapons[0] = class'Rx_Weapon_Railgun' //class'Rx_Weapon_PlasmaChainGun' //2
	PrimaryWeapons[1] = class'Rx_Weapon_ATMine' //4
	//PrimaryWeapons[2] = class'Rx_Weapon_EMPGrenade_Rechargeable' //5
	SidearmWeapons[0] =  class'Rx_Weapon_TiberiumAutoRifle' // class'Rx_Weapon_TiberiumFlechetteRifle' //1
	ExplosiveWeapons[0] = class'Rx_Weapon_TimedC4' //3
	
	
	AvailableSidearmWeapons(0) = class'Rx_Weapon_TiberiumAutoRifle' //class'Rx_Weapon_TiberiumFlechetteRifle'
	
	//Minor Customization
	//AvailableSidearmWeapons(1) = class'Rx_Weapon_SMG_NOD'
	//AvailableExplosiveWeapons(2) = class'Rx_Weapon_ATMine'
	
	AvailableAbilityWeapons(0) = class'Rx_WeaponAbility_EMPGrenade' 
}
