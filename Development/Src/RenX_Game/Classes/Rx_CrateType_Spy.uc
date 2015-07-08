class Rx_CrateType_Spy extends Rx_CrateType;

var int BroadcastMessageAltIndex;
var config float MinutesUntilProbabiltyIncreaseStart;
var config float ProbabilityIncreasePerMinute;
var config float MaxProbabilityIncrease;


function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "spy" `s RecipientPRI.CharClassInfo.name `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local float Probability, ProbabilityIncrease;
	Probability = Super.GetProbabilityWeight(Recipient,CratePickup);

	ProbabilityIncrease = ProbabilityIncreasePerMinute * ((CratePickup.WorldInfo.GRI.ElapsedTime / 60.0f) - MinutesUntilProbabiltyIncreaseStart);
	Probability += fclamp(ProbabilityIncrease,0,MaxProbabilityIncrease);
	
	return Probability;
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

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		(Recipient.GetTeamNum() == TEAM_NOD ?
		class'Rx_PurchaseSystem'.default.GDIInfantryClasses[Rand(14)] : 
		class'Rx_PurchaseSystem'.default.NodInfantryClasses[Rand(14)]),
		Recipient);
	RecipientPRI.SetIsSpy(true);	
}

DefaultProperties
{
	BroadcastMessageIndex = 8
	BroadcastMessageAltIndex = 7
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_Spy'
}
