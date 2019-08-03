class Rx_Console extends UTConsole;

var array<string> BannedCommands; 

/******************************************************************
Save for editors (which can get their own hacked up consoles) there
are some native console commands that simply need to be disabled in RenX
Most notable is the 'viewmode' command, as it breaks stealth and doesn't count as a 
'cheating' console command. 
********************************************************************/
function ConsoleCommand(string Command)
{	
	
if (isBannedCommand(Command)) 
	{
		`log("Bad Command Input") ; 
		return; 
	}
	
	
	// Store the command in the console history.
	if ((HistoryTop == 0) ? !(History[MaxHistory - 1] ~= Command) : !(History[HistoryTop - 1] ~= Command))
	{
		// ensure uniqueness
		PurgeCommandFromHistory(Command);

		History[HistoryTop] = Command;
		HistoryTop = (HistoryTop+1) % MaxHistory;

		if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
			HistoryBot = (HistoryBot+1) % MaxHistory;
	}
	HistoryCur = HistoryTop;

	// Save the command history to the INI.
	SaveConfig();

	OutputText("\n>>>" @ Command @ "<<<");

	if(ConsoleTargetPlayer != None)
	{
		// If there is a console target player, execute the command in the player's context.

		if (Left(Command, 1) == ".")
			Rx_Controller(ConsoleTargetPlayer.Actor).SendRconOutCommand(Mid(Command, 1));
		else if (Left(Command, 1) == "/")
			Rx_Controller(ConsoleTargetPlayer.Actor).AdminRcon(Mid(Command, 1));
		else
			ConsoleTargetPlayer.Actor.ConsoleCommand(Command);
	}
	else if(GamePlayers.Length > 0 && GamePlayers[0].Actor != None)
	{
		// If there are any players, execute the command in the first players context.

		if (Left(Command, 1) == ".")
			Rx_Controller(GamePlayers[0].Actor).SendRconOutCommand(Mid(Command, 1));
		else if (Left(Command, 1) == "/")
			Rx_Controller(GamePlayers[0].Actor).AdminRcon(Mid(Command, 1));
		else
			GamePlayers[0].Actor.ConsoleCommand(Command);
	}
	else
	{
		// Otherwise, execute the command in the context of the viewport.
		Outer.ConsoleCommand(Command);
	}
}

function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
	// Don't allow console commands when in seamless travel.
	if ( ConsoleTargetPlayer != None && ConsoleTargetPlayer.Actor.WorldInfo.IsInSeamlessTravel() )
	{
		return false;
	}

	if ( Event == IE_Pressed )
	{
		bCaptureKeyInput = false;

		if ( Key == ConsoleKey )
		{
			GotoState('Open');

			// this already gets set in Open.BeginState, but no harm in being explicit
			bCaptureKeyInput = true;
		}
		else if ( Key == TypeKey )
		{
			GotoState('Typing');
			// this already gets set in Typing.BeginState, but no harm in being explicit
			bCaptureKeyInput = true;
		}
	}

	return bCaptureKeyInput;
}

function bool isBannedCommand(coerce string CString)
{
	local int i; 
	for(i=0;i < BannedCommands.Length; i++)
	{
			if(inStr(Caps(CString), Caps(BannedCommands[i]) ) != -1) return true; 
			else
			continue; 
	}
	return false; 
}

function AddBannedCommand(string CommandName)
{
	BannedCommands.AddItem(CommandName);
	`log("added banned command:"@CommandName);
}

DefaultProperties 
{
	BannedCommands(0) = "PrevViewMode"; 
	BannedCommands(1) = "NextViewMode"; 
	BannedCommands(2) = "Viewmode"; 
	BannedCommands(3) = "EnableCheats";
	BannedCommands(4) = "FogDensity";
	//BannedCommands(4) = "pktlag";
	//BannedCommands(5) = "pktloss";
	
}
