class Rx_VoteMenuChoice_RemoveBots extends Rx_VoteMenuChoice;

var string ConsoleDisplayText;

var int BotsToTeam;
var int Amount; // 0 for all bots

var int CurrentTier;

function array<string> GetDisplayStrings()
{
	local array<string> ret;
	local GameReplicationInfo GRI;

	GRI = Handler.PlayerOwner.WorldInfo.GRI;

	if (CurrentTier == 0)
	{
		ret.AddItem("1|To " $Rx_TeamInfo(GRI.Teams[0]).GetHumanReadableName());
		ret.AddItem("2|To " $Rx_TeamInfo(GRI.Teams[1]).GetHumanReadableName());
		ret.AddItem("3|From both Teams");
	}
	else if (CurrentTier == 1)
	{
		ret.AddItem("1|Remove all");
		ret.AddItem("2|Specify amount");
	}

	return ret;
}

function KeyPress(byte T)
{
	if (CurrentTier == 0)
	{
		// accept 1, 2, 3
		if (T == 1 || T == 2 || T == 3)
		{
			BotsToTeam = T;
			CurrentTier = 1;
		}
	}
	else if (CurrentTier == 1)
	{
		// accept 1, 2
		if (T == 1 || T == 2)
		{
			if (T == 2)
			{
				CurrentTier = 2;
				// enable console
				Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
			}
			else
			{
				Finish();
			}
		}
	}
}

function InputFromConsole(string text)
{
	local string s;

	s = Right(text, Len(text) - 9);
	Amount = int(s);

	Finish();
}

function bool GoBack()
{
	switch (CurrentTier)
	{
	case 0:
		return true; // kill this submenu
	case 1:
		CurrentTier = 0;
		return false;
	case 2:
		CurrentTier = 1;
		return false;
	}
}

function string SerializeParam()
{
	return string(BotsToTeam) $ "\n" $ string(Amount);
}

function DeserializeParam(string param)
{
	local int i;

	i = InStr(param, "\n");
	BotsToTeam = int(Left(param, i));
	param = Right(param, Len(param) - i - 1);
	Amount = int(param);
}

function string ComposeTopString()
{
	local string str;

	if (Amount > 0) str = string(Amount);
	else str = "all";

	str = super.ComposeTopString() $ " wants to remove " $ str $ " bots from ";

	switch (BotsToTeam)
	{
	case 1:
		str = str $ "<font color='" $GDIColor $"'>"$TeamTypeToString(0)$"</font>";
		break;
	case 2:
		str = str $ "<font color='" $NodColor $"'>"$TeamTypeToString(1)$"</font>";
		break;
	case 3:
		str = str $ "<font color='" $HostColor $"'>"$"both teams"$"</font>";
		break;
	}


	return str;
}

function string ParametersLogString()
{
	local string teamPram;
	switch (BotsToTeam)
	{
	case 1:
		teamPram = TeamTypeToString(0);
		break;
	case 2:
		teamPram = TeamTypeToString(1);
		break;
	case 3:
		teamPram = "Both";
		break;
	}
	return "team" `s teamPram `s "amount" `s Amount;
}

function Execute(Rx_Game game)
{
	local int i;
	local UTBot bot;
	local bool killed;

	if (BotsToTeam == 3 && Amount == 0)
	{
		game.KillBots();
		return;
	}

	if (BotsToTeam == 1 || BotsToTeam == 3)
	{
		for (i = 0; i < Amount; i++)
		{
			killed = false;
			foreach game.AllActors(class'UTBot', bot)
			{
				if(Rx_Bot_Scripted(bot) != None)
					continue;

				if (bot.PlayerReplicationInfo.Team.TeamIndex == 0)
				{
					game.KillBot(bot);
					killed = true;
					break;
				}
			}
		
			if (!killed) break; // run out of bots
		}
	}

	if (BotsToTeam == 2 || BotsToTeam == 3)
	{
		for (i = 0; i < Amount; i++)
		{
			killed = false;
			foreach game.AllActors(class'UTBot', bot)
			{
				if(Rx_Bot_Scripted(bot) != None)
					continue;

				if (bot.PlayerReplicationInfo.Team.TeamIndex == 1)
				{
					game.KillBot(bot);
					killed = true;
					break;
				}
			}
		
			if (!killed) break; // run out of bots
		}
	}
}

DefaultProperties
{
	MenuDisplayString = "Remove Bots"
	ConsoleDisplayText = "Amount of bots: "
}
