class Rx_GFxGameinfoHud_Survival extends Rx_GFxGameinfoHud;

var int CurrentWave;
var float TimeUntilNextWave;
var GFxObject WaveMC, WaveText;
var bool bWaveStarted;
var bool bSurvivalStarted;

function Initialize()
{
	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	InitializeHUDVars();

	SetupScoreboard();
	MineCount.SetText(0);


	CurrentNumberPRIs = 0;
	CurrentNumVehicles = -1;
	CurrentMaxVehicles = -1;
}


exec function InitializeHUDVars() 
{
	//Gameplay Info
	BottomInfo      = GetVariableObject("_root.BottomInfo");
	StatsMC			= BottomInfo.GetObject("Stats");
	Credits         = StatsMC.GetObject("Credits");
	VehicleCount    = StatsMC.GetObject("Vehicles");
	MineCount    	= StatsMC.GetObject("Mines");
	CommPoints      = StatsMC.GetObject("CP");

	ScoreContainer = GetVariableObject("_root.ScoreContainer");
	ScoresText = ScoreContainer.GetObject("Scores");
//	KNDText = ScoreContainer.GetObject("KND");
	PlayerPosText = ScoreContainer.GetObject("CurrentPos");
	PlayerMaxText = ScoreContainer.GetObject("PlayerNum");

	LastScore = -1;
//	LastKill = -1;
//	LastDeath = -1;
	LastPos = -1;
	LastMaxPlayer = -1;
}

function TickHUD()
{
	local Pawn MyPawn;
	local int CurrentPos;
	local int RenScore;
	local Array<PlayerReplicationInfo> PRIList;
	local PlayerReplicationInfo PRI;

	if(RxPC == None)
		RxPC = Rx_Controller(GetPC());

	if(RxPC == None) 
	{
		return;
	}
	else
	{
		if(RxPRI == None)
			RxPRI = Rx_PRI(RxPC.PlayerReplicationInfo);

		if(RxGRI == None)
			RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);	
	}

	MyPawn = RxPC.Pawn;

	if(MyPawn != None)
	{
		if(bPlayerDead)
		{
			bPlayerDead = false;
			SetLivingHUDVisible(true);
		}
	}
	else
	{
		if(!bPlayerDead)
		{
			bPlayerDead = true;
			SetLivingHUDVisible(false);
		}		
	}

	if(Scoreboard != None)
		UpdateScoreboard();

	if(!bBuildingSetup)
		SetupBuildings();

	if(NextScoreUpdate < RenxHud.WorldInfo.TimeSeconds)
	{
		foreach RxGRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None || Rx_PRI(pri).bIsScripted)	// skip if the bot is a scripted one
				continue;

			PRIList.AddItem(pri);
		}

		PRIList.Sort(SortPriDelegate);	
		CurrentPos = 1 + (PRIList.Find(RxPRI));

		if(RxPRI != None && ScoreContainer != None)
		{
			RenScore = RxPRI.GetRenScore();


			if(LastScore != RenScore)
			{
				LastScore = RenScore;
				ScoresText.SetText(string(RenScore));
			}
			if(LastPos != CurrentPos)
			{
				LastPos = CurrentPos;
				PlayerPosText.SetText(string(CurrentPos));
			}
			if(LastMaxPlayer != PRIList.Length)
			{
				LastMaxPlayer = PRIList.Length;
				PlayerMaxText.SetText(String(PRIList.Length));
			}
		}

		NextScoreUpdate = RenxHud.WorldInfo.TimeSeconds + 0.75;
	}

	if (RxPRI != none)
	{
		if(!RxPC.IsSpectating())
		{
			UpdateCredits(RxPRI.GetCredits());
			if(RxPC.PlayerReplicationInfo.Team != None) 
			{
				UpdateVehicleCount(Rx_TeamInfo(RxPRI.Team).GetVehicleCount(),Rx_TeamInfo(RxPRI.Team).VehicleLimit);
				UpdateMineCount(Rx_TeamInfo(RxPRI.Team).MineCount,Rx_TeamInfo(RxPRI.Team).mineLimit);
			}
		}
		else if(Pawn(RxPC.ViewTarget) != None) 
		{
			UpdateCredits(Rx_PRI(Pawn(RxPC.ViewTarget).PlayerReplicationInfo).GetCredits());
			if(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team != None) 
			{
				UpdateVehicleCount(Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).GetVehicleCount(),Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).VehicleLimit);
				UpdateMineCount(Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).MineCount,Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).mineLimit);
			}	
		}
	}

	UpdateWaveInfo();

	// For the commander points and max points on the bottom part of the hud. EX: "756/3000'
	if(RxPRI.Team != None)
		CommPoints.SetText(int(Rx_TeamInfo(RxPRI.Team).GetCommandPoints())$"/"$int(Rx_TeamInfo(RxPRI.Team).GetMaxCommandPoints()));

}

