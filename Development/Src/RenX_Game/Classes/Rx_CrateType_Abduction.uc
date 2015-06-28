class Rx_CrateType_Abduction extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "abduction" `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	// 0 Probability if the area directly above us isn't clear
	if (CratePickup.FastTrace(CratePickup.Location + vect(0,0,1000),CratePickup.Location + vect(0,0,256)))
		return super.GetProbabilityWeight(Recipient,CratePickup);
	else
		return 0;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_AlienAbductionBeam Beam;

	Beam = CratePickup.Spawn(class'Rx_AlienAbductionBeam',,,Recipient.Location);
	Beam.SetTarget(Recipient);
}

DefaultProperties
{
	//PickupSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeImminent_Cue'
	BroadcastMessageIndex = 12
}