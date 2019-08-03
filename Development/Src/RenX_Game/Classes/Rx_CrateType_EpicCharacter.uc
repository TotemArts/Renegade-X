class Rx_CrateType_EpicCharacter extends Rx_CrateType;

var config float ProbabilityIncreaseWhenInfantryProductionDestroyed;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "hero" `s RecipientPRI.CharClassInfo.name `s "by" `s `PlayerLog(RecipientPRI);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		(Recipient.GetTeamNum() == TEAM_GDI ?
		class'Rx_FamilyInfo_GDI_Sydney_Suit' : 
		class'Rx_FamilyInfo_Nod_Raveshaw_Mutant'),
		Recipient);
}

DefaultProperties
{
	BroadcastMessageIndex = 19
	PickupSound = SoundCue'Rx_Pickups.Sounds.S_Crate_EpicCharacter_Cue'
}