function ToggleScoreboard()
{
	if(++currentScoreboard >= 5)
		currentScoreboard = 1;

		SetupScoreboard();
	
	Scoreboard.GotoAndStopI(currentScoreboard);
}

function SetupScoreboard()
{
	local Rx_GRI gri;
	local PlayerController PC;
	local byte TeamNum;

	PC = GetPC();
	gri = Rx_GRI(PC.WorldInfo.GRI);
	if(Rx_MapInfo_Cooperative(PC.WorldInfo.GetMapInfo()) != None)
		TeamNum =  Rx_MapInfo_Cooperative(PC.WorldInfo.GetMapInfo()).PlayerTeam;
	else if(Rx_GRI_Coop(PC.WorldInfo.GRI) != None)
		TeamNum = Rx_GRI_Coop(PC.WorldInfo.GRI).PlayerTeam;
	else
		TeamNum = PC.GetTeamNum();

	Scoreboard = GetVariableObject("_root.Scoreboard");
	SBTeamScore[0] =  Scoreboard.GetObject("TeamStats_1");
	SBTeamScore[0].GoToAndStopI(TeamNum + 1);
	SBTeamScoreText[0] = SBTeamScore[0].GetObject("Score");
	SBTeamScorePlayerNum[0] = SBTeamScore[0].GetObject("PlayerNumber");
	SBBuildContainer[0] = SBTeamScore[0].GetObject("BuildingContainer");
	WaveMC = Scoreboard.GetObject("WaveCounterMC");
	WaveMC.GoToAndStopI(2);
	WaveMC.SetVisible(false);
	MatchTimer = WaveMC.GetObject("Time");


	// Set Score
	if(gri != None)
	{
		LastTeamScore[0] = Rx_TeamInfo(gri.Teams[TeamNum]).GetRenScore();

	// Set PlayerList
		LastPlayerNum[0] = Rx_TeamInfo(GRI.Teams[TeamNum]).ReplicatedSize;
	}
	else
	{
		LastTeamScore[0] = 0;
	// Set PlayerList
		LastPlayerNum[0] = 0;
	}

	SBTeamScoreText[0].SetText(LastTeamScore[0]);
	SBTeamScorePlayerNum[0].SetText(LastPlayerNum[0]);



}

