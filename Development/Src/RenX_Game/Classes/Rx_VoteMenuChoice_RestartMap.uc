class Rx_VoteMenuChoice_RestartMap extends Rx_VoteMenuChoice;

function Init()
{
	Finish();
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
