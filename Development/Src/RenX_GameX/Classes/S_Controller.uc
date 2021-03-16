class S_Controller extends Rx_Controller;

function EnableCommanderMenu()
{
	
	if(VoteHandler != none || Rx_GRI(WorldInfo.GRI).bEnableCommanders == false) return; 
	
	if(Com_Menu != none ) 
	{
		DestroyOldComMenu() ;
		return; 
	}

	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander", 'Red'); 
		return; 
	}
	
	Com_Menu = new (self) class'S_CommanderMenuHandler';
	Com_Menu.Enabled(self);
}

DefaultProperties
{
	PTMenuClass = class'S_GFxPurchaseMenu'
	GDIColor    = "#3260FF"

	TeamVictorySound[0]        = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Victory_Nod'
	TeamDefeatSound[0]         = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Defeat_Nod'
}