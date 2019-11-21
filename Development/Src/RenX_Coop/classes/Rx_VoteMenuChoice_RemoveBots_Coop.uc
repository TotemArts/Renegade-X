class Rx_VoteMenuChoice_RemoveBots_Coop extends Rx_VoteMenuChoice_RemoveBots;


function array<string> GetDisplayStrings()
{
	local array<string> ret;

	if (CurrentTier == 0)
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
		// accept 1, 2
		if (T == 1 || T == 2)
		{
			if (T == 2)
			{
				CurrentTier = 1;
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
	}
}


function string ComposeTopString()
{
	local string str;

	if (Amount > 0) 
		str = string(Amount);
	else 
		str = "all";

	str = super.ComposeTopString() $ " wants to remove " $ str $ " bots";

	return str;
}

function string ParametersLogString()
{
	return "amount" `s Amount;
}

function Execute(Rx_Game game)
{
	local int i;
	local UTBot bot;
	local bool killed;

	if (Amount == 0)
	{
		game.KillBots();
		return;
	}

	for (i = 0; i < Amount; i++)
	{
		killed = false;
		foreach game.AllActors(class'UTBot', bot)
		{
			if(Rx_Bot_Scripted(bot) == None)
			{
				game.KillBot(bot);
				killed = true;
				break;
			}
		}
		if (!killed) 
			break;
	}
}
