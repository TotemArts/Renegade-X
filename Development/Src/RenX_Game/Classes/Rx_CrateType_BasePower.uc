class Rx_CrateType_BasePower extends Rx_CrateType 
	config(Xsettings);
	
var int LastPickupTeamID,RestorePowerInSeconds;
var repnotify bool isActive;
var array<Rx_Building_Team_Internals> BuildingsPoweredDown;
var int BroadcastMessageAltIndex;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "Adv. Defense Shutdown" `s "by" `s `PlayerLog(RecipientPRI);
}

function BroadcastMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if (RecipientPRI.GetTeamNum() == TEAM_NOD)
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);

		Rx_Game(RecipientPRI.WorldInfo.Game).CTextBroadcast(TEAM_NOD,"Enemy defenses temporarily offline!",'Red',,2,true);
		Rx_Game(RecipientPRI.WorldInfo.Game).CTextBroadcast(TEAM_GDI,"Our defenses are temporarily offline!",'Red',,2,true);
	}
	else
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);

		Rx_Game(RecipientPRI.WorldInfo.Game).CTextBroadcast(TEAM_GDI,"Enemy defenses temporarily offline!",'Red',,2,true);
		Rx_Game(RecipientPRI.WorldInfo.Game).CTextBroadcast(TEAM_NOD,"Our defenses are temporarily offline!",'Red',,2,true);
	}
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local Rx_Building building;
	local bool hasDefences;
	
		foreach CratePickup.AllActors(class'Rx_Building', building) {
			if ( Rx_Building_Defense(building) != None  && (!Rx_Building_Defense(building).bDisabled || !building.IsDestroyed()))
				hasDefences = true;
		}
	if ( !hasDefences )
		return 0;
	if ( isActive == false )
		return super.GetProbabilityWeight(Recipient,CratePickup);
	else
		return 0;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_Building building;
	local Rx_Building_Team_Internals buildingTeamInternals;

	if ( Recipient.GetTeamNum() == TEAM_GDI )
	{
		`log("[Rx_CrateType_BasePower] Executing Crate Behaviour - Looking for Adv Defenses on Nod if GDI picked up the crate");
			foreach CratePickup.AllActors(class'Rx_Building', building) {
				if ( Rx_Building_Defense(building) != None ) 
				{
					buildingTeamInternals = Rx_Building_Team_Internals(building.BuildingInternals);
					if(buildingTeamInternals.TeamID == TEAM_NOD)
						if ( buildingTeamInternals.bNoPower == false )
						{
							BuildingsPoweredDown.AddItem(buildingTeamInternals);
							buildingTeamInternals.PowerLost(true);
							buildingTeamInternals.SetTimer(RestorePowerInSeconds, false, 'PowerRestore');
							`log("[Rx_CrateType_BasePower] Found Adv Defenses | Building Power Disabled " $ building.Name);
						}
				}
	}
		`log("[Rx_CrateType_BasePower] ExecuteCrateBehaviour | Looking for Adv Defenses on GDI, if Nod picked up the crate");
	} 
	else {
			foreach CratePickup.AllActors(class'Rx_Building', building) {
				if ( Rx_Building_Defense(building) != None ) 
				{
					buildingTeamInternals = Rx_Building_Team_Internals(building.BuildingInternals);
					if(buildingTeamInternals.TeamID == TEAM_GDI)
						if ( buildingTeamInternals.bNoPower == false )
						{
							BuildingsPoweredDown.AddItem(buildingTeamInternals);
							buildingTeamInternals.PowerLost(true);
							Rx_Building_AdvancedGuardTower_Internals(buildingTeamInternals).SetTimer(RestorePowerInSeconds, false, 'PowerRestore');
							`log("[Rx_CrateType_BasePower] Found Adv Defenses | Building Power Disabled " $ building.Name);
						}
				}
		}
	}
	
	LastPickupTeamID = Recipient.GetTeamNum();
	isActive = true;
	`log("[Rx_CrateType_BasePower] ExecuteCrateBehaviour | Timer Started... Waiting " $ RestorePowerInSeconds $ " seconds");
}

function RestorePower()
{
	local Rx_Building_Team_Internals building;
	
	`log("[Rx_CrateType_BasePower] RESTORE_POWER | Starting check to Restore Power to the Adv Defense that was shut down if not desstroyed");
	
	foreach BuildingsPoweredDown(building) 
		{
			`log("[Rx_CrateType_BasePower] RestorePower | Restoring Power To Building " $ building.Name);
			if ( building.isDestroyed() == false ) 
			{
				building.PowerRestore();
				`log("[Rx_CrateType_BasePower] RestorePower | Restored Power To Building " $ building.Name);
			}
		}
	
	`log("[Rx_CrateType_BasePower] Restored Power | Done");
}

DefaultProperties
{
	BroadcastMessageIndex = 26
	BroadcastMessageAltIndex = 27
	RestorePowerInSeconds = 90
	
	Pickupsound = SoundCue'Rx_Pickups.Sounds.SC_Crate_PowerOffline'
}

