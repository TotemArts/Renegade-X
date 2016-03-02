class Rx_VoteMenuChoice_Kick extends Rx_VoteMenuChoice;

var int KickID;
var Rx_Controller KickC;

function Init()
{
	// enable console
	Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID to kick: ");
}

function array<string> GetDisplayStrings()
{
	local array<string> ret;
	local GameReplicationInfo GRI;
	local int i;

	GRI = Handler.PlayerOwner.WorldInfo.GRI;
	for (i = 0; i < GRI.PRIArray.Length; i++)
	{
		if (GRI.PRIArray[i].bBot) continue;
		ret.AddItem(string(GRI.PRIArray[i].PlayerID) $ ": " $ GRI.PRIArray[i].PlayerName);
	}

	return ret;
}

function InputFromConsole(string text)
{
	local string s;

	s = Right(text, Len(text) - 9);
	KickID = int(s);

	Finish();
}

function string SerializeParam()
{
	return string(KickID);
}

function DeserializeParam(string param)
{
	local Rx_Controller c;
	KickID = int(param);

	foreach VoteInstigator.AllActors(class'Rx_Controller', c)
	{
		if (c.PlayerReplicationInfo.PlayerID == KickID)
		{
			KickC = c;
			break;
		}
	}

	if (KickC == none)
	{
		bPendingDelete = true;
		Rx_Game(VoteInstigator.WorldInfo.Game).DestroyVote(self);
	}
}

function ServerSecondTick(Rx_Game game)
{
	if (KickC == none) game.DestroyVote(self);
	else super.ServerSecondTick(game);
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ " wants to kick " $ KickC.PlayerReplicationInfo.PlayerName;
}

function string ParametersLogString()
{
	if (KickC == None)
		return "";
	return "player" `s `PlayerLog(KickC.PlayerReplicationInfo);
}

function Execute(Rx_Game game)
{
	game.AccessControl.KickPlayer(KickC, "voted to be kicked");
}

DefaultProperties
{
	MenuDisplayString = "Kick Player"
}
