class Rx_CrateType_Teleport extends Rx_CrateType;

var bool bSearchedForCTM;
var Rx_CrateTeleportManager MyTeleportManager;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "teleportation" `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local Rx_CrateTeleportManager CTM;

	// 0 Probability if the area directly above us isn't clear
	if(!bSearchedForCTM)
	{
		foreach Recipient.AllActors(class'Rx_CrateTeleportManager', CTM)
		{
			if(CTM != None)
			{
				MyTeleportManager = CTM;

				if(MyTeleportManager.PickupSound != None)
					PickupSound = MyTeleportManager.PickupSound;
			}
		}

		bSearchedForCTM = true;
	}

	if(MyTeleportManager != None && MyTeleportManager.bIsEnabled)
		return super.GetProbabilityWeight(Recipient,CratePickup);
	else
		return 0;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local int i;
	local Vector NewLoc;
	local Rotator NewRot;

	if(MyTeleportManager.DestinationList.Length > 1)
		i = Rand(MyTeleportManager.DestinationList.Length);

	else
		i = 0;

	NewLoc = MyTeleportManager.DestinationList[i].Location;
	NewRot = MyTeleportManager.DestinationList[i].Rotation;	

	Recipient.PlayTeleportEffect(false, true);
	Recipient.SetLocation(NewLoc);
	Recipient.SetRotation(NewRot);
	Recipient.SetViewRotation(NewRot);
	Recipient.ClientSetRotation(NewRot);
	Recipient.PlayTeleportEffect(true, true);
}

function SendLocalMessage(Rx_Controller Recipient)
{
	Recipient.CTextMessage(GetPickupMessage(),'LightGreen',90);
}

function string GetPickupMessage()
{
	if(MyTeleportManager != None && MyTeleportManager.PickupMessage != "")
		return MyTeleportManager.PickupMessage;

	else
		return PickupMessage;

}

DefaultProperties
{
	//PickupSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeImminent_Cue'
	BroadcastMessageIndex = 21
}