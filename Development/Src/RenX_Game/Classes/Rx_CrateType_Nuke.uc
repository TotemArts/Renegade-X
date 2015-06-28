class Rx_CrateType_Nuke extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "nuke" `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	if (CratePickup.bNoNukeDeath)
		return 0;
	else return super.GetProbabilityWeight(Recipient,CratePickup);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_Weapon_CrateNuke Beacon;
	local Rotator spawnRotation;
	local Vector spawnLocation;

	Recipient.GetActorEyesViewPoint(spawnLocation,spawnRotation);

	Beacon = CratePickup.Spawn(class'Rx_Weapon_CrateNuke',,, CratePickup.Location,CratePickup.Rotation);
	Beacon.TeamNum = TEAM_UNOWNED;
}

DefaultProperties
{
	PickupSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeImminent_Cue'
	BroadcastMessageIndex = 3
}