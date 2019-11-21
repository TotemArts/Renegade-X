class Rx_PurchaseSystem extends ReplicationInfo
	notplaceable
	config(PurchaseSystem);

var protectedwrite array<class<Rx_FamilyInfo> >	GDIInfantryClasses;
var protectedwrite array<class<Rx_Vehicle_PTInfo> >     GDIVehicleClasses;
var array<class<Rx_Weapon> >      		GDIWeaponClasses;
var array<class<Rx_Weapon> >      		GDIItemClasses;
var protectedwrite array<class<Rx_FamilyInfo> >			NodInfantryClasses;
var protectedwrite array<class<Rx_Vehicle_PTInfo> >     NodVehicleClasses;
var array<class<Rx_Weapon> >      		NodWeaponClasses;
var array<class<Rx_Weapon> >      		NodItemClasses;

// Deprecated
var config int                          GDIVehiclePrices[7];
var config int                          GDIWeaponPrices[7];
var config int                          GDIItemPrices[8];
var config int                          NodVehiclePrices[8];
var config int                          NodWeaponPrices[7];
var config int                          NodItemPrices[8];

var Array<Rx_Building_PowerPlant>          GDIPowerPlants;
var Array<Rx_Building_PowerPlant>          NodPowerPlants;
var Array<Rx_Building_GDI_VehicleFactory>		WeaponsFactory;
var Array<Rx_Building_Nod_VehicleFactory>		AirStrip;
var Array<Rx_Building_GDI_InfantryFactory>	Barracks;
var Array<Rx_Building_Nod_InfantryFactory>	HandOfNod;
var array<Actor>			            Silos;

var Rx_VehicleManager                   VehicleManager;
var config int 							AirdropCooldownTime;

// replication block nuked because the purchasesystem is inside Rx_Game anyways

//replication
//{
//	if( bNetInitial && Role == ROLE_Authority )
//		GDIPowerPlants, NodPowerPlants, GDIVehiclePrices, NodVehiclePrices, WeaponsFactory, AirStrip, Barracks, HandOfNod;
//
//}

simulated event PostBeginPlay()
{
	local Rx_Building building;

	ForEach AllActors(class'Rx_Building',building)
	{
		if ( ClassIsChildOf(building.Class,  class'Rx_Building_PowerPlant') )
		{
			if(Building.GetTeamNum() == 0)
				GDIPowerPlants.AddItem(Rx_Building_PowerPlant(building));
			else if (Building.GetTeamNum() == 1)
				NodPowerPlants.AddItem(Rx_Building_PowerPlant(building));
		}
		else if (Rx_Building_GDI_VehicleFactory(building) != None)
		{
			WeaponsFactory.AddItem(Rx_Building_GDI_VehicleFactory(building));
		}
		else if (Rx_Building_Nod_VehicleFactory(building) != None)
		{
			AirStrip.AddItem(Rx_Building_Nod_VehicleFactory(building));
		}
		else if (Rx_Building_GDI_InfantryFactory(building) != None)
		{
			Barracks.AddItem(Rx_Building_GDI_InfantryFactory(building));
		}
		else if (Rx_Building_Nod_InfantryFactory(building) != None)
		{
			HandOfNod.AddItem(Rx_Building_Nod_InfantryFactory(building));
		}	
		else if (building.isA('Rx_Building_Silo'))
		{
			Silos.AddItem(building.BuildingInternals);
		}
	}
	//Check if there are map specific vehicles/infantry
	UpdateMapSpecificVehicleClasses(); 
	UpdateMapSpecificInfantryClasses();
}

function SetVehicleManager( Rx_VehicleManager vm )
{
	VehicleManager = vm;
}

