class Rx_VeterancyModifiers extends Object;

/*Convenient class to simply hold all of the modifiers for veterancy*/

//Positive
//Infantry or Vehicle
var int Mod_BeaconDefense; 
var int Mod_BeaconAttack;
var int Mod_SniperKilled;
var int Mod_BeaconHolderKill;
var int Mod_Disadvantage; // VRank is lower than that of the person killed
var int Mod_AssaultKill ; //If they're in their base when killed


//Infantry
var int Mod_Headshot; 
var int Mod_SniperKill;

//Negative

//Infantry or Vehicle 
var int Mod_DefenseKill;
var int Mod_UnfairAdvantage; //VRank > the person killed. 

//Infantry 
var int Mod_MineKill;

//Vehicle
var int Mod_Ground2Air; //Ground vehicle to air vehicle 
//EVENTS 
var int Ev_GoodBeaconLaid;

var int Ev_VehicleRepair;
var int Ev_VehicleRepairAssist ; //Vehicle being repaired kills another vehicle
var int Ev_PawnRepair;
var int Ev_BuildingRepair;
var int Ev_C4Disarmed;
var int Ev_BeaconDisarmed;
var int Ev_CaptureTechBuilding;
var int Ev_VehiclesDamaged; 

var int Ev_VehicleSteal; 
var int Ev_InfantryRepairKillAssists; 
var int Ev_VehicleEMP ; 


//Team events 
var int Ev_BuildingDestroyed; 
var int Ev_BuildingArmorBreak; 
var int Ev_HarvesterDestroyed ;


DefaultProperties 
{
	//Positive

	//Infantry and VEhicle 
	Mod_BeaconAttack = +1
	Mod_BeaconDefense = +2

	//Infantry
	Mod_BeaconHolderKill = +5
	Mod_Headshot = +2 
	Mod_SniperKill = +1 
	Mod_SniperKilled = +3 //+1
	Mod_Disadvantage = +2 //Multiplied by the VRank difference
	Mod_AssaultKill = +5
	Mod_MineKill = +1
	
	//Vehicle
	Mod_Ground2Air = +2

	//Negative
	Mod_DefenseKill = -3

	Mod_UnfairAdvantage = -2 //Per VRank level above the target

	//Events 
	Ev_GoodBeaconLaid = +2
	Ev_BuildingRepair = +1 
	Ev_PawnRepair = +2 
	Ev_VehicleRepair = +2 //Same bonus as infantry, but slightly slower to achieve
	Ev_VehicleSteal = +10
	Ev_C4Disarmed = +1
	Ev_BeaconDisarmed = +5
	Ev_VehicleRepairAssist = +4
	Ev_InfantryRepairKillAssists = +2
	Ev_CaptureTechBuilding = +5 
	Ev_VehicleEMP = +2; 
	Ev_VehiclesDamaged = +1

	//Team-Wide Bonuses
	Ev_BuildingDestroyed = +20 //+35 //+50 Modified in Rx_Game based on number of buildings destroyed
	Ev_BuildingArmorBreak = +15 //+20 
	Ev_HarvesterDestroyed = +8

} 
