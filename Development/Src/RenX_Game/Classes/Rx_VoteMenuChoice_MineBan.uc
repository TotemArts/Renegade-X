class Rx_VoteMenuChoice_MineBan extends Rx_VoteMenuChoice;

var int ComID;
var string ComName;
var Rx_Controller ComC;

function Init()
{
	ToTeam = Handler.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
	Handler.PlayerOwner.ShowVoteMenuConsole("PlayerID USE NAME to mine-ban: ");
}

function array<string> GetDisplayStrings();

function InputFromConsole(string text)
{
	local string Pname;
	local Rx_PRI P_PRI;
	
	
	Pname = Right(text, Len(text) - 22);
	
	P_PRI = Handler.PlayerOwner.ParsePlayer(Pname);
	Pname = P_PRI.PlayerName;
	
	if(P_PRI == None)
		Handler.Terminate();
	else
	{
		ComName = Pname;
		ComID = FindPlayerIDfromName(Pname);

		if (ComID <= 0)
			Handler.PlayerOwner.CTextMessage("Player not found on team",'Red', 80);		
	
		Finish();
	}
}

function string SerializeParam()
{
	return string(ComID);
}

function DeserializeParam(string param)
{
	local Rx_Controller c;
	
	ComID = int(param);	

	if (ComID !=0)
	{
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
	Handler.PlayerOwner.SendVote(self.Class, SerializeParam(), ToTeam);
	Handler.Terminate();
}

function int FindPlayerIDfromName (string Pname)
{
	local Rx_PRI LPRI;
	local int P_ID, i;
	local GameReplicationInfo LGRI;

	LGRI = Handler.PlayerOwner.WorldInfo.GRI ;

	for (i=0; i < LGRI.PRIArray.Length; i++)
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
			
			P_ID = LPRI.PlayerID;
			return P_ID;
			break;
		}
	}
	if (P_ID == 0) return -8008;
}

function string ComposeTopString()
{	
	local string FontColor;
	
	if(ComC.GetTeamNum() == 0)
		FontColor = GDIColor;
	else if(ComC.GetTeamNum() == 1)
		FontColor = NodColor;
	else
		FontColor = HostColor;


	return super.ComposeTopString() $ " wants to ban" @ "<font color='" $FontColor $"'>"$ ComC.PlayerReplicationInfo.PlayerName$"</font>" @ "from Mining" ;	
}

function string ParametersLogString()
{
	if (ComC == None)
		return "";
	return "player" `s `PlayerLog(ComC.PlayerReplicationInfo);
}

function ServerSecondTick(Rx_Game game)
{
	if (ComC == none)
		game.DestroyVote(self);
	else
		super.ServerSecondTick(game);
}

function Execute(Rx_Game game)
{
	local Rx_PRI PRI;
	local Rx_Controller RXC;
	
	if (ComC == none)
		return;

	PRI = Rx_PRI(ComC.PlayerReplicationInfo);

	foreach PRI.Owner.LocalPlayerControllers(class'Rx_Controller',RXC) //This is why we use variables as references kids... but meh, too lazy to be neat X.x
	{
		if (RXC.GetTeamNum() == RX_Controller(PRI.Owner).GetTeamNum() && RXC != RX_Controller(PRI.Owner)) 
		{
			if(PRI.GetMineStatus())
				Rx_Controller(PRI.Owner).CTextMessage(PRI.PlayerName @ "Has Been Banned from Mining",'LightBlue',80);
			else
				Rx_Controller(PRI.Owner).CTextMessage(PRI.PlayerName @ "'s Mine Ban Lifted",'LightBlue',80);
		}
	}
	PRI.SwitchMineStatus();	
}

DefaultProperties
{
	MenuDisplayString = "Mining Ban"
}
