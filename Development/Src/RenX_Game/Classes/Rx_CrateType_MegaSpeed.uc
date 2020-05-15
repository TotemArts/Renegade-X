class Rx_CrateType_MegaSpeed extends Rx_CrateType 
    config(XSettings);

var Rx_CrateType_MegaSpeed_Helper CrateHelper;
var int BroadcastMessageAltIndex;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
    return "GAME" `s "Crate;" `s "Mega Speed" `s "by" `s `PlayerLog(RecipientPRI);
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

function string GetPickupMessage()
{
    return "You channel your inner Neo!";
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if ( CrateHelper == None )
		CrateHelper = CratePickup.Spawn(class'Rx_CrateType_MegaSpeed_Helper');
	
	if ( CrateHelper != None )
	{
		CrateHelper.RestoreNormalSpeed(Recipient);
		Recipient.SpeedUpgradeMultiplier = 1.65f;
		Recipient.UpdateRunSpeedNode();
		Recipient.SetGroundSpeed();
	}
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	return Super.GetProbabilityWeight(Recipient, CratePickup);
}

DefaultProperties
{
    BroadcastMessageIndex = 28
	BroadcastMessageAltIndex = 29
}