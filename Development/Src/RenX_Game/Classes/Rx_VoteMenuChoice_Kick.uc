class Rx_VoteMenuChoice_Kick extends Rx_VoteMenuChoice;

var int KickID;
var Rx_Controller KickC;
var array<int> KickIDList; 

/**function Init()
{
	// enable console
	//Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID to kick: ");
}*/

function ServerInit(Rx_Controller instigator, string param, int t)
{
	local string params;
	 
	ToTeam = t;
	VoteInstigator = instigator;
	DeserializeParam(param);
	TopString = ComposeTopString();
	EndTime = instigator.WorldInfo.TimeSeconds + TimeLeft;
	
	// Log vote called.
	params = ParametersLogString();
	if (params != "")
		Rx_Game(instigator.WorldInfo.Game).RxLog("VOTE"`s "Called;" `s TeamTypeToString(t) `s class `s "by" `s `PlayerLog(instigator.PlayerReplicationInfo) `s params);
	else
		Rx_Game(instigator.WorldInfo.Game).RxLog("VOTE"`s "Called;" `s TeamTypeToString(t) `s class `s "by" `s `PlayerLog(instigator.PlayerReplicationInfo) );
/*
	if (KickC != None && Rx_PRI(KickC.PlayerReplicationInfo).bIsAFK) {
		`RxGameObject.RxLog("VOTE" `s "Results;" `s TeamTypeToString(ToTeam) `s class `s "pass" `s "Yes=1" `s "No=0");
		Execute(`RxGameObject);
		`RxGameObject.DestroyVote(self);
	}
*/
	// update on players
	UpdatePlayers(instigator.WorldInfo);
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
		ret.AddItem(string((i+1)%10) $ "|"@ GRI.PRIArray[i].PlayerName);
		KickIDList.AddItem(GRI.PRIArray[i].PlayerID);
	}

	return ret;
}

/**function InputFromConsole(string text)
{
	local string s;

	s = Right(text, Len(text) - 9);
	KickID = int(s);

	Finish();
}*/



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

function KeyPress(byte T)
{
	local byte 	PageNum; 
	local int	ParsedSelection; 
	
	PageNum = Rx_HUD(Handler.PlayerOwner.myHUD).CurrentPageNum; 
	// accept 1, 2, 3
	if(T>0 && T<=10) {
		ParsedSelection = (PageNum-1)*10 + T;
	} else {
		Finish();
		return;
	}
	KickID = KickIDList[ParsedSelection];
		
	Finish(); 
}

DefaultProperties
{
	MenuDisplayString = "Kick Player"
}
