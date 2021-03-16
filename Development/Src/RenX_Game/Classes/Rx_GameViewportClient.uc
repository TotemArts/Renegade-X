class Rx_GameViewportClient extends UTGameViewportClient dependsOn(Rx_Jukebox);

var Rx_GFXFrontEnd FrontEnd;
var bool bKickMessageRecently;
var bool bTakeSS;
var string FailoverURL;

function SetStartupMovie(string leaving_level, string loading_level)
{
	local Rx_SetStartupMovie movie_handler;
	movie_handler = new class'Rx_SetStartupMovie';
	movie_handler.SetStartupMovie(leaving_level, loading_level);
}

function DrawTransition(Canvas Canvas)
{
	local string MapName;
	local int pos;

	local class<UTGame> GameClass;
	local string HintMessage;

	if (Outer.TransitionType == TT_Loading)
	{
		MapName = Outer.TransitionDescription;

		// Ensure no file extension is included
		pos = InStr(MapName, ".");
		if (pos != -1)
			MapName = Left(MapName, pos);

		SetStartupMovie(string(class'Engine'.static.GetCurrentWorldInfo().GetPackageName()), MapName);





		class'Engine'.static.RemoveAllOverlays();

		// pull the map prefix off the name
		Pos = InStr(MapName,"-");
		if (Pos != -1)
		{
			MapName = right(MapName, (Len(MapName) - Pos) - 1);
		}

		// get the class represented by the GameType string
		GameClass = class<UTGame>(FindObject(Outer.TransitionGameType, class'Class'));

		if (GameClass == none)
		{
			// Some of the game types are in UTGameContent instead of UTGame. Unfortunately UTGameContent has not been loaded yet so we have to get its base class in UTGame
			// to get the proper description string.
			Pos = InStr(Outer.TransitionGameType, ".");

			if(Pos != -1)
			{
				// Repurpose HintMessage

				HintMessage = Right(Outer.TransitionGameType, Len(Outer.TransitionGameType) - Pos - 1);

				Pos = InStr(HintMessage, "_Content");

				if(Pos != -1)
				{
					HintMessage = Left(HintMessage, Pos);

					HintMessage = "UTGame." $ HintMessage;

					GameClass = class<UTGame>(FindObject(HintMessage, class'Class'));
				}

				HintMessage = "";
			}
		}

		// Map name
		//class'Engine'.static.AddOverlay(LoadingScreenMapNameFont, MapName, 0.1, 0.1, 1.0, 1.0, false);

		// Draw a random hint!
		// NOTE: We always include deathmatch hints, since they're generally appropriate for all game types
		HintMessage = LoadRandomLocalizedHintMessage(string(class'UTDeathmatch'.Name), GameClass == None ? "" : string(GameClass.Name));
		if( Len(HintMessage) > 0 )
			class'Engine'.static.AddOverlayWrapped( LoadingScreenHintMessageFont, HintMessage, 0.15, 0.8, 1.0, 1.0, 0.7 );
	}
	else
	{
		super.DrawTransition(Canvas);
	}
}

event SetProgressMessage(EProgressMessageType MessageType, string Message, optional string Title, optional bool bIgnoreFutureNetworkMessages)
{
	local string percentage;
	Super.SetProgressMessage(MessageType, Message, Title, bIgnoreFutureNetworkMessages);

	if (MessageType == PMT_DownloadProgress)
	{
		if (Title == "Success")
		{
			if (FrontEnd.DownloadProgressDialogInstance != None)
				FrontEnd.CloseDownloadProgressDialog();
		}
		else
		{
			percentage = Right(Message, 6);
			switch (Left(percentage, 1))
			{
			case "e":
				percentage = Mid(percentage, 2);
				break;
			case " ":
				percentage = Mid(percentage, 1);
				break;
			default:
				break;
			}
			Message = Left(Message, InStr(Message, ",", false, false, 5));
			if (FrontEnd.DownloadProgressDialogInstance == None)
				FrontEnd.OpenShowDownloadProgressDialog(Title, Message $ "B");
			Message = Mid(Message, 5);
			FrontEnd.UpdateDownloadProgressDialog(float(Message) * float(percentage) / 100.0, float(Message));
			FrontEnd.UpdateDownloadProgressPercentage(percentage);
		}
	}
}