simulated function class<Rx_FamilyInfo> GetStartClass(byte TeamID, PlayerReplicationInfo PRI)
{
	if ( TeamID == TEAM_GDI )
	{
		//set starting class based on the last free class (nBab)
		//return GDIInfantryClasses[0]; (Old line)
		//return GDIInfantryClasses[Rx_Hud(GetALocalPlayerController().myHud).HudMovie.lastFreeClass];
		return GDIInfantryClasses[Rx_PRI(PRI).LastFreeCharacterClass];
	} 
	else
	{
		//set starting class based on the last free class (nBab)
		//return NodInfantryClasses[0]; (Old line)
		return NodInfantryClasses[Rx_PRI(PRI).LastFreeCharacterClass];
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

	return class<Rx_FamilyInfo>(pri.CharClassInfo).default.bIsStealth;

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

function bool IsEquiped(Rx_Controller Buyer, int TeamID, int ItemID, optional EClassification Classification)
{
	local class<rx_weapon> weap;

	weap = GetItemClass(TeamID, ItemID);

	return Buyer.IsEquiped(weap, Classification);
}

function PurchaseItem(Controller Buyer, int TeamID, int ItemID)
{

	if (FFloor(Rx_PRI(Buyer.PlayerReplicationInfo).GetCredits()) >= GetItemPrices(TeamID,ItemID))
	{
			Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(GetItemPrices(TeamID,ItemID));
			if(Rx_Controller(Buyer) != None)
				Rx_Controller(Buyer).SetItem(GetItemClass(TeamID, ItemID));
			else if (Rx_Bot(Buyer) != None)
				Rx_Bot(Buyer).SetItem(GetItemClass(TeamID, ItemID));
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

// Temporary; replace with Rx_FamilyInfo.bHighTier
function bool IsHighTierClass(class<Rx_FamilyInfo> CharacterClass) {
	return CharacterClass.default.bHighTier;
}

function bool IsFree(class<Rx_FamilyInfo> CharacterClass) {
	return CharacterClass.default.BasePurchaseCost <= 0;
}

function PurchaseCharacter(Controller Buyer, int TeamID, class<Rx_FamilyInfo> CharacterClass)
{
	if (IsHighTierClass(CharacterClass) && AreHighTierPayClassesDisabled(TeamID))
		return; // You can't buy high tier classes when your infantry factory is destroyed

	if (FFloor(Rx_PRI(Buyer.PlayerReplicationInfo).GetCredits()) >= GetClassPrice(TeamID, CharacterClass) )
	{
		Rx_PRI(Buyer.PlayerReplicationInfo).RemoveCredits(GetClassPrice(TeamID, CharacterClass));
		
		if (IsFree(CharacterClass))
			Rx_PRI(Buyer.PlayerReplicationInfo).SetChar(CharacterClass, Buyer.Pawn, true); // Free class
		else
			Rx_PRI(Buyer.PlayerReplicationInfo).SetChar(CharacterClass, Buyer.Pawn, false); // Not a free class
		
		`LogRxPub("GAME" `s "Purchase;" `s "character" `s Rx_PRI(Buyer.PlayerReplicationInfo).CharClassInfo.name `s "by" `s `PlayerLog(Buyer.PlayerReplicationInfo));
		Rx_PRI(Buyer.PlayerReplicationInfo).SetIsSpy(false); // if spy, after new char should be gone
		
	}
}



function bool PurchaseVehicle(Rx_PRI Buyer, int TeamID, int VehicleID )
{
	local class<Rx_Vehicle> vehicleClass;

	if (FFloor(Buyer.GetCredits()) >= GetVehiclePrices(TeamID,VehicleID,AirdropAvailable(Buyer)) && !AreVehiclesDisabled(TeamID, Controller(Buyer.Owner)) )
	{
		vehicleClass = GetVehicleClass(TeamID,VehicleID);
		if((AreHighTierVehiclesDisabled(TeamID) && VehicleID > 1 && !ClassIsChildOf(vehicleClass, class'Rx_Vehicle_Air'))
			|| AreAirVehiclesDisabled(TeamId) && ClassIsChildOf(vehicleClass, class'Rx_Vehicle_Air'))
			return false; //Limit airdrops to APCs and Humvees/Buggies. 
		
		if(VehicleManager.QueueVehicle(vehicleClass,Buyer,VehicleID))
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
		Buyer.SetVehicleIsStolen(false);
		Buyer.SetVehicleIsFromCrate (false);
	}
	return false;
}

function PerformRefill( Rx_Controller cont )
{
	local Rx_Pawn p;
	
	if(cont.RefillCooldown() > 0)
		return;
	
	p = Rx_Pawn(cont.Pawn);

	if ( p != none )
	{
		`LogRxPub("GAME" `s "Purchase;" `s "refill" `s `PlayerLog(cont.PlayerReplicationInfo));
		p.Health = p.HealthMax;
		p.Armor  = p.ArmorMax;
		p.DamageRate  = 0;
		p.ClientSetStamina(p.MaxStamina);
		if(Rx_Pawn_SBH(p) != None)
			Rx_Pawn_SBH(p).ChangeState('WaitForSt');
		cont.RefillCooldownTime = cont.default.RefillCooldownTime;
		cont.SetTimer(1.0,true,'RefillCooldownTimer');	
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

function BotPerformRefill (Rx_Bot cont)
{
	local Rx_Pawn p;
	
	p = Rx_Pawn(cont.Pawn);

	if ( p != none )
	{
		`LogRxPub("GAME" `s "Purchase;" `s "refill" `s `PlayerLog(cont.PlayerReplicationInfo));
		p.Health = p.HealthMax;
		p.Armor  = p.ArmorMax;
		p.DamageRate  = 0;
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


simulated function int GetClassPrice(byte teamID, class<Rx_FamilyInfo> InfantryClass)
{
	local float Multiplier;
	local int i;
	local bool bPPAvailable;
	Multiplier = 1;

	if(teamID == TEAM_GDI && GDIPowerPlants.Length > 0)
	{
		for(i=0; i < GDIPowerPlants.Length; i++)
		{
			if(!GDIPowerPlants[i].IsDestroyed())
				bPPAvailable = true;
				break;
		}
		if(!bPPAvailable)
			Multiplier = 1.5;
	}
	else if(teamID == TEAM_NOD && NodPowerPlants.Length > 0)
	{
		for(i=0; i < NodPowerPlants.Length; i++)
		{
			if(!NodPowerPlants[i].IsDestroyed())
				bPPAvailable = true;
				break;
		}
		if(!bPPAvailable)
			Multiplier = 1.5;
	}
	
	if(AreHighTierPayClassesDisabled(TeamID))
		Multiplier *= 2.0;

	return InfantryClass.default.BasePurchaseCost * Multiplier;
}

simulated function int GetWeaponPrices(byte teamID, int charid)
{
	local float Multiplier;
	local bool bPPAvailable;
	local int i;

	Multiplier = 1;

	if(teamID == TEAM_GDI && GDIPowerPlants.Length > 0)
	{
		for(i=0; i < GDIPowerPlants.Length; i++)
		{
			if(!GDIPowerPlants[i].IsDestroyed())
				bPPAvailable = true;
				break;
		}
		if(!bPPAvailable)
			Multiplier = 1.5;
	}
	else if(teamID == TEAM_NOD && NodPowerPlants.Length > 0)
	{
		for(i=0; i < NodPowerPlants.Length; i++)
		{
			if(!NodPowerPlants[i].IsDestroyed())
				bPPAvailable = true;
				break;
		}
		if(!bPPAvailable)
			Multiplier = 1.5;
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
		return GDIItemClasses[charid].static.GetPrice(teamID);
	} 
	else
	{
		return NodItemClasses[charid].static.GetPrice(teamID);
	}
}

simulated function bool IsItemBuyable (Rx_Controller Player, byte teamID, int charid)
{
	return GetItemClass(teamID, charid).static.IsBuyable(Player);
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

	if (teamID == TEAM_GDI && Barracks.length <= 0) 
	{
		return true;
	}
	else if (teamID == TEAM_NOD && HandOfNod.length <= 0)
	{
		return true;
	}

	return AreTeamBarracksDestroyed(teamID);
}

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName;
	local string factoryStatus;
	local string outputText;
	local int AirdropTime;
	
	
	if (menuName == "VEHICLES") {
		if (teamID == TEAM_GDI) {
			factoryName = WeaponsFactory.Length > 0 ? Caps(WeaponsFactory[0].GetHumanReadableName()) : "WEAPONS FACTORY";
		} else if (teamID == TEAM_NOD) {
			factoryName = AirStrip.Length > 0 ? Caps(AirStrip[0].GetHumanReadableName()) : "AIRSTRIP";
		}

		if (teamID == TEAM_GDI && WeaponsFactory.Length <= 0)
		{
			factoryStatus = "STATUS : UNAVAILABLE"; 
		}
		else if (teamID == TEAM_NOD && AirStrip.Length <= 0)
		{
			factoryStatus = "STATUS : UNAVAILABLE";
		}
		else if (AreVehiclesDisabled(teamID, rxPC)) 
		{
			if (Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit())
			{
				if(Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).VehicleLimit <= 0)
				{
					factoryStatus = "STATUS: VEHICLE UNAUTHORIZED"; 
				}
				else
				{
					factoryStatus = "STATUS: FULL"; 
				}
			}
			else if (default.AirdropCooldownTime < 0)
				factoryStatus = "STATUS: DESTROYED";
			else
			{
				AirdropTime = default.AirdropCooldownTime - (WorldInfo.TimeSeconds - Rx_PRi(rxPC.PlayerreplicationInfo).LastAirdropTime);
				factoryStatus = "STATUS: AIRDROP PENDING("$AirdropTime$")";
			}
		} 
		else {
			if(!AirdropAvailable(rxPC.PlayerreplicationInfo))
				factoryStatus = "STATUS: ACTIVE";
			else	
				factoryStatus = "STATUS: AIRDROP READY";
		}
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>"; 
		
	} 
	else if (menuName == "CHARACTERS") {
		if (teamID == TEAM_GDI) {
			factoryName = Barracks.Length > 0 ? Caps(Barracks[0].GetHumanReadableName()) : "BARRACKS";
		} else if (teamID == TEAM_NOD) {
			factoryName = HandOfNod.Length > 0 ? Caps(HandOfNod[0].GetHumanReadableName()) : "HAND OF NOD";
		}
		
		factoryStatus = "STATUS: " $ AreHighTierPayClassesDisabled(teamID) ? "LIMITED" : "ACTIVE";
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>" 		
		$ "\n<font size='10'>Advanced Characters" 
		$ "\nAdvanced Weapons</font>";
	} else if (menuName == "REFILL") {
		factoryStatus = rxPC.RefillCooldown() > 0 ? "Available in<font size='12'><b>"@rxPC.RefillCooldown()@"</font>" : "AVAILABLE";
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>" 		
		$ "\n<font size='9'>Refill Health" 
		$ "\nRefill Armour"
		$ "\nRefill Ammo"
		$ "\nRefill Stamina</font>";
	}


	return outputText;
}

simulated function int GetVehiclePrices(byte teamID, int VehicleID, bool bViaAirdrop)
{
	local float Multiplier;

	Multiplier = 1.0;
	
	if(AreTeamPowerPlantsDestroyed(teamID))
	Multiplier = 1.5;

	
	if(bViaAirdrop)
		Multiplier *= 2.0;

	if (teamID == TEAM_GDI)
	{
		return int(GDIVehicleClasses[VehicleID].default.cost) * Multiplier;
	} 
	else
	{
		return int(NodVehicleClasses[VehicleID].default.cost) * Multiplier;
	}
}

simulated function bool AreTeamPowerPlantsDestroyed(byte teamID)
{
	local int i;

	if(teamID == TEAM_GDI && GDIPowerPlants.Length > 0)
	{
		for(i=0; i < GDIPowerPlants.Length; i++)
		{
			if(!GDIPowerPlants[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else if(teamID == TEAM_NOD && NodPowerPlants.Length > 0)
	{
		for(i=0; i < NodPowerPlants.Length; i++)
		{
			if(!NodPowerPlants[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else
		return false;	
}

simulated function bool AreTeamBarracksDestroyed(byte teamID)
{
	local int i;

	if(teamID == TEAM_GDI && Barracks.Length > 0)
	{
		for(i=0; i < Barracks.Length; i++)
		{
			if(!Barracks[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else if(teamID == TEAM_NOD && HandOfNod.Length > 0)
	{
		for(i=0; i < HandOfNod.Length; i++)
		{
			if(!HandOfNod[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else
		return true;	
}

simulated function bool AreTeamFactoriesDestroyed(byte teamID)
{
	local int i;

	if(teamID == TEAM_GDI && WeaponsFactory.Length > 0)
	{
		for(i=0; i < WeaponsFactory.Length; i++)
		{
			if(!WeaponsFactory[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else if(teamID == TEAM_NOD && AirStrip.Length > 0)
	{
		for(i=0; i < AirStrip.Length; i++)
		{
			if(!AirStrip[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else
		return true;	
}

simulated function class<Rx_Vehicle> GetVehicleClass(byte teamID, int VehicleID)
{
	if (teamID == TEAM_GDI)
	{
		return GDIVehicleClasses[VehicleID].default.VehicleClass;
	} 
	else
	{
		return NodVehicleClasses[VehicleID].default.VehicleClass;
	}
}

simulated function bool AreVehiclesDisabled(byte teamID, Controller rxPC)
{

	if (teamID == TEAM_GDI && WeaponsFactory.Length <= 0) 
		return true;

	else if (teamID == TEAM_NOD && AirStrip.Length <= 0)
		return true;

	if (teamID == TEAM_GDI)
	{
		if( Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit() )
		{			
			return true;
		}
				
		if(AreTeamFactoriesDestroyed(teamID))
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

		if(AreTeamFactoriesDestroyed(teamID))
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

simulated function bool AreHighTierVehiclesDisabled (byte TeamID)
{

	if (WeaponsFactory.Length <= 0 && teamID == TEAM_GDI)
	{
		return true;
	}
	else if (AirStrip.Length <= 0 && teamID == TEAM_NOD)
	{
		return true;
	}
	
	return AreTeamFactoriesDestroyed(teamID);
}

simulated function bool AreAirVehiclesDisabled(byte TeamID)
{
	return AreHighTierVehiclesDisabled(TeamID);
}

simulated function bool AirdropAvailable(PlayerreplicationInfo pri)
{
	if(Rx_Pri(pri).LastAirdropTime == 0 && Rx_Pri(pri).AirdropCounter == 0) /*This didn't take into account whether or not the Airdrop counter was active or not. If WorldTime was 0 (like when a player joins), it just said screw your airdrops forever n00b. FIXED -Yosh */ 
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

simulated function UpdateMapSpecificVehicleClasses(){
	local Rx_MapInfo MI; 
	local int i; 
	
	MI = Rx_MapInfo(WorldInfo.GetMapInfo());
	
	if(MI == none)
			return; 
	else{
		//Update GDI vehicles based on map info 
		for(i=0; i<MI.GDIVehicleArray.Length; i++){
			GDIVehicleClasses[i] = MI.GDIVehicleArray[i];
		}
		//Update Nod vehicles based on map info 
		for(i=0; i<MI.NodVehicleArray.Length; i++){
			NodVehicleClasses[i] = MI.NodVehicleArray[i];
		}
	}	
}

simulated function UpdateMapSpecificInfantryClasses(){
	local Rx_MapInfo MI; 
	local int i; 
	
	MI = Rx_MapInfo(WorldInfo.GetMapInfo());
	
	if(MI == none)
			return; 
	else{
		//Update GDI vehicles based on map info 
		for(i=0; i<MI.GDIInfantryArray.Length; i++){
			GDIInfantryClasses[i] = MI.GDIInfantryArray[i];
		}
		//Update Nod vehicles based on map info 
		for(i=0; i<MI.NodInfantryArray.Length; i++){
			NodInfantryClasses[i] = MI.NodInfantryArray[i];
		}
	}	
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

function array<class<Rx_FamilyInfo> > ClassesForTeam(byte TeamNum) {
	if (TeamNum == TEAM_GDI) {
		return GDIInfantryClasses;
	}
	else {
		return NodInfantryClasses;
	}
}

function array<class<Rx_Vehicle_PTInfo> > VehiclesForTeam(byte TeamNum) {
	if (TeamNum == TEAM_GDI) {
		return GDIVehicleClasses;
	}
	else {
		return NodVehicleClasses;
	}
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
	
	GDIVehicleClasses[0]   = class'RenX_Game.Rx_Vehicle_GDI_Humvee_PTInfo'
	GDIVehicleClasses[1]   = class'RenX_Game.Rx_Vehicle_GDI_APC_PTInfo'
	GDIVehicleClasses[2]   = class'RenX_Game.Rx_Vehicle_GDI_MRLS_PTInfo'
	GDIVehicleClasses[3]   = class'RenX_Game.Rx_Vehicle_GDI_MediumTank_PTInfo'
	GDIVehicleClasses[4]   = class'RenX_Game.Rx_Vehicle_GDI_MammothTank_PTInfo'
	GDIVehicleClasses[5]   = class'RenX_Game.Rx_Vehicle_GDI_Chinook_PTInfo'
	GDIVehicleClasses[6]   = class'RenX_Game.Rx_Vehicle_GDI_Orca_PTInfo'

	GDIItemClasses[0]  = class'Rx_Weapon_IonCannonBeacon'
	GDIItemClasses[1]  = class'Rx_Weapon_Airstrike_GDI'
	GDIItemClasses[2]  = class'Rx_Weapon_RepairTool'

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
	NodInfantryClasses[12] = class'Rx_FamilyInfo_Nod_Raveshaw'//_Mutant'
	NodInfantryClasses[13] = class'Rx_FamilyInfo_Nod_Mendoza'
	NodInfantryClasses[14] = class'Rx_FamilyInfo_Nod_Technician'
	
	NodVehicleClasses[0]   = class'RenX_Game.Rx_Vehicle_Nod_Buggy_PTInfo'
	NodVehicleClasses[1]   = class'RenX_Game.Rx_Vehicle_Nod_APC_PTInfo'
	NodVehicleClasses[2]   = class'RenX_Game.Rx_Vehicle_Nod_Artillery_PTInfo'
	NodVehicleClasses[3]   = class'RenX_Game.Rx_Vehicle_Nod_FlameTank_PTInfo'
	NodVehicleClasses[4]   = class'RenX_Game.Rx_Vehicle_Nod_LightTank_PTInfo'
	NodVehicleClasses[5]   = class'RenX_Game.Rx_Vehicle_Nod_StealthTank_PTInfo'
	NodVehicleClasses[6]   = class'RenX_Game.Rx_Vehicle_Nod_Chinook_PTInfo'
	NodVehicleClasses[7]   = class'RenX_Game.Rx_Vehicle_Nod_Apache_PTInfo'

	NodItemClasses[0]  = class'Rx_Weapon_NukeBeacon'
	NodItemClasses[1]  = class'Rx_Weapon_Airstrike_Nod'
	NodItemClasses[2]  = class'Rx_Weapon_RepairTool'
}
