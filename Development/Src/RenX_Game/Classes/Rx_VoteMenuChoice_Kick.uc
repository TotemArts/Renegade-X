class Rx_VoteMenuChoice_Kick extends Rx_VoteMenuChoice;

var int KickID;
var Rx_Controller KickC;

var array<int> TargetPlayerIDs;
var array<string> TargetDisplayStrings;

function PopulateTargets() {
	local GameReplicationInfo GRI;
	local int i;

	// Populate GRI
	GRI = Handler.PlayerOwner.WorldInfo.GRI;

	// Populate result
	for (i = 0; i < GRI.PRIArray.Length; ++i) {
		if (!GRI.PRIArray[i].bBot) {
			TargetPlayerIDs.AddItem(GRI.PRIArray[i].PlayerID);
			TargetDisplayStrings.AddItem(string(TargetPlayerIDs.Length % 10) $ "|"@ GRI.PRIArray[i].PlayerName);
		}
	}
}

function array<string> GetDisplayStrings()
{
	if (TargetDisplayStrings.Length == 0) {
		PopulateTargets();
	}

	return TargetDisplayStrings;
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

// TODO: Put this somewhere else so it can be used in a generic way
function int IndexForKey(byte InputIndex) {
	local byte PageNum;

	// Sanity check input (must be in range [1, 10])
	if (InputIndex < 1 || InputIndex > 10) {
		return -1;
	}

	// Get current page number
	PageNum = Rx_HUD(Handler.PlayerOwner.myHUD).CurrentPageNum; 
	
	// Return array index based on input index and page
	`log("---AGENT--- InputIndex: " $ InputIndex $ "; PageNum: " $ PageNum);
	return (PageNum - 1) * 10 + InputIndex - 1;
}

function KeyPress(byte InputIndex)
{ 
	local int ParsedSelection; 

	// Get selection index based on input
	ParsedSelection = IndexForKey(InputIndex);
	`log("---AGENT--- ParsedSelection: " $ ParsedSelection $ "; TargetPlayerIDs.Length: " $ TargetPlayerIDs.Length);

	// Sanity check selection index
	if (ParsedSelection >= 0 && ParsedSelection < TargetPlayerIDs.Length) {
		KickID = TargetPlayerIDs[ParsedSelection];
	}
	
	Finish(); 
}

DefaultProperties
{
	MenuDisplayString = "Kick Player"
}
