class Rx_Game_MainMenu extends Rx_Game;

event InitGame( string Options, out string ErrorMessage )
{
	super.InitGame(Options, ErrorMessage);

	LANBroadcast.start(false);
}

function StartMatch()
{
}

DefaultProperties
{
	//bQuickStart = true;
	GameType = 0 // 0 = Rx_Game_MainMenu
}
