class Rx_VoteMenuChoice_Donate extends Rx_VoteMenuChoice;

var int pID;
var float Amount;
var int pNameLen;

var int CurrentTier;

function Init()
{
	// enable console
	Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID to donate to: ");
}

function array<string> GetDisplayStrings()
{
	local array<string> ret;
	local GameReplicationInfo GRI;
	local int i;

	if (CurrentTier == 0)
	{
		GRI = Handler.PlayerOwner.WorldInfo.GRI;
		for (i = 0; i < GRI.PRIArray.Length; i++)
		{
			if (GRI.PRIArray[i].bBot) continue;
			ret.AddItem(string(GRI.PRIArray[i].PlayerID) $ ": " $ GRI.PRIArray[i].PlayerName);
		}
	}
	else
	{
		ret.Length = 0;
	}

	return ret;
}

function bool GetPlayerName(int id, out string pname)
{
	local GameReplicationInfo GRI;
	local int i;

	GRI = Handler.PlayerOwner.WorldInfo.GRI;
	for (i = 0; i < GRI.PRIArray.Length; i++)
	{
		if (GRI.PRIArray[i].PlayerID == id)
		{
			pname = GRI.PRIArray[i].PlayerName;
			return true;
		}
	}

	return false;
}

function InputFromConsole(string text)
{
	local string s;
	local string pname;

	if (CurrentTier == 0)
	{
		s = Right(text, Len(text) - 14);
		pID = int(s);

		if (!GetPlayerName(pID, pname))
		{
			// todo: terminate, wrong player selected
			Handler.Terminate();
			return;
		}

		pNameLen = Len(pname);

		CurrentTier++;
		//Handler.PlayerOwner.ShowVoteMenuConsole("How much credits do you want to donate to " $ pname $ ": ");
		Handler.PlayerOwner.HowMuchCreditsString = "How much credits do you want to donate to " $ pname $ ": ";
	}
	else
	{
		s = Right(text, Len(text) - (40 + pNameLen));
		Amount = int(s);

		Finish();
	}
}


function Finish()
{
	Handler.PlayerOwner.DonateCredits(pID, Amount);
	Handler.Terminate();
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

DefaultProperties
{
}
