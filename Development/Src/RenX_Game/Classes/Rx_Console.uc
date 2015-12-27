class Rx_Console extends UTConsole;

/******************************************************************
Save for editors (which can get their own hacked up consoles) there
are some native console commands that simply need to be disabled in RenX
Most notable is the 'viewmode' command, as it breaks stealth and doesn't count as a 
'cheating' console command. 
********************************************************************/
function ConsoleCommand(string Command)
{
	if (Left(Command, 9) ~= "viewmode ")
	{
		OutputText("\n>>>" @ Command @ "<<<");
		`log("Command " $Command @ "is disabled"); 
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
		ConsoleTargetPlayer.Actor.ConsoleCommand(Command);
	}
	else if(GamePlayers.Length > 0 && GamePlayers[0].Actor != None)
	{
		// If there are any players, execute the command in the first players context.
		GamePlayers[0].Actor.ConsoleCommand(Command);
	}
	else
	{
		// Otherwise, execute the command in the context of the viewport.
		Outer.ConsoleCommand(Command);
	}
}
