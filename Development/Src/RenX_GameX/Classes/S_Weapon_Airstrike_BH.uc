class S_Weapon_Airstrike_BH extends Rx_Weapon_Airstrike_Nod;

reliable server function ServerDeploy(rotator rot)
{
	local S_Airstrike as;


	if(Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime > 0 
				&& (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime < Rx_MapInfo(WorldInfo.GetMapInfo()).AirStrikeCoolDown)) 
	{
		Rx_Controller(Instigator.Controller).CTextMessage("Next Airstrike available in "$int(Rx_MapInfo(WorldInfo.GetMapInfo()).AirStrikeCoolDown - (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime))$" seconds",'Red',45);
		//Rx_Controller(Instigator.Controller).ClientMessage("Next Airstrike available in "$int(default.AirstrikeCooldown - (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime))$" seconds");
		return; 
	}	

	`log("Deploying AS at=" $ AirstrikeLocation $ " rot=" $ rot);
	as = Spawn(class'S_Airstrike', Instigator.Controller, , AirstrikeLocation, rot, , false);
	as.Init(AirstrikeType);

	// remove this weapon from inventory
	Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);	
	Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime = WorldInfo.TimeSeconds;
}


