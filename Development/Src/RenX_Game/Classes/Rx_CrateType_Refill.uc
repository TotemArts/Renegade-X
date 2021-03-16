class Rx_CrateType_Refill extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "refill" `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	if (!CanUseRefill(Recipient))
		return 0;
	else return super.GetProbabilityWeight(Recipient,CratePickup);
}

function bool CanUseRefill(Rx_Pawn Recipient)
{
	local float MaxAmmoCount;
	local float AmmoCount;
	
	MaxAmmoCount = Rx_Weapon(Recipient.weapon).MaxAmmoCount;
	AmmoCount = Rx_Weapon(Recipient.weapon).AmmoCount;	
	
	if(AmmoCount/(MaxAmmoCount/100.0) < 75.0)
	{
		loginternal(AmmoCount/(MaxAmmoCount/100.0));
		return true;	
	}
	
	if(Recipient.Health/(Recipient.HealthMax/100.0) < 75.0)
	{
		return true;	
	}
	return false;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	Recipient.PerformRefill();
}

DefaultProperties
{
	BroadcastMessageIndex = 9
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_Refill'
}
