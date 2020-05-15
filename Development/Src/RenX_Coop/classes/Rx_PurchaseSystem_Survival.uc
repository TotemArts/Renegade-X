class Rx_PurchaseSystem_Survival extends Rx_PurchaseSystem_Coop;

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName;
	local string factoryStatus;
	local string outputText;
	
	if (menuName == "VEHICLES") 
	{
		factoryName = "VEHICLE REINFORCEMENT";

		if (VehicleSpawnerManagers.length <= 0 && !GetVehicleSpawners() && !AreVehicleBuildingsAvailable(teamID))
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
			else
				factoryStatus = "STATUS: UNAUTHORIZED";
		} 
		else 
		{
			factoryStatus = "STATUS: ACTIVE";
			
		}
		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>"; 
		
	} 
	else if (menuName == "CHARACTERS") {
		if (teamID == TEAM_GDI) 
		{
			factoryName = Barracks.Length > 0 ? Caps(Barracks[0].GetHumanReadableName()) : "ARMORY";
			if(GDIInfantryClasses.Length < 6)
				factoryStatus = "STATUS: UNAVAILABLE";
			else
				factoryStatus = "STATUS: ACTIVE";
		} 
		else if (teamID == TEAM_NOD) {
			factoryName = HandOfNod.Length > 0 ? Caps(HandOfNod[0].GetHumanReadableName()) : "ARMORY";
			if(NodInfantryClasses.Length < 6)
				factoryStatus = "STATUS: UNAVAILABLE";
			else
				factoryStatus = "STATUS: ACTIVE";		
		}
		

		outputText = "<font size='9'>" $factoryName $"</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>" 		
		$ "\n<font size='10'>Advanced Characters" 
		$ "\nAdvanced Weapons</font>";		
	} 
	else if (menuName == "REFILL") 
	{
		factoryStatus = rxPC.RefillCooldown() > 0 ? "Available in<font size='12'><b>"@rxPC.RefillCooldown()@"</font>" : "AVAILABLE";
		outputText = "<font size='9'>ARMORY</font>"
		$ "\n<font size='11'><b>" $factoryStatus $"</b></font>" 		
		$ "\n<font size='9'>Refill Health" 
		$ "\nRefill Armour"
		$ "\nRefill Ammo"
		$ "\nRefill Stamina</font>";
	}


	return outputText;
}

simulated function bool AreVehicleBuildingsAvailable(byte TeamID)
{
	if (teamID == TEAM_GDI && WeaponsFactory.Length <= 0)
	{
		return true;
	}
	else if (teamID == TEAM_NOD && AirStrip.Length <= 0)
	{
		return true;
	}	

	return false;
}

simulated function bool AreHighTierPayClassesDisabled( byte teamID )
{
	if(TeamID == 0 && Barracks.Length > 0)
	{
		return super(Rx_PurchaseSystem).AreHighTierPayClassesDisabled(teamID);
	}
	else if(TeamID == 1 && HandOfNod.Length > 0)
	{
		return super(Rx_PurchaseSystem).AreHighTierPayClassesDisabled(teamID);	
	}

	return false;
}

simulated function bool AreVehiclesDisabled(byte teamID, Controller rxPC)
{

	if (VehicleSpawnerManagers.length <= 0) 
		return Super(Rx_PurchaseSystem).AreVehiclesDisabled(teamID, rxPC); // if no VehicleSpawnerManagers detected, use the good ol' way

	return Super.AreVehiclesDisabled(teamID, rxPC);
}

function bool PurchaseVehicle(Rx_PRI Buyer, int TeamID, int VehicleID )
{
	if (VehicleSpawnerManagers.length <= 0) 
		return Super(Rx_PurchaseSystem).PurchaseVehicle(Buyer,TeamID,VehicleID);

	return Super.PurchaseVehicle(Buyer,TeamID,VehicleID);
}	

DefaultProperties
{
	GDIItemClasses[0]  = class'Rx_Weapon_Airstrike_GDI'
	GDIItemClasses[1]  = class'Rx_Weapon_Blueprint_Defense_GT_GDI'
	GDIItemClasses[2]  = class'Rx_Weapon_RepairTool'
	GDIItemClasses[3]  = class'Rx_Weapon_Blueprint_Defense_Turret_GDI'
	GDIItemClasses[4]  = class'Rx_Weapon_Blueprint_Defense_CeilingTurret'

	NodItemClasses[0]  = class'Rx_Weapon_Airstrike_Nod'
	NodItemClasses[1]  = class'Rx_Weapon_Blueprint_Defense_GT_Nod'
	NodItemClasses[2]  = class'Rx_Weapon_RepairTool'
	NodItemClasses[3]  = class'Rx_Weapon_Blueprint_Defense_Turret_Nod'
	NodItemClasses[4]  = class'Rx_Weapon_Blueprint_Defense_CeilingTurret'

}
