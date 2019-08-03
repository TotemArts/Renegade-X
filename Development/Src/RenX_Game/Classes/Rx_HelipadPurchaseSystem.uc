class Rx_HelipadPurchaseSystem extends Rx_PurchaseSystem
notplaceable;

var array<Rx_Building_Helipad_GDI> GDIHelipad;
var array<Rx_Building_Helipad_Nod> NodHelipad;

//replication
//{
//	if(bNetInitial && Role == ROLE_Authority)
//		GDIHelipad, NodHelipad;
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
		else if (Rx_Building_Helipad_GDI(building) != None)
		{
			GDIHelipad.AddItem(Rx_Building_Helipad_GDI(building));
		}
		else if (Rx_Building_Helipad_Nod(building) != None)
		{
			NodHelipad.AddItem(Rx_Building_Helipad_Nod(building));
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

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName, factoryName2;
	local string factoryStatus, factoryStatus2;
	local string outputText;
	local int AirdropTime;
	
	if (menuName == "VEHICLES") {
		if (teamID == TEAM_GDI) {
			factoryName = WeaponsFactory.Length > 0 ? Caps(WeaponsFactory[0].GetHumanReadableName()) : "WEAPONS FACTORY";
			factoryName2 = "HELIPAD";
		} else if (teamID == TEAM_NOD) {
			factoryName = AirStrip.Length > 0 ? Caps(AirStrip[0].GetHumanReadableName()) : "AIRSTRIP";
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

		if (!AreAirVehiclesDisabled(rxPC.GetTeamNum()) && !Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit())
			factoryStatus2 = "STATUS: ACTIVE";
		else if (AreAirVehiclesDisabled(rxPC.GetTeamNum()) && !Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit())
			factoryStatus2 = "STATUS: DESTROYED";
		else
			factoryStatus2 = "STATUS: FULL";

		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>"
		$ "\n<font size='9'>" $factoryName2 $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus2 $"</b></font>"; 
		
	} else if (menuName == "CHARACTERS") {
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

simulated function bool AreTeamHelipadsDestroyed(byte teamID)
{
	local int i;

	if(teamID == TEAM_GDI && GDIHelipad.Length > 0)
	{
		for(i=0; i < GDIHelipad.Length; i++)
		{
			if(!GDIHelipad[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else if(teamID == TEAM_NOD && NodHelipad.Length > 0)
	{
		for(i=0; i < NodHelipad.Length; i++)
		{
			if(!NodHelipad[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else
		return true;	
}

simulated function bool AreAirVehiclesDisabled(byte team)
{
	return AreTeamHelipadsDestroyed(team);
}

simulated function bool AreVehiclesDisabled(byte teamID, Controller rxPC)
{
	if (!AreTeamHelipadsDestroyed(teamID))
		return false;

	return Super.AreVehiclesDisabled(teamID, rxPC);
}
