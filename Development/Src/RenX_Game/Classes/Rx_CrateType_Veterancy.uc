class Rx_CrateType_Veterancy extends Rx_CrateType;

var const int VPAmount;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "veterancy" `s "by" `s `PlayerLog(RecipientPRI) `s "amount" `s VPAmount;
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	if (Rx_PRI(Recipient.Controller.PlayerReplicationInfo).VRank >= ArrayCount(class'Rx_Game'.default.VPMilestones))
		return 0;
	else
		return super.GetProbabilityWeight(Recipient,CratePickup);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	//
	if(Rx_Controller(Recipient.Controller) != none){
		Rx_Controller(Recipient.Controller).DisseminateVPString("[Veterancy Crate]&" $ VPAmount $ "&");;
	}
	else
		RecipientPRI.AddVP(VPAmount);
}

DefaultProperties
{
	VPAmount = 20
	BroadcastMessageIndex = 16
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_Veterancy'
}