/**
 * Initialize the game viewport.
 * @param OutError - If an error occurs, returns the error description.
 * @return False if an error occurred, true if the viewport was initialized successfully.
 */
event bool Init(out string OutError)
{
	local PlayerManagerInteraction PlayerInteraction;
	local int NumCustomInteractions;
	local class<UIInteraction> CustomInteractionClass;
	local UIInteraction CustomInteraction;
	local int Idx;

	//assert(Outer.ConsoleClass != None);

	ActiveSplitscreenType = DesiredSplitscreenType;

`if(`notdefined(FINAL_RELEASE))
	// Create the viewport's console.
	ViewportConsole = new(Self) class'Rx_Console' ; //Outer.ConsoleClass;
	if ( InsertInteraction(ViewportConsole) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ ViewportConsole;
		return false;
	}
`endif

	// Initialize custom interactions
	NumCustomInteractions = GetNumCustomInteractions();
	for ( Idx = 0; Idx < NumCustomInteractions; Idx++ )
	{
		CustomInteractionClass = GetCustomInteractionClass(Idx);
		CustomInteraction = new(Self) CustomInteractionClass;
		if ( InsertInteraction(CustomInteraction) == -1 )
		{
			OutError = "Failed to add interaction to GlobalInteractions array:" @ CustomInteraction;
			return false;
		}
		SetCustomInteractionObject(CustomInteraction);
	}

	assert(UIControllerClass != None);

	// Create a interaction to handle UI input.
	UIController = new(Self) UIControllerClass;
	if ( InsertInteraction(UIController) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ UIController;
		return false;
	}

	// Create the viewport's player management interaction.
	PlayerInteraction = new(Self) class'PlayerManagerInteraction';
	if ( InsertInteraction(PlayerInteraction) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ PlayerInteraction;
		return false;
	}

	// Disable the old UI system, if desired for debugging
	if( bDebugNoGFxUI )
	{
		DebugSetUISystemEnabled(TRUE, FALSE);
	}

	// create the initial player - this is necessary or we can't render anything in-game.
	return CreateInitialPlayer(OutError);
}

function NotifyConnectionError(EProgressMessageType MessageType, optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine") )
{
	local WorldInfo WI;

	if(bKickMessageRecently && Title != "Kicked") {
		ConsoleCommand("Disconnect");
		`log(`location@`showvar(MessageType)@`showvar(Message)@`showvar(Title));
		return;
	}

	if(Title == "Kicked") {
		bKickMessageRecently = true;
	}
	else if (MessageType == PMT_ConnectionFailure // PMT_SocketFailure?
		&& FailoverURL != "") {
		// Try to failover
		if (Outer.GamePlayers[0].Actor != None) {
			Outer.GamePlayers[0].Actor.ClientTravel(FailoverURL, TRAVEL_Absolute);
		}

		// Clear failover
		FailoverURL = "";
		return;
	}

	WI = class'Engine'.static.GetCurrentWorldInfo();

	`log(`location@`showvar(MessageType)@`showvar(Message)@`showvar(Title));

	if (WI.Game != None)
	{
		// Mark the server as having a problem
		WI.Game.bHasNetworkError = true;
	}

	class'UTPlayerController'.static.SetFrontEndErrorMessage(Title, Message);

	// Start quitting to the main menu
	`RxGameObject.LANBroadcast.Close();
	if (UTPlayerController(Outer.GamePlayers[0].Actor) != None)
	{
		UTPlayerController(Outer.GamePlayers[0].Actor).QuitToMainMenu();
	}
	else
	{
		// stop any movies currently playing before we quit out
		class'Engine'.static.StopMovie(true);

		// Call disconnect to force us back to the menu level
		ConsoleCommand("Disconnect");
	}
}

event PostRender(Canvas Canvas)
{
	local ByteArrayWrapper cap;
	local Rx_Controller PC;
	Super.PostRender(Canvas);

	if (bTakeSS) {
		bTakeSS = false;

		`RxEngineObject.DllCore.take_ss(Viewport, cap);
		PC = Rx_Controller(GamePlayers[0].Actor);
		if (PC != None) {
			PC.HandleSSCap(cap);
		}
	}
}

DefaultProperties
{
	LoadingScreenHintMessageFont = Font'RenxHud.Font.AgentConDB';
}