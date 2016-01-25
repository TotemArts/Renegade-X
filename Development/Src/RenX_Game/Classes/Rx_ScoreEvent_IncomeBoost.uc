class Rx_ScoreEvent_IncomeBoost extends Rx_ScoreEvent;

var const float CreditsAmount;

function ScoreReached(Rx_TeamInfo Team)
{
	local Rx_Controller PC;
	foreach class'Engine'.static.GetCurrentWorldInfo().AllControllers(class'Rx_Controller', PC)
		if (Rx_PRI(PC.PlayerReplicationInfo).Team == Team)
			Rx_PRI(PC.PlayerReplicationInfo).AddCredits(CreditsAmount);
}

DefaultProperties
{
	ScoreRequired = 5000;
	CreditsAmount = 1000.0;
}
