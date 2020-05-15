class Rx_CrateType_RadarSweep extends Rx_CrateType;

var int BroadcastMessageAltIndex;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "Radar Sweep" `s "by" `s `PlayerLog(RecipientPRI) ;
}

function BroadcastMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if (RecipientPRI.GetTeamNum() == TEAM_NOD)
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);
	}
	else
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);
	}
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
		return super.GetProbabilityWeight(Recipient,CratePickup);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_GRI RxGRI;
	local PlayerReplicationInfo pri;

	RxGRI = Rx_GRI(Recipient.WorldInfo.GRI);

	foreach RxGRI.PRIArray(pri)
	{
		if(Rx_Pri(pri) == None || pri.GetTeamNum() != RecipientPRI.GetTeamNum() || Rx_PRI(pri).bIsScripted)	// skip if the bot is a scripted one
			continue;

		if(Controller(pri.owner).Pawn == None || VSizeSq(Recipient.Location - Controller(pri.owner).Pawn.Location) > Square(class'Rx_CommanderSupport_BeaconInfo_RadarScan'.default.AOE_Radius))
			continue;

		if(Rx_Vehicle(Controller(pri.owner).Pawn) != None)
			Rx_Vehicle(Controller(pri.owner).Pawn).SetSpotted(60.f);
		else if(Rx_Pawn(Controller(pri.owner).Pawn) != None)
			Rx_PRI(pri).SetSpotted(60.f);

		Rx_Pri(pri).SetAsTarget(1);
	}
}

DefaultProperties
{
	BroadcastMessageIndex = 24
	BroadcastMessageAltIndex = 23
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Pickup_Armour'
}

