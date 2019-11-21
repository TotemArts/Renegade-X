class Rx_VoteMenuChoice_AddBots_Coop extends Rx_VoteMenuChoice_AddBots;

function Init()
{
	// enable console
	Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
}

function array<string> GetDisplayStrings()
{
	local array<string> ret;


	if (CurrentTier == 1)
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

function KeyPress(byte T)
{

	if (CurrentTier == 1)
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

	CurrentTier = 1;
}

function bool GoBack()
{
	switch (CurrentTier)
	{
	case 0:
		return true; // kill this submenu
	case 1:
		CurrentTier = 0;
		// enable console
		Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		return false;
	}
}

function string ComposeTopString()
{
	local string str;

	if(Skill < 9)
		str = super(Rx_VoteMenuChoice).ComposeTopString() $ " wants to add " $ string(Amount) $ " bots with skill " $ string(Skill);
	else	
		str = super(Rx_VoteMenuChoice).ComposeTopString() $ " wants to add " $ string(Amount) $ " CABAL-tier bots";

	return str;
}

function string ParametersLogString()
{
	return "amount" `s Amount `s "skill" `s Skill;
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

			B = game.AddBot( , true, Rx_Game_Cooperative(game).GetPlayerTeam());
			if(B != None)
				AdjustSkill(B);
	}
}
