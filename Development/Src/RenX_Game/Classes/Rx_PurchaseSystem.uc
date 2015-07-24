class Rx_PurchaseSystem extends ReplicationInfo
	notplaceable
	config(PurchaseSystem);

var const array<class<Rx_FamilyInfo> >	GDIInfantryClasses;
var const array<class<Rx_Vehicle> >     GDIVehicleClasses;
var const array<class<Rx_Weapon> >      GDIWeaponClasses;
var const array<class<Rx_Weapon> >      GDIItemClasses;
var const array<class<Rx_FamilyInfo> >	NodInfantryClasses;
var const array<class<Rx_Vehicle> >     NodVehicleClasses;
var const array<class<Rx_Weapon> >      NodWeaponClasses;
var const array<class<Rx_Weapon> >      NodItemClasses;


var config int                          GDIInfantryPrices[15];
var config int                          GDIVehiclePrices[7];
var config int                          GDIWeaponPrices[7];
var config int                          GDIItemPrices[8];
var config int                          NodInfantryPrices[15];
var config int                          NodVehiclePrices[8];
var config int                          NodWeaponPrices[7];
var config int                          NodItemPrices[8];

var Rx_Building_PowerPlant              PowerPlants[2];
var Rx_Building_WeaponsFactory          WeaponsFactory;
var Rx_Building_AirTower                AirTower;
var Rx_Building_Airstrip                AirStrip;
var Rx_Building_Barracks                Barracks;
var Rx_Building_HandOfNod               HandOfNod;
var array<Rx_Building_Silo >            Silos;

var Rx_VehicleManager                   VehicleManager;
var config int 							AirdropCooldownTime;


replication
{
	if( bNetInitial && Role == ROLE_Authority )
		NodInfantryPrices, GDIInfantryPrices, PowerPlants, GDIVehiclePrices,  
			NodVehiclePrices, WeaponsFactory, AirStrip, AirTower, Barracks, HandOfNod;
}

simulated event PostBeginPlay()
{
	local Rx_Building building;

	ForEach AllActors(class'Rx_Building',building)
	{
		if ( ClassIsChildOf(building.Class,  class'Rx_Building_PowerPlant') )
		{
			PowerPlants[building.GetTeamNum()] = Rx_Building_PowerPlant(building);
		}
		else if ( building.Class == class'Rx_Building_WeaponsFactory' || building.Class == class'Rx_Building_WeaponsFactory_Ramps' )
		{
			WeaponsFactory = Rx_Building_WeaponsFactory(building);
		}
		else if ( building.Class == class'Rx_Building_AirTower' || building.Class == class'Rx_Building_AirTower_Ramps')
		{
			AirTower = Rx_Building_AirTower(building);
		}
		else if ( building.Class == class'Rx_Building_AirStrip')
		{
			AirStrip = Rx_Building_AirStrip(building);
		}
		else if ( building.Class == class'Rx_Building_Barracks' || building.Class == class'Rx_Building_Barracks_Ramps')
		{
			Barracks = Rx_Building_Barracks(building);
		}
		else if ( building.Class == class'Rx_Building_HandOfNod' || building.Class == class'Rx_Building_HandOfNod_Ramps')
		{
			HandOfNod = Rx_Building_HandOfNod(building);
		}	
		else if (building.Class == class'Rx_Building_Silo')
		{
			Silos.AddItem(Rx_Building_Silo(building));
		}
	}
}

function SetVehicleManager( Rx_VehicleManager vm )
{
	VehicleManager = vm;
}

simulated function class<Rx_FamilyInfo> GetStartClass(byte TeamID)
{
	if ( TeamID == TEAM_GDI )
	{
		return GDIInfantryClasses[0];
	} 
	else
	{
		return NodInfantryClasses[0];
	}
}

simulated function class<Rx_FamilyInfo> GetHealerClass(byte TeamID)
{
	if ( TeamID == TEAM_GDI )
	{
		return GDIInfantryClasses[13];
	} 
	else
	{
		return NodInfantryClasses[13];
	}
}

simulated function bool IsStealthBlackHand(Rx_PRI pri)
{
	if ( pri.CharClassInfo == NodInfantryClasses[9] )
	{
		return True;
	}
	return False;
}

