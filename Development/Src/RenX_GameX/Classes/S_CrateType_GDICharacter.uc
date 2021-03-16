class S_CrateType_GDICharacter extends Rx_CrateType_EpicCharacter;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "GDI character" `s RecipientPRI.CharClassInfo.name `s "by" `s `PlayerLog(RecipientPRI);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		class'Rx_PurchaseSystem'.default.GDIInfantryClasses[RandRange(7,class'Rx_PurchaseSystem'.default.GDIInfantryClasses.Length-1)],
		Recipient);
}

DefaultProperties
{
	BroadcastMessageIndex = 30
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_CharacterChange'
}

