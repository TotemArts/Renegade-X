class Rx_GFxPauseMenu_FadeSystem extends GFxMoviePlayer;

var GFxObject FadeScreen;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

	FadeScreen = GetVariableObject("FadeScreen");

	AddCaptureKey('XboxTypeS_A');
	AddCaptureKey('XboxTypeS_Start');
	AddCaptureKey('Enter');

    return true;
}

function ShowSystem()
{
	FadeScreen.GotoAndPlay("open");
}
function HideSystem()
{
	FadeScreen.GotoAndPlay("close");
}
function OnCloseAnimationComplete()
{
//    Rx_GFXHudWrapper(GetPC().MyHUD).FadeScreenClose();
}

DefaultProperties
{
    bDisplayWithHudOff=TRUE
    bEnableGammaCorrection=FALSE
	bPauseGameWhileActive=FALSE
	//bCaptureInput=true
}
