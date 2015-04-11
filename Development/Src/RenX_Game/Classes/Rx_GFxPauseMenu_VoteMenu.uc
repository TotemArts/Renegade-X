class Rx_GFxPauseMenu_VoteMenu extends Rx_GFxPauseMenu_View;

var Rx_GFxPauseMenu PauseMenu;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFxPauseMenu Menu)
{
	PauseMenu = Menu;
	//GetPC().ClientMessage("" $ self $ "loaded");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName) 
	{
		default:
			//GetPC().ClientMessage("" $ self $ "-> " $ WidgetName);
			break;
	}
	return true;
}
DefaultProperties
{
}
