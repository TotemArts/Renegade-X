class Rx_CrateType_Kamikaze extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "Kamikaze" `s "by" `s `PlayerLog(RecipientPRI);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_KamikazeSuit Suit;

	Suit = CratePickup.Spawn(class'Rx_KamikazeSuit',,,Recipient.Location);
	Suit.SetTarget(Recipient);
}

DefaultProperties
{
	PickupSound = SoundCue'Rx_Pickups.Sounds.S_Crate_Kamikaze_Cue'
	BroadcastMessageIndex = 20
}