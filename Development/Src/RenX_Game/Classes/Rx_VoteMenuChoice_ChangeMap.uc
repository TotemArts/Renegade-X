class Rx_VoteMenuChoice_ChangeMap extends Rx_VoteMenuChoice;

function Init()
{
	Finish();
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ " wants to change the map";
}

function Execute(Rx_Game game)
{
	game.EndRxGame("triggered", 255);
}

DefaultProperties
{
	MenuDisplayString = "Change Map"
}