function SetupBuildings()
{
	local Rx_Building Building;
	local BuildingInfo CurrentBuilding;
	local float BuildPosX,BuildPosY;
	local Array<Rx_Building> BList;
	local Vector BLocs;
	local byte TeamNum;
	local PlayerController PC;

	if(bBuildingSetup)
		return;

	PC = GetPC();

	if(Rx_MapInfo_Cooperative(PC.WorldInfo.GetMapInfo()) != None)
		TeamNum =  Rx_MapInfo_Cooperative(PC.WorldInfo.GetMapInfo()).PlayerTeam;
	else if(Rx_GRI_Coop(PC.WorldInfo.GRI) != None)
		TeamNum = Rx_GRI_Coop(PC.WorldInfo.GRI).PlayerTeam;
	else
		TeamNum = PC.GetTeamNum();		

	bBuildingSetup = true;

	BuildingInfo_GDI.Length = 0;
	BuildingInfo_Nod.Length = 0;

	foreach GetPC().WorldInfo.AllActors(class'Rx_Building', Building)
	{
		if(Rx_Building_Team_Internals(Building.BuildingInternals) == None || !Building.bSignificant)
			continue;

		if(Rx_Building_TechBuilding(Building) != None)
			continue;

		if(Rx_Building_AirTower(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		BList.AddItem(Building);
		BLocs += Building.Location;

		// cache these in our parent HUD for later use...
	}
	if(BList.Length <= 0)
		return;

	BuildingDistanceAverage = BLocs / BList.Length;

	BList.Sort(SortBuildingDelegate);

	foreach BList(Building)
	{
		// Don't list tech buildings and insignificant ones


		CurrentBuilding.RelatedBuilding = Building;
		CurrentBuilding.LastArmor = Building.GetArmor();
		CurrentBuilding.LastHealth = Building.GetHealth();

		if(Building.GetTeamNum() == TeamNum)
		{
			CurrentBuilding.Icon = SBBuildContainer[0].AttachMovie("BuildingInfo_Icon", "GDIBuilding"$BuildingInfo_GDI.Length);
			LoadTexture("img://" $ PathName(Building.IconTexture), CurrentBuilding.Icon);

			BuildPosX = 0 - (25 * (BuildingInfo_GDI.Length));
			BuildPosY = 0;

			CurrentBuilding.Icon.SetPosition(BuildPosX, BuildPosY);
			CurrentBuilding.LastStatus = AssessBuildingStatus(CurrentBuilding.RelatedBuilding);
			CurrentBuilding.Icon.SetColorTransform(BColor[CurrentBuilding.LastStatus]);
			BuildingInfo_GDI.AddItem(CurrentBuilding);
		}
	}
}

// Rendered obsolete because we're dynamically loading textures instead
/*
function int ParseBuildingIcon(Rx_Building Building)
{
	switch(Building.myBuildingType)
	{
		case BT_Def:
			return 1;
		case BT_Veh:
			return 2;
		case BT_Inf:
			return 3;
		case BT_Money:
			return 4;
		case BT_Power:
			return 5;
	}
}
*/


function UpdateScoreboardCommon()
{
	local Rx_GRI GRI;
	local PlayerController PC;
	local int CurrentScore[2];
	local int CurrentPlayer[2];


	PC = GetPC();
	if (PC != none)
	{
		GRI = Rx_GRI(PC.WorldInfo.GRI);
	}

	if (GRI == none)
	{
		return; // if we don't have a GRI then we cant update the scores
	}

	CurrentScore[0] = Rx_TeamInfo(GRI.Teams[PC.GetTeamNum()]).GetDisplayRenScore();

	// check if update is needed
	if(LastTeamScore[0] != CurrentScore[0])
	{
		LastTeamScore[0] = CurrentScore[0];
		SBTeamScoreText[0].SetText(LastTeamScore[0]);
	}

	CurrentPlayer[0] = Rx_TeamInfo(GRI.Teams[PC.GetTeamNum()]).ReplicatedSize;

	if(LastPlayerNum[0] != CurrentPlayer[0])
	{
		LastPlayerNum[0] = CurrentPlayer[0];
		SBTeamScorePlayerNum[0].SetText(LastPlayerNum[0]);
	}
}


function UpdateBuildings()
{
	local int NextStatus;
	local int i;

	if(BuildingInfo_GDI.Length > 0)
	{
		for(i = 0; i < BuildingInfo_GDI.Length; i++)
		{
			NextStatus = AssessBuildingStatus(BuildingInfo_GDI[i].RelatedBuilding);
			
			if(NextStatus != BuildingInfo_GDI[i].LastStatus)
			{
				BuildingInfo_GDI[i].LastStatus = NextStatus;
				BuildingInfo_GDI[i].Icon.SetColorTransform(BColor[NextStatus]);
			}
		}
	}
}

function UpdateWaveInfo()
{
	if(WaveMC == None || RxPC == None)
		return;


	TimeUntilNextWave = Rx_GRI_Survival(RxPC.WorldInfo.GRI).TimeUntilNextWave;

	
	if(RxPC.WorldInfo.GRI.bMatchHasBegun && !bSurvivalStarted)
	{
		WaveMC.SetVisible(true);
		bSurvivalStarted = true;
	}
	else if (!RxPC.WorldInfo.GRI.bMatchHasBegun)
	{
		return;
	}

	if(TimeUntilNextWave > 0)
	{
		if(bWaveStarted)
		{
			bWaveStarted = false;
			WaveMC.GoToAndStopI(2);
			MatchTimer = WaveMC.GetObject("Time");
		}


		UpdateMatchTimer(FCeil(TimeUntilNextWave));

	} 
	else if (!bWaveStarted)
	{
		bWaveStarted = true;
		WaveMC.GoToAndStopI(1);
		CurrentWave = Rx_GRI_Survival(RxPC.WorldInfo.GRI).WaveNumber;
		WaveText = WaveMC.GetObject("WaveText");
		WaveText.SetText("WAVE - "$CurrentWave);
	}
}

function UpdateMatchTimer( int inTime )
{
	local string time;
	local int hours;
	local int minutes;
	local int seconds;

	if( CurrentTime != inTime  && MatchTimer != None)
	{
		hours = FFloor(float(inTime))/3600.0f;
		time = string(hours);
		if(hours < 10)
		{
			time = "0"$time;
		}
		time = time$":";		
		minutes = ((FFloor(float(inTime))/60.0f) - (Hours * 60));

		if(minutes < 10)
		{
			time $= "0";
		}

		time $= minutes$":";
		
		seconds = inTime%60;
		if (seconds < 10 )
		{
			time = time$"0";
			if(seconds == 0 && GetPC() != None && Rx_Controller(GetPC()) != None && Rx_PRI(Rx_Controller(GetPC()).playerreplicationinfo) != None)
				Rx_PRI(Rx_Controller(GetPC()).playerreplicationinfo).UpdateScoreLastMinutes();
		}
		time = time$seconds;
		MatchTimer.SetText(time);
		CurrentTime = inTime;
	}
}



DefaultProperties
{
	bDisplayWithHudOff  = false
	MovieInfo           = SwfMovie'RenXHud_Survival.RenXGameinfoHud_Survival'
	CurrentWave			= 1
}