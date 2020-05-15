//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxFrontEnd_View extends GFxUIView;


function InitSpawnedWidget(GFxObject WidgetComponents, GFxObject CallbackWidget )
{
	if (WidgetComponents != none) return;
	WidgetComponents = GFxClikWidget(CallbackWidget);
}

function SetupMenu()
{
	ActionScriptVoid("SetupMenu");
}

DefaultProperties
{

}