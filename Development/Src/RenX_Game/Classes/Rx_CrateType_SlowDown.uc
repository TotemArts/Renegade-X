class Rx_CrateType_SlowDown extends Rx_CrateType 
    config(XSettings);

var Rx_CrateType_SlowDown_Helper CrateHelper;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
    return "GAME" `s "Crate;" `s "Slow Down" `s "by" `s `PlayerLog(RecipientPRI);
}

function string GetPickupMessage()
{
    return "Someone stuck some glue on your shoes, slowing you down!";
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if ( CrateHelper == None )
		CrateHelper = CratePickup.Spawn(class'Rx_CrateType_SlowDown_Helper');
	
	if ( CrateHelper != None )
	{
		CrateHelper.RestoreNormalSpeed(Recipient);
		Recipient.SpeedUpgradeMultiplier = 0.85f;
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
    BroadcastMessageIndex = 25
}