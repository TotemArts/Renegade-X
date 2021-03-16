class Rx_VoteMenuChoice_AddBots extends Rx_VoteMenuChoice
	config(RenegadeXAISetup);

var string ConsoleDisplayText;

var int BotsToTeam;
var int Amount;
var int Skill;

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
		ret.AddItem("3|To both Teams");
	}
	else if (CurrentTier == 2)
	{
		ret.AddItem("1|Skill 1");
		ret.AddItem("2|Skill 2");
		ret.AddItem("3|Skill 3");
		ret.AddItem("4|Skill 4");
		ret.AddItem("5|Skill 5");
		ret.AddItem("6|Skill 6");
		ret.AddItem("7|Skill 7");
		ret.AddItem("8|Skill 8");

		if(IsCheatBotEnabled())
			ret.AddItem("9|Tiberium-blessed Skill");
	}

	return ret;
}

unreliable server function bool IsCheatBotEnabled()
{
	return Rx_PRI(Handler.PlayerOwner.PlayerReplicationInfo).bCanRequestCheatBots;
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

			// enable console
			Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		}
	}
	else if (CurrentTier == 2)
	{
			// accept 1 - 9 if cheater bots are enabled
		if(IsCheatBotEnabled())
		{
			if (T >= 1 && T <= 9)
			{
				Skill = T;

				Finish();
			}
		}
			// accept 1 - 8
		else
		{	
			if (T >= 1 && T <= 8)
			{
				Skill = T;

				Finish();
			}
		}
	}
}

function InputFromConsole(string text)
{
	local string s;

	s = Right(text, Len(text) - 9);
	Amount = Min(int(s), 128); // do not go over 128 for now

	if (Amount <= 0)
	{
		Handler.Terminate();
		return;
	}

	CurrentTier = 2;
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
		// enable console
		Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		return false;
	}
}

function string SerializeParam()
{
	return string(BotsToTeam) $ "\n" $ string(Amount) $ "\n" $ string(Skill);
}

function DeserializeParam(string param)
{
	local int i;

	i = InStr(param, "\n");
	BotsToTeam = int(Left(param, i));
	param = Right(param, Len(param) - i - 1);
	i = InStr(param, "\n");
	Amount = int(Left(param, i));
	param = Right(param, Len(param) - i - 1);
	Skill = int(param);
}

function string ComposeTopString()
{
	local string str;

	if(Skill < 9)
		str = super.ComposeTopString() $ " wants to add " $ string(Amount) $ " bots with skill " $ string(Skill) $ " to ";
	else	
		str = super.ComposeTopString() $ " wants to add " $ string(Amount) $ " CABAL-tier bots to ";
	switch (BotsToTeam)
	{
	case 1:
		str = str $ "<font color='" $GDIColor $"'>"$TeamTypeToString(0)$"</font>";
		break;
	case 2:
		str = str $ "<font color='" $NodColor $"'>"$TeamTypeToString(1)$"</font>"; //Nod not NOD
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
	return "team" `s teamPram `s "amount" `s Amount `s "skill" `s Skill;
}

function Execute(Rx_Game game)
{
	local int i;
	local UTBot B;

	// max is player max minus current bots and players 
	i = game.MaxPlayers - game.NumBots - game.NumPlayers;
	Amount = Min(Amount, i); 
	Amount = Max(Amount, 0);

	for (i = 0; i < Amount; i++)
	{		
		if ((BotsToTeam == 1 || BotsToTeam == 3) && game.Teams[0].Size < 32)
		{
			B = game.AddBot( , true, 0);
			if(B != None)
				AdjustSkill(B);
		}
		if ((BotsToTeam == 2 || BotsToTeam == 3) && game.Teams[1].Size < 32)
		{
			B = game.AddBot( , true, 1);
			if(B != None)
				AdjustSkill(B);
		}
	}
}

function AdjustSkill(UTBot B)
{
	B.Skill = Skill;
	B.ResetSkill();
}

DefaultProperties
{
	MenuDisplayString = "Add Bots"
	ConsoleDisplayText = "Amount of bots: "
}
