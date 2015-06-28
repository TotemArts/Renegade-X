class Rx_CrateType_TimeBomb extends Rx_CrateType;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "timebomb" `s "by" `s `PlayerLog(RecipientPRI);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Rx_Weapon_DeployedTimedC4 C4;
	local Rotator spawnRotation;
	local Vector spawnLocation;

	Recipient.GetActorEyesViewPoint(spawnLocation,spawnRotation);
	spawnRotation = rotator(Normal(vector(spawnRotation) * vect(1,1,0))); // Flatten, we only care about x/y direction
	spawnLocation -= vector(spawnRotation) * 10; // Place behind the eyes to not interfere with first person firing.

	C4 = CratePickup.Spawn(class'Rx_Weapon_DeployedTimedC4',,, spawnLocation,spawnRotation + rot(16384,-16384,0));
	C4.Landed(vect(0,0,1),Recipient);
	C4.InstigatorController = Recipient.Controller;
	C4.SetDamageAll(true);
	C4.TeamNum = Recipient.GetTeamNum();
}

DefaultProperties
{
	BroadcastMessageIndex = 13
	PickupSound = none
}
