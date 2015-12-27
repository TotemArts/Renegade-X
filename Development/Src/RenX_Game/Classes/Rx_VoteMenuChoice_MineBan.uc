class Rx_VoteMenuChoice_MineBan extends Rx_VoteMenuChoice;

var int ComID				;
var string ComName				;
var Rx_Controller ComC			;
var int Testnum;
//if these variable names seem oddly commander like... that's because they are.

function Init()
{
	// enable console
	ToTeam = Handler.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
	Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID USE NAME to mine-ban: ");
}

function array<string> GetDisplayStrings();

function InputFromConsole(string text)
{
	local string Pname;
	local Rx_PRI P_PRI;
	local color MyColor;
	
	MyColor=MakeColor(255,0,0,255);
	
	Pname = Right(text, Len(text) - 22);
	
	`log(text);
	
	`log("Playername was" $ Pname) ;
	
	//Parse player name from string. Thankfully someone else already wrote a function to parse names =D
	
	P_PRI = Handler.PlayerOwner.ParsePlayer(Pname);

	Pname = P_PRI.PlayerName;
	
	if(P_PRI == None)
	{
	`log("Failed to find player PRI, terminating vote.");
	Handler.Terminate();
	}
	
	else
	{
		//`log("Setting ComName to"@Pname);
	ComName=Pname	;
	
	ComID=FindPlayerIDfromName(Pname);
	
if(ComID <= 0) Handler.PlayerOwner.CTextMessage("GDI",80, "Player not found on team",MyColor,255,255, false,1,0.6);		
	
Finish();
	}
}

function string SerializeParam()
{

//`log("000000000000000Serialize returning " $ ComName);
return string(ComID);

}

function DeserializeParam(string param)
{
	local Rx_Controller c;
	
	//`log(ComID);
	ComID = int(param);
	

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
	`log("Sending vote with Class:"@self.Class @"Serialized Parameter: "@SerializeParam() @ "To Team: " @ToTeam);
	Handler.PlayerOwner.SendVote(self.Class, SerializeParam(), ToTeam);
	Handler.Terminate();
}



function int FindPlayerIDfromName (string Pname)
{
local Rx_PRI LPRI;
local int P_ID, i;
local GameReplicationInfo LGRI;

LGRI = Handler.PlayerOwner.WorldInfo.GRI ;


for (i=0;i < LGRI.PRIArray.Length;i++)
	{
	
		
		LPRI=Rx_PRI(LGRI.PRIArray[i]);
		
		`log(LPRI);
		
		if (LPRI.PlayerName == Pname)
		{
			`log(LPRI.PlayerName);
			
			
			if(LPRI.Team.TeamIndex != Handler.PlayerOwner.GetTeamNum()) //Don't ban people on the other team 
			{
			return -8008;	
			}
			
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
return super.ComposeTopString() $ " wants to ban" @ ComC.PlayerReplicationInfo.PlayerName @ "from Mining" ;	
}

function ServerSecondTick(Rx_Game game)
{
	if (ComC == none) game.DestroyVote(self);
	else super.ServerSecondTick(game);
}





function Execute(Rx_Game game)
{

local Rx_PRI PRI;
local color MyColor;
local Rx_Controller RXC;
MyColor=MakeColor(50,190,255,255);
	
	if (ComC == none)
		return ;
	PRI = Rx_PRI(ComC.PlayerReplicationInfo);

	
	
	
	foreach PRI.Owner.LocalPlayerControllers(class'Rx_Controller',RXC) //This is why we use variables as references kids... but meh, too lazy to be neat X.x
	{
	if(RXC.GetTeamNum() == RX_Controller(PRI.Owner).GetTeamNum() && RXC != RX_Controller(PRI.Owner)) 
		{
		if(PRI.GetMineStatus())	Rx_Controller(PRI.Owner).CTextMessage("GDI",80, PRI.PlayerName @ "Has Been Banned from Mining",MyColor,255,255, false,1,0.6);
		else
		Rx_Controller(PRI.Owner).CTextMessage("GDI",80, PRI.PlayerName @ "'s Mine Ban Lifted",MyColor,255,255, false,1,0.6);
		}
	}
	PRI.SwitchMineStatus();



	
}




DefaultProperties
{

MenuDisplayString = "Mining Ban"
	
	
}
