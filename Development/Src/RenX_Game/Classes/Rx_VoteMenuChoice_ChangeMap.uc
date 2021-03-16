class Rx_VoteMenuChoice_ChangeMap extends Rx_VoteMenuChoice;

function Init()
{
	Finish();
}

function ServerInit(Rx_Controller instigator, string param, int t)
{
	super.ServerInit(instigator, param, t);

	Rx_Game(instigator.WorldInfo.Game).CTextBroadcast(255, "A CHANGE MAP VOTE HAS BEEN STARTED", 'Red', 120,,true);
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