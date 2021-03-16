class Rx_TeamManager extends Object;

static function SetTeams() {
	// Set the teams for the next round

	`RxEngineObject.ClearTeams(); // clear up teams before restructuring

	switch (`RxGameObject.TeamMode)
	{
	case 0: // Static
		RetainTeamsNextMatch();
		break;
	case 1: // Swap
		SwapTeamsNextMatch();
		break;
	case 2: // Random swap
		if (Rand(2) != 0)
			SwapTeamsNextMatch();
		break;
	case 3: // Shuffle
		ShuffleTeamsNextMatch();
		break;
	case 4: // Traditional (do nothing)
		break;
	case 5: // Traditional + free swaps (do nothing)
		break;
	case 6: // Random Shuffle
		RandomShuffleTeamsNextMatch();
		break;
	case 7: // TODO: Implement leaderboard-based shuffle
		break;
	default: // Invalid value; do nothing
		break;
	}
}

/** Shuffle Algorithms */

private static function ShuffleTeamsNextMatch()
{
	local Array<Rx_Controller> Team1, Team2, All;
	local float Team1Score, Team2Score;
	local int GDICount, NodCount;
	local Rx_Controller PC, Highest;
	local Rx_Mutator Rx_Mut;

	LogInternal("autobal: shuffle" );

	Rx_Mut = `RxGameObject.GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBeforeTeamShuffling();
	}		

	if (Rx_Mut != None)
	{
		if(Rx_Mut.ShuffleTeamsNextMatch())
			return;
	}		

	// Gather all Human Players
	foreach `WorldInfoObject.AllControllers(class'Rx_Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
			All.AddItem(PC);
	}

	// Sort them all into 2 teams.
	while (All.Length > 0)
	{
		Highest = None;
		foreach All(PC)
		{
			if (Highest == None)
				Highest = PC;
			else if (Rx_PRI(PC.PlayerReplicationInfo).OldRenScore > Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore)
				Highest = PC;
		}

		All.RemoveItem(Highest);

		if (Team1Score <= Team2Score)
		{
			Team1.AddItem(Highest);
			Team1Score += Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore;
		}
		else
		{
			Team2.AddItem(Highest);
			Team2Score += Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore;
		}

		// If the small team + the rest is less than the larger team, then place all remaining players in the small team.
		if (Team1.Length >= Team2.Length + All.Length)
		{
			// Dump the rest in Team2.
			foreach All(PC)
				Team2.AddItem(PC);
			break;
		}
		else if (Team2.Length >= Team1.Length + All.Length)
		{
			// Dump the rest in Team1.
			foreach All(PC)
				Team1.AddItem(PC);
			break;
		}
	}

	// Figure out which team will be which faction. Just do the one that moves the least.
	foreach Team1(PC)
	{
		if (PC.PlayerReplicationInfo.Team.TeamIndex == 0)
			++GDICount;
		else
			++NodCount;
	}
	if (GDICount >= NodCount)
	{
		// Team 1 go GDI, Team 2 go Nod
		foreach Team1(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
	}
	else
	{
		// Team 1 go Nod, Team 2 go GDI
		foreach Team1(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
	}

	if (Rx_Mut != None)
	{
		Rx_Mut.OnAfterTeamShuffling();
	}	

	// Terribly unoptimized, but done.

}

private static function RandomShuffleTeamsNextMatch()
{
	local Array<Rx_Controller> Team1, Team2, All;
	local int RandomTeam;
	local int i;
	local Rx_Controller PC;
	local Rx_Mutator Rx_Mut;

	LogInternal("autobal: random shuffle" );

	Rx_Mut = `RxGameObject.GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBeforeTeamShuffling();
	}		

	if (Rx_Mut != None)
	{
		if(Rx_Mut.ShuffleTeamsNextMatch())
			return;
	}		

	// Gather all Human Players
	foreach `WorldInfoObject.AllControllers(class'Rx_Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
			All.AddItem(PC);
	}

	// Sort them all into 2 teams.
	while (All.Length > 0)
	{
         i = Rand(All.Length);
         if(RandomTeam == 0)
         {
            Team1.AddItem(All[i]);
            RandomTeam = 1;
           // LogInternal("Added"@All[i].PlayerReplicationInfo.PlayerName@"to Team1");
         } 
         else            
         {
            Team2.AddItem(All[i]);
            RandomTeam = 0;
           // LogInternal("Added"@All[i].PlayerReplicationInfo.PlayerName@"to Team2");
         } 
         All.RemoveItem(All[i]);
		
	}

	// Figure out which team will be which faction. It's random.
	if (Rand(2) != 1)
	{
		// Team 1 go GDI, Team 2 go Nod
		foreach Team1(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
	}
	else
	{
		// Team 1 go Nod, Team 2 go GDI
		foreach Team1(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
	}

	if (Rx_Mut != None)
	{
		Rx_Mut.OnAfterTeamShuffling();
	}	

	// Terribly unoptimized, but done.

}

private static function RetainTeamsNextMatch()
{
	local Controller PC;

	foreach `WorldInfoObject.AllControllers(class'Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI)
				`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
			else if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD)
				`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
		}
	}
}

private static function SwapTeamsNextMatch()
{
	local Controller PC;

	foreach `WorldInfoObject.AllControllers(class'Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI)
				`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
			else if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD)
				`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
		}
	}
}

