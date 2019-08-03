class Rx_CrateType_DamageResistance extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "Damage Resistance" `s "by" `s `PlayerLog(RecipientPRI) ;
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
		return super.GetProbabilityWeight(Recipient,CratePickup);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if(Rx_Controller(Recipient.Controller) != none) 
		Rx_Controller(Recipient.Controller).AddActiveModifier(class'Rx_StatModifierInfo_Crate_Defense');
	else if(Rx_Bot(Recipient.Controller) != none) 
		Rx_Bot(Recipient.Controller).AddActiveModifier(class'Rx_StatModifierInfo_Crate_Defense');
}

DefaultProperties
{
	BroadcastMessageIndex = 17
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Pickup_Armour'
}