/**Shahman Teh: Deprecated function.*/
function PurchaseIonCannonBeacon(Rx_Controller Buyer)
{
	`log("WARNING: Deprecated Function");
	Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(1000);
	Rx_InventoryManager(Buyer.Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_IonCannonBeacon',CLASS_ITEM);	
}

/**Shahman Teh: Deprecated function.*/
function PurchaseNukeBeacon(Rx_Controller Buyer)
{
	`log("WARNING: Deprecated Function");
	Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(1000);
	Rx_InventoryManager(Buyer.Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_NukeBeacon',CLASS_ITEM);
}

function PurchaseItem(Rx_Controller Buyer, int TeamID, int ItemID)
{
	if (FFloor(Rx_PRI(Buyer.PlayerReplicationInfo).GetCredits()) >= GetItemPrices(TeamID,ItemID))
	{
			Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(GetItemPrices(TeamID,ItemID));
			Buyer.SetItem(GetItemClass(TeamID, ItemID));
		`LogRxPub("GAME" `s "Purchase;" `s "item" `s GetItemClass(TeamID, ItemID) `s "by" `s `PlayerLog(Buyer.PlayerReplicationInfo));
	}
}
function PurchaseWeapon(Rx_Controller Buyer, int TeamID, int WeaponID)
{
	if (FFloor(Rx_PRI(Buyer.PlayerReplicationInfo).GetCredits()) >= GetWeaponPrices(TeamID,WeaponID))
	{
		Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(GetWeaponPrices(TeamID,WeaponID));
		`LogRxPub("GAME" `s "Purchase;" `s "weapon" `s GetWeaponClass(TeamID, WeaponID) `s "by" `s `PlayerLog(Buyer.PlayerReplicationInfo));
		if (WeaponID == 4 || WeaponID == 5 || WeaponID == 6) {
			if ( (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) || WorldInfo.NetMode == NM_Standalone ){
				if (Rx_Pawn(Buyer.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' || Rx_Pawn(Buyer.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician') {
					Buyer.SetAdvEngineerExplosives(GetWeaponClass(TeamID, WeaponID));				
				} else {
					Buyer.RemoveAllExplosives();
					Buyer.AddExplosives(GetWeaponClass(TeamID, WeaponID));
				}
			} else {
				if (Buyer.bJustBaughtEngineer) {
					Buyer.SetAdvEngineerExplosives(GetWeaponClass(TeamID, WeaponID));
				} else {
					Buyer.RemoveAllExplosives();
					Buyer.AddExplosives(GetWeaponClass(TeamID, WeaponID));
				}
			}
			if (Buyer.bJustBaughtEngineer || Rx_Pawn(Buyer.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' || Rx_Pawn(Buyer.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
				Buyer.SetAdvEngineerExplosives(GetWeaponClass(TeamID, WeaponID));
				//Buyer.SetPrimaryWeapon(GetWeaponClass(TeamID, WeaponID));
			} else {
				Buyer.RemoveAllExplosives();
				Buyer.AddExplosives(GetWeaponClass(TeamID, WeaponID));
			}
		} else {
			Buyer.SetSidearmWeapon(GetWeaponClass(TeamID, WeaponID));
		}
		
	}
}
function  PurchaseCharacter(Rx_Controller Buyer, int TeamID, int CharID)
{
	if (AreHighTierPayClassesDisabled(TeamID) && CharID > 7)
	{
		return; // if the appropriate building is destroyed tehy cannot buy anything > 10
	}

	if (FFloor(Rx_PRI(Buyer.PlayerReplicationInfo).GetCredits()) >= GetClassPrices(TeamID,CharID) )
	{
		Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(GetClassPrices(TeamID,CharID));
		Rx_PRI(Buyer.PlayerReplicationInfo).SetChar(GetFamilyClass(TeamID,CharID),Buyer.Pawn);
		`LogRxPub("GAME" `s "Purchase;" `s "character" `s Rx_PRI(Buyer.PlayerReplicationInfo).CharClassInfo.name `s "by" `s `PlayerLog(Buyer.PlayerReplicationInfo));
		Rx_PRI(Buyer.PlayerReplicationInfo).SetIsSpy(false); // if spy, after new char should be gone
	}
}

function bool PurchaseVehicle(Rx_PRI Buyer, int TeamID, int VehicleID )
{

	if (FFloor(Buyer.GetCredits()) >= GetVehiclePrices(TeamID,VehicleID,AirdropAvailable(Buyer)) && !AreVehiclesDisabled(TeamID, Controller(Buyer.Owner)) )
	{
		if(VehicleManager.QueueVehicle(GetVehicleClass(TeamID,VehicleID),Buyer,VehicleID))
		{
			Buyer.RemoveCredits(GetVehiclePrices(TeamID,VehicleID,AirdropAvailable(Buyer)));
			
			if(Buyer.AirdropCounter > 0)
			{
				Buyer.AirdropCounter++;
				if(WorldInfo.NetMode == NM_Standalone)
					Buyer.LastAirdropTime = Worldinfo.TimeSeconds;
			}
			return true;
		} 
		else 
		{
			if(Rx_Controller(Buyer.Owner) != None)
				Rx_Controller(Buyer.Owner).clientmessage("You have reached the queue limit, vehicle not added to the queue!", 'Vehicle');
			return false;
		}
	}
	return false;
}

function PerformRefill( Rx_Controller cont )
{
	local Rx_Pawn p;
	p = Rx_Pawn(cont.Pawn);

	if ( p != none )
	{
		`LogRxPub("GAME" `s "Purchase;" `s "refill" `s `PlayerLog(cont.PlayerReplicationInfo));
		p.Health = p.HealthMax;
		p.Armor  = p.ArmorMax;
		p.ClientSetStamina(p.MaxStamina);
		if(Rx_Pawn_SBH(p) != None)
			Rx_Pawn_SBH(p).ChangeState('WaitForSt');
	}

	if(Rx_InventoryManager(p.InvManager) != none )
	{
		Rx_InventoryManager(p.InvManager).PerformWeaponRefill();
	}
	else
	{
		`log("We didnt refill weapons because the inventory manager was"@p.InvManager.Class);
	}

}


simulated function int GetClassPrices(byte teamID, int charid)
{
	local float Multiplier;
	Multiplier = 1;
	
	if (PowerPlants[teamID] != None && PowerPlants[teamID].IsDestroyed()) 
	{
		Multiplier = 1.5; // if powerplant is dead then everything costs 2 times as much
	}

	if(AreHighTierPayClassesDisabled(TeamID))
		Multiplier *= 2.0;

	if (teamID == TEAM_GDI)
	{
		return GDIInfantryPrices[charid] * Multiplier;
	} 
	else
	{
		return NodInfantryPrices[charid] * Multiplier;
	}
}

simulated function int GetWeaponPrices(byte teamID, int charid)
{
	local float Multiplier;
	Multiplier = 1;
	
	if (PowerPlants[teamID] != None && PowerPlants[teamID].IsDestroyed()) 
	{
		Multiplier = 1.5; // if powerplant is dead then everything costs 2 times as much
	}

	if (teamID == TEAM_GDI)
	{
		return GDIWeaponPrices[charid] * Multiplier;
	} 
	else
	{
		return NodWeaponPrices[charid] * Multiplier;
	}
}

simulated function int GetItemPrices(byte teamID, int charid)
{
	if (teamID == TEAM_GDI)
	{
		return GDIItemPrices[charid];
	} 
	else
	{
		return NodItemPrices[charid];
	}
}

simulated function class<Rx_FamilyInfo> GetFamilyClass(byte teamID, int charid)
{
	if (teamID == TEAM_GDI)
	{
		return GDIInfantryClasses[charid];
	} 
	else
	{
		return NodInfantryClasses[charid];
	}
}


simulated function class<Rx_Weapon> GetWeaponClass(byte teamID, int weaponid)
{
	if (teamID == TEAM_GDI)
	{
		return GDIWeaponClasses[weaponid];
	} 
	else
	{
		return NodWeaponClasses[weaponid];
	}
}

simulated function class<Rx_Weapon> GetItemClass(byte teamID, int itemid)
{
	if (teamID == TEAM_GDI)
	{
		return GDIItemClasses[itemid];
	} 
	else
	{
		return NodItemClasses[itemid];
	}
}

simulated function bool AreHighTierPayClassesDisabled( byte teamID )
{
	if (Barracks == none || HandOfNod == none) {
		return true;
	}
	if (teamID == TEAM_GDI)
	{
		return Barracks.IsDestroyed();
	}
	else if (teamID == TEAM_NOD)
	{
		return HandOfNod.IsDestroyed();
	}
	`log("Error: TeamID given to AreHighTierPayClassesDisabled does not equal GDI or NOD team numbers",true,'_PurchaseSystem_');
	return true;
}

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName;
	local string factoryStatus;
	local string outputText;
	local int AirdropTime;
	
	
	if (menuName == "VEHICLES") {
		if (teamID == TEAM_GDI) {
			factoryName = WeaponsFactory != none ? Caps(WeaponsFactory.GetHumanReadableName()) : "WEAPONS FACTORY";
		} else if (teamID == TEAM_NOD) {
			factoryName = AirStrip != none ? Caps(AirStrip.GetHumanReadableName()) : "AIRSTRIP";
		}
		if (AreVehiclesDisabled(teamID, rxPC)) {
			if (Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit())
				factoryStatus = "STATUS: FULL"; 
			else if (default.AirdropCooldownTime < 0)
				factoryStatus = "STATUS: DESTROYED";
			else
			{
				AirdropTime = default.AirdropCooldownTime - (WorldInfo.TimeSeconds - Rx_PRi(rxPC.PlayerreplicationInfo).LastAirdropTime);
				factoryStatus = "STATUS: AIRDROP PENDING("$AirdropTime$")";
			}
		} else {
			if(!AirdropAvailable(rxPC.PlayerreplicationInfo))
				factoryStatus = "STATUS: ACTIVE";
			else	
				factoryStatus = "STATUS: AIRDROP READY";
		}
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>"; 
		
	} else if (menuName == "CHARACTERS") {
		if (teamID == TEAM_GDI) {
			factoryName = Barracks != none ? Caps(Barracks.GetHumanReadableName()) : "BARRACKS";
		} else if (teamID == TEAM_NOD) {
			factoryName = HandOfNod != none ? Caps(HandOfNod.GetHumanReadableName()) : "HAND OF NOD";
		}
		factoryStatus = "STATUS: " $ AreHighTierPayClassesDisabled(teamID) ? "LIMITED" : "ACTIVE";
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>" 		
		$ "\n<font size='10'>Advanced Characters" 
		$ "\nAdvanced Weapons</font>";
	}


	return outputText;
}

simulated function int GetVehiclePrices(byte teamID, int VehicleID, bool bViaAirdrop)
{
	local float Multiplier;
	Multiplier = 1.0;
	
	if (PowerPlants[teamID] != None && PowerPlants[teamID].IsDestroyed()) 
	{
		Multiplier = 1.5; // if powerplant is dead then everything costs 2 times as much
	}
	
	if(bViaAirdrop)
		Multiplier *= 2.0;

	if (teamID == TEAM_GDI)
	{
		return GDIVehiclePrices[VehicleID] * Multiplier;
	} 
	else
	{
		return NodVehiclePrices[VehicleID] * Multiplier;
	}
}

simulated function class<Rx_Vehicle> GetVehicleClass(byte teamID, int VehicleID)
{
	if (teamID == TEAM_GDI)
	{
		return GDIVehicleClasses[VehicleID];
	} 
	else
	{
		return NodVehicleClasses[VehicleID];
	}
}

simulated function bool AreVehiclesDisabled(byte teamID, Controller rxPC)
{

	if (WeaponsFactory == none || AirTower == none) {
		return true;
	}

	if (teamID == TEAM_GDI)
	{
		if( Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit() )
		{			
			return true;
		}
		
		if(WeaponsFactory.IsDestroyed())
		{
			if(Rx_Controller(rxPC) != None && (AirdropAvailable(rxPC.playerreplicationinfo)))
				return false;
			else
				return true;				
		}
		
		return false;
	}
	else if (teamID == TEAM_NOD)
	{
		if(  Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit() )
		{
			return true;
		}
		
		if(AirTower.IsDestroyed())
		{
			if(Rx_Controller(rxPC) != None && (AirdropAvailable(rxPC.playerreplicationinfo)))
				return false;
			else
				return true;				
		}		
		
		return false;
	}
	`log("Error: TeamID given to AreVehiclesDisabled does not equal GDI or NOD team numbers",true,'_PurchaseSystem_');
	return true;
}

simulated function bool AirdropAvailable(PlayerreplicationInfo pri)
{
	if(Rx_Pri(pri).LastAirdropTime == 0)
		return false;
	if (default.AirdropCooldownTime < 0)
		return false;
	return default.AirdropCooldownTime - (Worldinfo.TimeSeconds - Rx_Pri(pri).LastAirdropTime) <= 0;
}

simulated function bool AreSilosCaptured(byte teamID)
{
	local byte i;

	for (i = 0; i < Silos.Length; i++) {
		if (Silos[i] == none) {
			continue;
		}

		if (Silos[i].GetTeamNum() == teamID) {
			return true;
		}
	}

	return false;
}


/*******************************/
/* Bot Specific Functionality  */
/*******************************/

function bool DoesHaveRepairGun( class<UTFamilyInfo> inFam )
{
	if ( inFam == GDIInfantryClasses[4] || inFam == NodInfantryClasses[4] || inFam == GDIInfantryClasses[14] || inFam == NodInfantryClasses[14] )
	{
		return true;
	}
	return false;	
}

function class<Rx_FamilyInfo> GetRandomBotClass(byte TeamID)
{
	local array<class<Rx_FamilyInfo> >  classArray;
	local int                           botCharIndex;
	
	if ( TeamID == TEAM_GDI )
	{
		classArray = GDIInfantryClasses;
	} 
	else
	{
		classArray = NodInfantryClasses;
	}
	botCharIndex = Rand(classArray.length-1);
	return classArray[botCharIndex];
}



DefaultProperties
{
	GDIInfantryClasses[0]  = class'Rx_FamilyInfo_GDI_Soldier'	
	GDIInfantryClasses[1]  = class'Rx_FamilyInfo_GDI_Shotgunner'
	GDIInfantryClasses[2]  = class'Rx_FamilyInfo_GDI_Grenadier'
	GDIInfantryClasses[3]  = class'Rx_FamilyInfo_GDI_Marksman'
	GDIInfantryClasses[4]  = class'Rx_FamilyInfo_GDI_Engineer'
	GDIInfantryClasses[5]  = class'Rx_FamilyInfo_GDI_Officer'
	GDIInfantryClasses[6]  = class'Rx_FamilyInfo_GDI_RocketSoldier'
	GDIInfantryClasses[7]  = class'Rx_FamilyInfo_GDI_McFarland'
	GDIInfantryClasses[8]  = class'Rx_FamilyInfo_GDI_Deadeye'
	GDIInfantryClasses[9]  = class'Rx_FamilyInfo_GDI_Gunner'
	GDIInfantryClasses[10] = class'Rx_FamilyInfo_GDI_Patch'
	GDIInfantryClasses[11] = class'Rx_FamilyInfo_GDI_Havoc'
	GDIInfantryClasses[12] = class'Rx_FamilyInfo_GDI_Sydney'
	GDIInfantryClasses[13] = class'Rx_FamilyInfo_GDI_Mobius'
	GDIInfantryClasses[14] = class'Rx_FamilyInfo_GDI_Hotwire'

	GDIVehicleClasses[0]   = class'RenX_Game.Rx_Vehicle_Humvee'
	GDIVehicleClasses[1]   = class'RenX_Game.Rx_Vehicle_APC_GDI'
	GDIVehicleClasses[2]   = class'RenX_Game.Rx_Vehicle_MRLS'
	GDIVehicleClasses[3]   = class'RenX_Game.Rx_Vehicle_MediumTank'
	GDIVehicleClasses[4]   = class'RenX_Game.Rx_Vehicle_MammothTank'
	GDIVehicleClasses[5]   = class'RenX_Game.Rx_Vehicle_Chinook_GDI'
	GDIVehicleClasses[6]   = class'RenX_Game.Rx_Vehicle_Orca'


	GDIWeaponClasses[0]  = class'Rx_Weapon_HeavyPistol'
	GDIWeaponClasses[1]  = class'Rx_Weapon_Carbine'
	GDIWeaponClasses[2]  = class'Rx_Weapon_TiberiumFlechetteRifle'
	GDIWeaponClasses[3]  = class'Rx_Weapon_TiberiumAutoRifle'
	GDIWeaponClasses[4]  = class'Rx_Weapon_EMPGrenade'
	GDIWeaponClasses[5]  = class'Rx_Weapon_ATMine'
	GDIWeaponClasses[6]  = class'Rx_Weapon_SmokeGrenade'

	GDIItemClasses[0]  = class'Rx_Weapon_IonCannonBeacon'
	GDIItemClasses[1]  = class'Rx_Weapon_Airstrike_GDI'


	NodInfantryClasses[0]  = class'Rx_FamilyInfo_Nod_Soldier'
	NodInfantryClasses[1]  = class'Rx_FamilyInfo_Nod_Shotgunner'
	NodInfantryClasses[2]  = class'Rx_FamilyInfo_Nod_FlameTrooper'
	NodInfantryClasses[3]  = class'Rx_FamilyInfo_Nod_Marksman'
	NodInfantryClasses[4]  = class'Rx_FamilyInfo_Nod_Engineer'
	NodInfantryClasses[5]  = class'Rx_FamilyInfo_Nod_Officer'
	NodInfantryClasses[6]  = class'Rx_FamilyInfo_Nod_RocketSoldier'	
	NodInfantryClasses[7]  = class'Rx_FamilyInfo_Nod_ChemicalTrooper'
	NodInfantryClasses[8]  = class'Rx_FamilyInfo_Nod_blackhandsniper'
	NodInfantryClasses[9]  = class'Rx_FamilyInfo_Nod_Stealthblackhand'
	NodInfantryClasses[10] = class'Rx_FamilyInfo_Nod_LaserChainGunner'
	NodInfantryClasses[11] = class'Rx_FamilyInfo_Nod_Sakura'		
	NodInfantryClasses[12] = class'Rx_FamilyInfo_Nod_Raveshaw'
	NodInfantryClasses[13] = class'Rx_FamilyInfo_Nod_Mendoza'
	NodInfantryClasses[14] = class'Rx_FamilyInfo_Nod_Technician'
	
	NodVehicleClasses[0]   = class'RenX_Game.Rx_Vehicle_Buggy'
	NodVehicleClasses[1]   = class'RenX_Game.Rx_Vehicle_APC_Nod'
	NodVehicleClasses[2]   = class'RenX_Game.Rx_Vehicle_Artillery'
	NodVehicleClasses[3]   = class'RenX_Game.Rx_Vehicle_FlameTank'
	NodVehicleClasses[4]   = class'RenX_Game.Rx_Vehicle_LightTank'
	NodVehicleClasses[5]   = class'RenX_Game.Rx_Vehicle_StealthTank'
	NodVehicleClasses[6]   = class'RenX_Game.Rx_Vehicle_Chinook_Nod'
	NodVehicleClasses[7]   = class'RenX_Game.Rx_Vehicle_Apache'

	NodWeaponClasses[0]  = class'Rx_Weapon_HeavyPistol'
	NodWeaponClasses[1]  = class'Rx_Weapon_Carbine'
	NodWeaponClasses[2]  = class'Rx_Weapon_TiberiumFlechetteRifle'
	NodWeaponClasses[3]  = class'Rx_Weapon_TiberiumAutoRifle'
	NodWeaponClasses[4]  = class'Rx_Weapon_EMPGrenade'
	NodWeaponClasses[5]  = class'Rx_Weapon_ATMine'
	NodWeaponClasses[6]  = class'Rx_Weapon_SmokeGrenade'

	NodItemClasses[0]  = class'Rx_Weapon_NukeBeacon'
	NodItemClasses[1]  = class'Rx_Weapon_Airstrike_Nod'
}
