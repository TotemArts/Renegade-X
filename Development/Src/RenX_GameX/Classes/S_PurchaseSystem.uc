class S_PurchaseSystem extends Rx_PurchaseSystem;

simulated function bool IsStealthBlackHand(Rx_PRI pri)
{
	if (pri.CharClassInfo == class'Rx_FamilyInfo_Nod_StealthBlackHand' || pri.CharClassInfo == class'S_FamilyInfo_BlackHand_StealthBlackHand') return true;

	return false;
}

DefaultProperties
{
	GDIItemClasses[0]  = class'S_Weapon_NukeBeacon'
	GDIItemClasses[1]  = class'S_Weapon_Airstrike_BH'
	GDIItemClasses[2]  = class'Rx_Weapon_RepairTool'
	NodItemClasses[1]  = class'S_Weapon_Airstrike_Nod'
	NodItemClasses[0]  = class'S_Weapon_NukeBeacon'

	GDIInfantryClasses[0]  = class'S_FamilyInfo_BlackHand_Soldier'
	GDIInfantryClasses[1]  = class'S_FamilyInfo_BlackHand_Shotgunner'
	GDIInfantryClasses[2]  = class'S_FamilyInfo_BlackHand_FlameTrooper'
	GDIInfantryClasses[3]  = class'S_FamilyInfo_BlackHand_Marksman'
	GDIInfantryClasses[4]  = class'S_FamilyInfo_BlackHand_Engineer'
	GDIInfantryClasses[5]  = class'S_FamilyInfo_BlackHand_Officer'
	GDIInfantryClasses[6]  = class'S_FamilyInfo_BlackHand_RocketSoldier'	
	GDIInfantryClasses[7]  = class'S_FamilyInfo_BlackHand_ChemicalTrooper'
	GDIInfantryClasses[8]  = class'S_FamilyInfo_BlackHand_blackhandsniper'
	GDIInfantryClasses[9]  = class'S_FamilyInfo_BlackHand_Stealthblackhand'
	GDIInfantryClasses[10] = class'S_FamilyInfo_BlackHand_LaserChainGunner'
	GDIInfantryClasses[11] = class'S_FamilyInfo_BlackHand_Sakura'		
	GDIInfantryClasses[12] = class'S_FamilyInfo_BlackHand_Raveshaw'//_Mutant'
	GDIInfantryClasses[13] = class'S_FamilyInfo_BlackHand_Mendoza'
	GDIInfantryClasses[14] = class'S_FamilyInfo_BlackHand_Technician'

	GDIVehicleClasses[0]   = class'RenX_GameX.S_Vehicle_BlackHand_Buggy_PTInfo'
	GDIVehicleClasses[1]   = class'RenX_GameX.S_Vehicle_BlackHand_APC_PTInfo'
	GDIVehicleClasses[2]   = class'RenX_GameX.S_Vehicle_BlackHand_Artillery_PTInfo'
	GDIVehicleClasses[3]   = class'RenX_GameX.S_Vehicle_BlackHand_FlameTank_PTInfo'
	GDIVehicleClasses[4]   = class'RenX_GameX.S_Vehicle_BlackHand_LightTank_PTInfo'
	GDIVehicleClasses[5]   = class'RenX_GameX.S_Vehicle_BlackHand_StealthTank_PTInfo'
	GDIVehicleClasses[6]   = class'RenX_GameX.S_Vehicle_BlackHand_Chinook_PTInfo'
	GDIVehicleClasses[7]   = class'RenX_GameX.S_Vehicle_BlackHand_Apache_PTInfo'
}