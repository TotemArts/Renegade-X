class Rx_PurchaseSystem_Coop extends Rx_PurchaseSystem;

var array<Rx_VehicleSpawnerManager> VehicleSpawnerManagers;

simulated event PostBeginPlay()
{
	local Rx_VehicleSpawnerManager VSM;
	super.PostBeginPlay();

	foreach WorldInfo.AllActors(class'Rx_VehicleSpawnerManager',VSM)
	{
		VehicleSpawnerManagers.AddItem(VSM);
	}
}

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName;
	local string factoryStatus;
	local string outputText;
	
	
	if (menuName == "VEHICLES") 
	{
		factoryName = "VEHICLE REINFORCEMENT";

		if (VehicleSpawnerManagers.length <= 0)
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
		if (teamID == TEAM_GDI) {
			factoryName = Barracks.Length > 0 ? Caps(Barracks[0].GetHumanReadableName()) : "ARMORY";
		} else if (teamID == TEAM_NOD) {
			factoryName = HandOfNod.Length > 0 ? Caps(HandOfNod[0].GetHumanReadableName()) : "ARMORY";
		}
		
		factoryStatus = "STATUS: ACTIVE";
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

simulated function bool AreVehiclesDisabled(byte teamID, Controller rxPC)
{

	local Rx_VehicleSpawnerManager VSM;

	if (VehicleSpawnerManagers.length <= 0) 
		return true;


	if( Rx_TeamInfo(WorldInfo.GRI.Teams[teamID]).IsAtVehicleLimit() )
	{			
		return true;
	}

	foreach VehicleSpawnerManagers(VSM)
	{
		if(VSM.bEnabled)
			return false;
	}



	`log("Error: TeamID given to AreVehiclesDisabled does not equal GDI or NOD team numbers",true,'_PurchaseSystem_');
	return true;
}

simulated function bool AreHighTierVehiclesDisabled (byte TeamID)
{
	return AreVehiclesDisabled(TeamID,None);
}

simulated function bool AreHighTierPayClassesDisabled( byte teamID )
{
	return false;
}
