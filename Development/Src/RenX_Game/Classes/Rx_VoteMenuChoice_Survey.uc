class Rx_VoteMenuChoice_Survey extends Rx_VoteMenuChoice;

var string ConsoleDisplayText;

var string SurveyText;

var int CurrentTier;

function Init()
{
	// enable console
	Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
}

function InputFromConsole(string text)
{
	SurveyText = Right(text, Len(text) - 6);
	CurrentTier = 1;
}

function array<string> GetDisplayStrings()
{
	local array<string> ret;

	if (CurrentTier == 1)
	{
		ret.AddItem("1: Among All");
		ret.AddItem("2: Only Team");
	}

	return ret;
}

function KeyPress(byte T)
{
	if (CurrentTier == 1)
	{
		// accept 1, 2
		if (T == 1 || T == 2)
		{
			if (T == 2)
				ToTeam = Handler.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
			Finish();
		}
	}
}

function bool GoBack()
{
	switch (CurrentTier)
	{
	case 0:
		return true; // kill this submenu
	case 1:
		CurrentTier = 0;
		Handler.PlayerOwner.ShowVoteMenuConsole(ConsoleDisplayText);
		return false;
	}
}

function string SerializeParam()
{
	return SurveyText;
}

function DeserializeParam(string param)
{
	SurveyText = param;
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ ": " $ SurveyText;
}

function string ParametersLogString()
{
	return "text:\""$SurveyText$"\"";
}

function Execute(Rx_Game game)
{
	// do nothing
}

DefaultProperties
{
	TimeLeft = 20 // seconds
	MenuDisplayString = "Survey"
	ConsoleDisplayText = "Survey text: "
}
