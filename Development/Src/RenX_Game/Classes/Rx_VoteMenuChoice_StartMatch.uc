class Rx_VoteMenuChoice_StartMatch extends Rx_VoteMenuChoice;

function Init()
{
	Finish();
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ " wants to start the match";
}

function Execute(Rx_Game Game)
{
	if (Game.bIsClanWars)
		Game.MatchInfo.bNextMapIsLive = true;
	Game.EndRxGame("triggered", 255);
}

DefaultProperties
{
	MenuDisplayString = "Start Match"
	TimeLeft=30
}
