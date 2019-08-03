class Rx_VoteMenuChoice_Commander extends Rx_VoteMenuChoice;

var SoundCue IonTestSnd;
var SoundCue ElectedSound;
var int ComID, CandidateRank;
var string ComName;
var Rx_Controller ComC;
var string HR_Teamname;
var int CurrentTier;
var bool VotingIn;

function Init()
{
	// enable console
	ToTeam = Handler.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
}


function array<string> GetDisplayStrings()
{
	local array<string> ret;

	if (CurrentTier == 0)
	{
		// Changing these to i|String, to match the required style to split them for the new side menu funciton.
		ret.AddItem("1|Elect");
		ret.AddItem("2|Impeach");
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
			switch (T)
			{
				case 1:
				VotingIn = true;
				break;
				case 2:
				VotingIn = false; 
				break;
			}
		
			if(Handler.PlayerOwner.WorldInfo.NetMode != NM_Standalone)
			{
				if(VotingIn) 
				{
					Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID or name of Commander candidate: ");
					CurrentTier=1;
				}
				else
				Finish();
			}
			else
			Finish(); 
		}
	}
}

function InputFromConsole(string text)
{
	local string Pname;
	local Rx_PRI P_PRI;

	Pname = Right(text, Len(text) - 33);
	
	//`log("Playername was" $ Pname) ;
	
	//Parse player name from string. Thankfully someone else already wrote a function to parse names =D
	
	P_PRI= Handler.PlayerOwner.ParsePlayer(Pname);

	Pname = P_PRI.PlayerName;
	
	if(P_PRI == None || P_PRI.GetTeamNum() != Handler.PlayerOwner.GetTeamNum() )
	{
		//`log("Failed to find player PRI, terminating vote.");
		Handler.PlayerOwner.CTextMessage("-Vote Failed-",'Red');
		Handler.Terminate();
	}
	else
	{
		//`log("Setting ComName to"@Pname);
		ComName=Pname	;
		
		ComID=FindPlayerIDfromName(Pname);
			
		Finish();
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
		// enable console
		//Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID or name of Commander candidate : ");
		return false;
	}
}


function string SerializeParam()
{

	//`log("000000000000000Serialize returning " $ ComName);
	return string(ComID) $ "\n" $ string(CandidateRank) $"\n" $ string(VotingIn);

}

function DeserializeParam(string param)
{
	local Rx_Controller c;
	local int i;
	//Fancy work with strings stolen from AddBots
	

	i = InStr(param, "\n");
	//`log(ComID);
	ComID = int(Left(param, i));
	//	`log("COMID: "@ComID);
	param = Right(param, Len(param) - i - 1);
	i = InStr(param, "\n");
	CandidateRank = 0 ;// int(Left(param, i));
	//`log("Rank: "@CandidateRank);
	param = Right(param, Len(param) - i - 1);
	VotingIn = bool(param);
	//`log("VoteIn: "@VotingIn);
	

	if(ComID !=0){
	foreach VoteInstigator.AllActors(class'Rx_Controller', c)
		{
		if (c.PlayerReplicationInfo.PlayerID == ComID)
			{
				ComC = c;
				break;
			}
		}
	
	if (ComC == none)
		{
			bPendingDelete = true;
			Rx_Game(VoteInstigator.WorldInfo.Game).DestroyVote(self);
		}
	}
}

function Finish()
{
	//`log("Sending vote with Class:"@self.Class @"Serialized Parameter: "@SerializeParam() @ "To Team: " @ToTeam);
	
	//Inject for standalones to just
	if(Handler.PlayerOwner.WorldInfo.NetMode == NM_Standalone) 
	{
		ComC = Handler.PlayerOwner;
		Execute(Rx_Game(Handler.PlayerOwner.WorldInfo.Game)); 
		Handler.Terminate();
		return;
	}
	
	Handler.PlayerOwner.SendVote(self.Class, SerializeParam(), ToTeam);
	Handler.Terminate();
}



function int FindPlayerIDfromName (string Pname)
{
local Rx_PRI LPRI;
local int P_ID, i;
local GameReplicationInfo LGRI;

LGRI = Handler.PlayerOwner.WorldInfo.GRI;

for (i=0;i < LGRI.PRIArray.Length;i++)
	{
		LPRI=Rx_PRI(LGRI.PRIArray[i]);
		
		//`log(LPRI);
		
		if (LPRI.PlayerName == Pname)
		{
			//`log(LPRI.PlayerName);
			P_ID = LPRI.PlayerID ;
	//`log("000000000000000 Player ID found as" @ P_ID)	;	
			return P_ID;
			break;
		}
	
	}
	if(P_ID == 0) return -8008;
}


function string ComposeTopString()
{

//Is it for GDI or Nod?
if(ToTeam == 0) HR_Teamname ="GDI";
	else
	HR_Teamname ="Nod" ;
	
//`log("0112121121221212 Composing Top string 11111111");
if(VotingIn) return super.ComposeTopString() $ " wants to vote " $ ComC.PlayerReplicationInfo.PlayerName $ " for " $ HR_Teamname @ "Commander" ;
else
return super.ComposeTopString() $ " wants to vote  OUT" @ HR_Teamname $"'s" @ "Commander" ;	
}

function ServerSecondTick(Rx_Game game)
{
	if(VotingIn)
		{
	if (ComC == none) 
		{
			//`log("Commander Controller not set to anything, destroying vote.");
			game.DestroyVote(self);
	
		}

	else super.ServerSecondTick(game);
		}
		else
	super.ServerSecondTick(game);
}





function Execute(Rx_Game game)
{

//local Rx_Controller CON ;
//`log("0112121121221212 Attempting to execute");

//Find applicable player controllers
	if(VotingIn) 
	{
		game.ChangeCommander(ToTeam, Rx_PRI(ComC.PlayerReplicationInfo));
	}
	else
		game.RemoveCommander(ToTeam);	
}

static function bool bIsAvailable(Rx_Controller MyHandler)
{
	return Rx_GRI(MyHandler.WorldInfo.GRI).bEnableCommanders;
}

DefaultProperties
{
	HR_Teamname = "NULL"
	MenuDisplayString = "Vote Commander"
}
