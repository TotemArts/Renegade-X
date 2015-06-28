class Rx_CrateType_Speed extends Rx_CrateType;

var int SpeedIncreasePercent;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "speed" `s "by" `s `PlayerLog(RecipientPRI);
}

function string GetPickupMessage()
{
	return Repl(PickupMessage, "`increasepct`", SpeedIncreasePercent, false);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	Recipient.SpeedUpgradeMultiplier += SpeedIncreasePercent / 100.0;
	Recipient.UpdateRunSpeedNode();
	Recipient.SetGroundSpeed();

	`log("Increasing speed by" @ SpeedIncreasePercent / 100.0 @ "percent to " @Recipient.SpeedUpgradeMultiplier);
}

DefaultProperties
{
	BroadcastMessageIndex = 11
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_Refill'

	SpeedIncreasePercent = 10
}
