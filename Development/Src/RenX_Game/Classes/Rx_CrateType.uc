class  Rx_CrateType extends Object
	abstract
	transient
	config(XSettings);

var config float BaseProbability; // 1 = Average probability, 2 = twice average, 0.5 = half average, 0 = never
var config int StartSpawnTime; // Time at which crate becomes possible in seconds

var localized string PickupMessage;
var int BroadcastMessageIndex;

var SoundCue PickupSound;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "by" `s `PlayerLog(RecipientPRI);
}

function BroadcastMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	CratePickup.BroadcastLocalizedMessage(CratePickup.MessageClass,BroadcastMessageIndex,RecipientPRI);
}

function SendLocalMessage(Rx_Controller Recipient)
{
	Recipient.clientmessage(GetPickupMessage());
}

function string GetPickupMessage()
{
	return PickupMessage;
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	return BaseProbability;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup);

DefaultProperties
{
}
