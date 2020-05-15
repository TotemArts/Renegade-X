class Rx_CrateType_SuperMoney extends Rx_CrateType 
	config(XSettings);

var config float MinutesToGiveSmallSum;
var config float ProbabilityIncreaseWhenPowerPlantDestroyed;
var config float ProbabilityIncreaseWhenRefineryDestroyed;

var transient int credits;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "super money" `s credits `s "by" `s `PlayerLog(RecipientPRI);
}

function string GetPickupMessage()
{
	return Repl("You found a Super Money crate and have awarded `credsum` credits to each teammate!", "`credsum`", credits, false);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local Rx_Building building;
	local float Probability;
	Probability = Super.GetProbabilityWeight(Recipient,CratePickup);
	
	ForEach CratePickup.AllActors(class'Rx_Building',building)
	{
		if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_GDI_PowerFactory(building) != none  && Rx_Building_GDI_PowerFactory(building).IsDestroyed()) || 
			(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_Nod_PowerFactory(building) != none  && Rx_Building_Nod_PowerFactory(building).IsDestroyed()))
		{
			Probability += ProbabilityIncreaseWhenPowerPlantDestroyed;
		}
		if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_GDI_MoneyFactory(building) != none  && Rx_Building_GDI_MoneyFactory(building).IsDestroyed()) || 
			(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_Nod_MoneyFactory(building) != none  && Rx_Building_Nod_MoneyFactory(building).IsDestroyed()))
		{
			Probability += ProbabilityIncreaseWhenRefineryDestroyed;
		}
	}

	LogInternal("SuperMoney GetProbabilityWeight returning " @ Probability);
	return Probability;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	credits = ((Rand(2)+1) * 100) + (Rand(4) * 50) + 50 + (Rand(3) * 50);
	RecipientPRI.AddCredits(credits);
	Recipient.ClientMessage("You found a Super Money crate, and have shared it's worth with your team!");
	GiveCreditsToAll(Recipient);
}

reliable server function GiveCreditsToAll(Rx_Pawn Sender)
{
	local byte teamNum;
	local Controller plyrController;
	local Controller c;
	
	// How many credits to give to each player on the team
	credits = (25 + (Rand(2)) * 100) + (Rand(3) * 50) + (Rand(3) * 25);
	teamNum = Sender.GetTeamNum();
	plyrController = Sender.Controller;
	
	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'Controller', c)
	{
		if (c.GetTeamNum() == teamNum && Rx_PRI(c.PlayerReplicationInfo) != None && c != plyrController )
		{
			if (PlayerController(c) != None)
			{
				//Recipient.CTextMessage(GetPickupMessage(),'LightGreen',90);
				Rx_Controller(c).CTextMessage(Rx_PRI(Sender.PlayerReplicationInfo).PlayerName $ " found a super money crate and has shared " $ credits $ " credits with you.",'LightGreen',90);
				Rx_PRI(c.PlayerReplicationInfo).AddCredits(credits);
				PlayAudio(Rx_PRI(c.PlayerReplicationInfo));
			}
		}
	}
}

simulated function PlayAudio(Rx_PRI pri)
{
	pri.PlaySound(PickupSound);
}

DefaultProperties
{
	BroadcastMessageIndex = 4
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_Money'
}

