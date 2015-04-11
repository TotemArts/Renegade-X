class Rx_GFxUITest extends GFxMoviePlayer
    config(Menu);


//	{label:"MAP", data:"SkirmishMap"},
//	{label:"GAME", data:"SkirmishGame"}
//	{label:"VIDEO", data:"SettingsVideo"},
//	{label:"AUDIO", data:"SettingsAudio"},
//	{label:"INPUT", data:"SettingsInput"}
//	{label:"SERVER BROWSER", data:"MultiplayerServer"},
//	{label:"FILTER", data:"MultiplayerFilter"},
//	{label:"HOST", data:"MultiplayerHost"}
//	{label:"TUTORIALS", data:"ExtrasTutorials"},
//	{label:"DATABASE", data:"ExtrasDatabase"},
//	{label:"CREDITS", data:"ExtrasCredits"}

var GFxObject CurrentSelectedButton;
var GFxClikWidget MainMenuView;
var GFxClikWidget MainMenuBar;

var Rx_GFxFrontEnd_Skirmish SkirmishMapView;

/** Called on start **/
function bool Start (optional bool StartPaused = false)
{
    // CaptureBindIndex = -1;

    super.Start();
    Advance(0);

    SetAlignment(Align_Center);
    SetViewScaleMode(SM_ShowAll);

    return true;
}


/** Called when a CLIK Widget is initialized **/
function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    GetPC().ClientMessage("Rx_GFxUITest::WidgetInit: " $WidgetName $" : " $WidgetPath $" : " $Widget);
    switch (WidgetName)
    {
        case 'MainMenuBar':
            MainMenuBar = GFxClikWidget(Widget);
            SetUpDataProvider(MainMenuBar);
            MainMenuBar.SetFloat("selectedIndex", -1);
            MainMenuBar.AddEventListener('CLIK_change', OnMainMenuBarChange);
            break;
        case 'MainMenuView':
            MainMenuView = GFxClikWidget(Widget);
            if (MainMenuBar != none && MainMenuBar.GetFloat("selectedIndex") == -1)
                MainMenuView.SetVisible(false);
            break;
        case 'SkirmishView':
            GetPC().ClientMessage("=======================================ssasd==");
            SkirmishMapView = Rx_GFxFrontEnd_Skirmish(Widget);
            GetPC().ClientMessage("CurrentView? " $SkirmishMapView.GetObject("currentView"));
            GetPC().ClientMessage("CurrentView name? " $SkirmishMapView.GetObject("currentView").GetString("_name"));
            SetWidgetPathBinding(SkirmishMapView, WidgetPath);
            //SkirmishMapView.OnViewLoaded();

//            if (MainMenuView == none)
//            {
//                MainMenuView = GFxUDKFrontEnd_MainMenu(Widget);
//                ConfigureView(MainMenuView, WidgetName, WidgetPath);
//
//                // Currently here because need to ensure MainMenuView has loaded.
//                ConfigureTargetView(MainMenuView);
//                bResult = true;
//            }
            break;
        default:
            break;
    }
    return true;
}


/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
    local GFxObject DataProvider;
    local GFxObject TempData;

    DataProvider = CreateArray();
    switch(Widget)
    {
        case (MainMenuBar):
            TempData = CreateObject("Object");
            TempData.SetString("label", Caps("Skirmish"));
            TempData.SetString("data", "SkirmishMenu");
            DataProvider.SetElementObject(0, TempData);

            TempData = CreateObject("Object");
            TempData.SetString("label", Caps("Multiplayer"));
            TempData.SetString("data", "MultiplayerMenu");
            DataProvider.SetElementObject(1, TempData);

            TempData = CreateObject("Object");
            TempData.SetString("label", Caps("Settings"));
            TempData.SetString("data", "SettingsMenu");
            DataProvider.SetElementObject(2, TempData);

            TempData = CreateObject("Object");
            TempData.SetString("label", Caps("Extras"));
            TempData.SetString("data", "ExtrasMenu");
            DataProvider.SetElementObject(3, TempData);

            TempData = CreateObject("Object");
            TempData.SetString("label", Caps("Exit"));
            DataProvider.SetElementObject(4, TempData);
            break;
        default:
            return;
    }
    Widget.SetObject("dataProvider", DataProvider);
}


function OnMainMenuBarChange(GFxClikWidget.EventData ev)
{
    if (!MainMenuView.GetBool("visible") && ev.index != 4)
    {
        MainMenuView.SetVisible(true);
    }
    CurrentSelectedButton = ev._this.GetObject("renderer");
}

defaultproperties
{

    WidgetBindings.Add((WidgetName="MainMenuView",WidgetClass=class'GFxClikWidget'))
    WidgetBindings.Add((WidgetName="MainMenuBar",WidgetClass=class'GFxClikWidget'))
    WidgetBindings.Add((WidgetName="SkirmishView",WidgetClass=class'Rx_GFxFrontEnd_Skirmish'))

    bDisplayWithHudOff=TRUE
    //MovieInfo=SwfMovie'RenXUITest.RenXUITest'
    bPauseGameWhileActive=FALSE
    bCaptureInput=true
}