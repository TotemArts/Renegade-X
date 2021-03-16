class Rx_VoteMenuChoice_RestartMap extends Rx_VoteMenuChoice;

function Init()
{
	Finish();
}

function ServerInit(Rx_Controller instigator, string param, int t)
{
	super.ServerInit(instigator, param, t);

	Rx_Game(instigator.WorldInfo.Game).CTextBroadcast(255, "A RESTART VOTE HAS BEEN STARTED", 'Red', 120,,true);
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ " wants to restart the map";
}

function Execute(Rx_Game game)
{
	game.WorldInfo.ServerTravel("?Restart",game.GetTravelType());
}

DefaultProperties
{
	MenuDisplayString = "Restart Map"
}
