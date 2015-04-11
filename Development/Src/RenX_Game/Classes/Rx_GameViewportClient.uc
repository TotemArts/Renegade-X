class Rx_GameViewportClient extends UTGameViewportClient;

function DrawTransition(Canvas Canvas)
{

	// if we are doing a loading transition, set up the text overlays for the loading movie
	if (Outer.TransitionType == TT_Loading)
	{
	
	}
	else 
	{
		super.DrawTransition(Canvas);
	}
}

DefaultProperties
{
}