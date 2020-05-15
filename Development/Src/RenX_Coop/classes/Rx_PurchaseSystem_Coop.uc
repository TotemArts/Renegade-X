class Rx_PurchaseSystem_Coop extends Rx_PurchaseSystem;

var array<Rx_VehicleSpawnerManager> VehicleSpawnerManagers;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	GetVehicleSpawners();
}

simulated function bool GetVehicleSpawners()
{
	local Rx_VehicleSpawnerManager VSM;

	foreach WorldInfo.AllActors(class 'Rx_VehicleSpawnerManager', VSM)
	{
		AddSpawnerManager(VSM);
	}

	if(VehicleSpawnerManagers.length <= 0)
		return false;

	return true;
}

simulated function AddSpawnerManager(Rx_VehicleSpawnerManager VSM)
{
	VehicleSpawnerManagers.AddItem(VSM);

	if(VehicleManager != None)
		Rx_VehicleManager_Coop(VehicleManager).VehicleSpawnerManagers.AddItem(VSM);
}

simulated function string GetFactoryDescription(byte teamID, string menuName, Rx_Controller rxPC) 
{
	local string factoryName;
	local string factoryStatus;
	local string outputText;
	
	if (menuName == "VEHICLES") 
	{
		factoryName = "VEHICLE REINFORCEMENT";

		if (VehicleSpawnerManagers.length <= 0 && !GetVehicleSpawners())
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

simulated function bool AreClassOptionLimited(byte teamID)
{
	if(teamID == TEAM_GDI && GDIInfantryClasses.Length <= 5)
		return true;
	if(teamID == TEAM_NOD && NodInfantryClasses.Length <= 5)
		return true;

	return false;

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

function bool PurchaseVehicle(Rx_PRI Buyer, int TeamID, int VehicleID )
{

	if(VehicleSpawnerManagers.length <= 0 && !GetVehicleSpawners())
		return false;

	return Super.PurchaseVehicle(Buyer,TeamID,VehicleID);
}

simulated function UpdateMapSpecificVehicleClasses(){
	local Rx_MapInfo MI;
	
	MI = Rx_MapInfo(WorldInfo.GetMapInfo());
	
	if(MI == none)
			return; 
	else
	{
			GDIVehicleClasses = MI.GDIVehicleArray;
			NodVehicleClasses = MI.NodVehicleArray;
	}	
}

simulated function UpdateMapSpecificInfantryClasses()
{
	local Rx_MapInfo MI; 
	
	MI = Rx_MapInfo(WorldInfo.GetMapInfo());
	
	if(MI == none)
			return; 
	else
	{

			GDIInfantryClasses = MI.GDIInfantryArray;
			NodInfantryClasses = MI.NodInfantryArray;
	}	
}

function bool DoesHaveRepairGun( class<UTFamilyInfo> inFam )
{
	local class<Rx_Weapon> WeaponLoadout;
	local class<Rx_InventoryManager> InvManager;

	InvManager = class<Rx_FamilyInfo>(inFam).default.InvManagerClass;

	foreach InvManager.default.PrimaryWeapons(WeaponLoadout)
	{
		if(class<Rx_Weapon_RepairGun>(WeaponLoadout) != None)
			return true;
	}

	return false;	
}

simulated function bool DoesClassExist( byte TeamID, int ClassNumber)
{
	if(TeamID == TEAM_GDI)
		return ClassNumber <= GDIInfantryClasses.Length - 1;

	else
		return ClassNumber <= NodInfantryClasses.Length - 1;
}

simulated function bool AirdropAvailable(PlayerreplicationInfo pri)
{
	return false;
}