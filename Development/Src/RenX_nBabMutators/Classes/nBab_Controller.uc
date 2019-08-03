class nBab_Controller extends Rx_Controller;

/*function OpenPT(Rx_BuildingAttachment_PT PT)
{
	if( PTMenu == none || !PTMenu.bMovieIsOpen)
	{
		Rx_HUD(myHUD).PTMovie = new class'nBab_GFxPurchaseMenu';
		PTMenu = Rx_HUD(myHUD).PTMovie;
		PTMenu.SetPurchaseSystem( (WorldInfo.NetMode == NM_StandAlone || (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) ) 
			? Rx_Game(WorldInfo.Game).PurchaseSystem 
			: Rx_GRI(WorldInfo.GRI).PurchaseSystem );

		PTMenu.SetTeam(PT.GetTeamNum());
		PTMenu.SetTimingMode(TM_Real);
		PTMenu.Initialize(LocalPlayer(Player), PT);
	}
	PTUsed = PT;
}*/

function OpenPT(Rx_BuildingAttachment_PT PT)
{
	super.OpenPT(PT);
	//Rx_HUD(GetPC().myHUD).SetVisible(false);
	Rx_HUD(myHUD).SetVisible(false);
}

DefaultProperties
{
	PTMenuClass = class'nBab_GFxPurchaseMenu'
}