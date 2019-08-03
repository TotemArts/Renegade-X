//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxView extends GFxUIView;

var public Rx_GFxFrontEnd MenuManager;
var public name ViewName;
var public GFxObject Parent;

function OnViewLoaded();

function InitSpawnedWidget(GFxObject WidgetComponents, GFxObject CallbackWidget )
{
	if (WidgetComponents != none) return;
	WidgetComponents = GFxClikWidget(CallbackWidget);
}