class Rx_GFxGameinfoHud extends GFxMoviePlayer;

struct SBPlayerEntry
{
	var GFxObject EntryLine;
	var GFxObject PlayerName;
	var GFxObject Kills;
	var GFxObject Deaths;
	var GFXObject KDRatio;
	var GFxObject Credits;
	var GFxObject Score;
	var bool bNew;
};

struct BuildingInfo
{
	var GFxObject Icon;
	var Rx_Building RelatedBuilding;
	var int LastArmor;
	var int LastHealth;
	var int LastStatus;
};

var Array<BuildingInfo> BuildingInfo_GDI;
var Array<BuildingInfo> BuildingInfo_Nod;
var const ASColorTransform BColor[3];
var bool bBuildingSetup;

var byte gdi_buildings, nod_buildings;
var Rx_Building GDIInfantryFactory;
var Vector BuildingDistanceAverage;

// Basic Scores

var GFxObject Scoreboard;
var GFxObject SBTeamScore[2];
var GFxObject SBTeamScoreText[2], SBTeamScorePlayerNum[2];
var GFxObject SBBuildContainer[2];
var int LastPlayerNum[2], LastTeamScore[2];
var const int NumPlayerStats;
var array<SBPlayerEntry> PlayerInfo;
var int CurrentNumberPRIs;
var float LastBuildingUpdateTime;


// TeamInfo
var GFxObject BottomInfo;
var GFxObject StatsMC;
var GFxObject Credits;
var GFxObject MatchTimer;
var GFxObject VehicleCount;
var GFxObject MineCount;
var GFxObject CommPoints;

var int currentScoreboard;
var int CurrentTime;
var int CurrentNumVehicles;
var int CurrentMaxVehicles;
var int CurrentNumMines;
var int CurrentMaxMines;
// Kill/Death

Var GFxObject ScoreContainer, ScoresText, PlayerPosText, PlayerMaxText, PlayerKillText, PlayerDeathText;
var float LastScore;
var int LastKill, LastPos, LastMaxPlayer, LastDeath;

var bool bPlayerDead;

var Rx_Controller RxPC;
var Rx_PRI RxPRI;
var Rx_GRI RxGRI;

var Rx_HUD RenxHud;

var int LastResX;
var int LastResY;

var float NextScoreUpdate;

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
	PlayerKillText = ScoreContainer.GetObject("Kill");
	PlayerDeathText = ScoreContainer.GetObject("Death");
	PlayerPosText = ScoreContainer.GetObject("CurrentPos");
	PlayerMaxText = ScoreContainer.GetObject("PlayerNum");

	LastScore = -1;
	LastKill = -1;
	LastDeath = -1;
	LastPos = -1;
	LastMaxPlayer = -1;
}

function TickHUD()
{
	local Pawn MyPawn;
	local int CurrentPos;
	local int RenScore, RenKill, RenDeath;
	local Array<PlayerReplicationInfo> PRIList;
	local PlayerReplicationInfo PRI;
	local Rx_PRI TempPRI;

	if (!bMovieIsOpen) {
		return;
	}

	if(RxPC == None)
		RxPC = Rx_Controller(GetPC());

	if(RxPC == None) 
	{
		return;
	}
	else
	{
		if (RxPC.IsSpectating() && Pawn(RxPC.ViewTarget) != None)
			TempPRI = Rx_PRI(Pawn(RxPC.ViewTarget).PlayerReplicationInfo);
		else
			TempPRI = Rx_PRI(RxPC.PlayerReplicationInfo);

		if(RxPRI == None || RxPRI != TempPRI)
		{
			RxPRI = TempPRI;
		}

		if(RxGRI == None)
			RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);	
	}

	if(RxPC.IsSpectating() && Pawn(RxPC.ViewTarget) != None)
		MyPawn = Pawn(RxPC.ViewTarget);
	else
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
	else
	{
		if(RxPC.WorldInfo.TimeSeconds - LastBuildingUpdateTime > 0.5)
		LastBuildingUpdateTime = RxPC.WorldInfo.TimeSeconds;
		if(IsBuildingAmountMismatched()) // if there's a mismatch in building number, reupdate 
		{
			bBuildingSetup = false;
		}
	}

	if (RxPC.WorldInfo != none && RxPC.WorldInfo.GRI !=none)
	{
		if (RxPC.WorldInfo.GRI.TimeLimit > 0)
			UpdateMatchTimer(RxPC.WorldInfo.GRI.RemainingTime);
		else
			UpdateMatchTimer(RxPC.WorldInfo.GRI.ElapsedTime);

	}

	if(NextScoreUpdate < RenxHud.WorldInfo.TimeSeconds)
	{
		foreach RxGRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None || Rx_PRI(pri).bIsScripted || pri.bIsSpectator)	// skip if the bot is a scripted one
				continue;

			PRIList.AddItem(pri);
		}

		PRIList.Sort(SortPriDelegate);	
		CurrentPos = 1 + (PRIList.Find(RxPRI));

		if(RxPRI != None && ScoreContainer != None)
		{
			RenScore = RxPRI.GetRenScore();
			RenKill = RxPRI.GetRenKills();
			RenDeath = RxPRI.Deaths;


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
			if(LastDeath != RenDeath)
			{
				LastDeath = RenDeath;
				PlayerDeathText.SetText(String(LastDeath));
			}
			if(LastKill != RenKill)
			{
				LastKill = RenKill;
				PlayerKillText.SetText(String(LastKill));
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

	// For the commander points and max points on the bottom part of the hud. EX: "756/3000'
	if(RxPRI.Team != None)
		CommPoints.SetText(int(Rx_TeamInfo(RxPRI.Team).GetCommandPoints())$"/"$int(Rx_TeamInfo(RxPRI.Team).GetMaxCommandPoints()));

}

function bool IsBuildingAmountMismatched()
{
	local int BuildingAmount;
	local Rx_Building Building;


	foreach GetPC().WorldInfo.AllActors(class'Rx_Building', Building)
	{
		if(Rx_Building_Team_Internals(Building.BuildingInternals) == None || !Building.bSignificant)
			continue;

		if(Rx_Building_TechBuilding(Building) != None)
			continue;

		if(Rx_Building_AirTower(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		BuildingAmount++;
		// start counting
	}

	if(BuildingInfo_GDI.Length + BuildingInfo_Nod.Length != BuildingAmount)
	{
		`log("Client has run into a mismatch, resetting building informations....");
		return true;
	}


	return false;
}

function UpdateVehicleCount( int numVehicles, int maxVehicles )
{
	if ( numVehicles != CurrentNumVehicles  || maxVehicles != CurrentMaxVehicles)
	{
		VehicleCount.SetText(numVehicles$"/" $ maxVehicles);
		CurrentNumVehicles = numVehicles;
		CurrentMaxVehicles = maxVehicles;
	}
}

function UpdateMineCount( int numMines, int maxMines )
{
	if ( numMines != CurrentNumMines || maxMines != CurrentMaxMines)
	{
		MineCount.SetText(numMines $"/" $ maxMines);
		CurrentNumMines = numMines;
		CurrentMaxMines = maxMines;
	}
}


function UpdateCredits(int inCredits)
{
	Credits.SetText(inCredits);
}

function UpdateMatchTimer( int inTime )
{
	local string time;
	local int hours;
	local int minutes;
	local int seconds;

	if( CurrentTime != inTime )
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


	gri = Rx_GRI(GetPC().WorldInfo.GRI);
	
	Scoreboard = GetVariableObject("_root.Scoreboard");
	MatchTimer = Scoreboard.GetObject("Time");
	SBTeamScore[0] =  Scoreboard.GetObject("TeamStats_1");
	SBTeamScore[0].GoToAndStopI(1);
	SBTeamScoreText[0] = SBTeamScore[0].GetObject("Score");
	SBTeamScorePlayerNum[0] = SBTeamScore[0].GetObject("PlayerNumber");
	SBBuildContainer[0] = SBTeamScore[0].GetObject("BuildingContainer");
	SBTeamScore[1] =  Scoreboard.GetObject("TeamStats_2");
	SBTeamScore[1].GoToAndStopI(2);
	SBTeamScoreText[1] = SBTeamScore[1].GetObject("Score");
	SBTeamScorePlayerNum[1] = SBTeamScore[1].GetObject("PlayerNumber");
	SBBuildContainer[1] = SBTeamScore[1].GetObject("BuildingContainer");


	// Set Score
	if(gri != None)
	{
		LastTeamScore[0] = Rx_TeamInfo(gri.Teams[0]).GetRenScore();
		LastTeamScore[1] = Rx_TeamInfo(gri.Teams[1]).GetRenScore();


	// Set PlayerList
		LastPlayerNum[0] = Rx_TeamInfo(GRI.Teams[0]).ReplicatedSize;
		LastPlayerNum[1] = Rx_TeamInfo(GRI.Teams[1]).ReplicatedSize;	
	}
	else
	{
		LastTeamScore[0] = 0;
		LastTeamScore[1] = 0;


	// Set PlayerList
		LastPlayerNum[0] = 0;
		LastPlayerNum[1] = 0;	
	}


	SBTeamScoreText[0].SetText(LastTeamScore[0]);
	SBTeamScoreText[1].SetText(LastTeamScore[1]);

	SBTeamScorePlayerNum[0].SetText(LastPlayerNum[0]);
	SBTeamScorePlayerNum[1].SetText(LastPlayerNum[1]);



}

function SetupBuildings()
{
	local Rx_Building Building;
	local BuildingInfo CurrentBuilding;
	local float BuildPosX,BuildPosY;
	local Array<Rx_Building> BList;
	local Vector BLocs;
	local Array<BuildingInfo> BuildingInfo_GDI_OLD;
	local Array<BuildingInfo> BuildingInfo_Nod_OLD;

	if(bBuildingSetup)
		return;

	bBuildingSetup = true;

	if(BuildingInfo_GDI.Length > 0)
		BuildingInfo_GDI_OLD = BuildingInfo_GDI;

	if(BuildingInfo_Nod.Length > 0)
		BuildingInfo_Nod_OLD = BuildingInfo_Nod;

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

		if(Building.GetTeamNum() == 0)
		{
			if(BuildingInfo_GDI.length + 1 <= BuildingInfo_GDI_OLD.Length)
				CurrentBuilding.Icon = BuildingInfo_GDI_OLD[BuildingInfo_GDI.length].Icon;
			else	
				CurrentBuilding.Icon = SBBuildContainer[0].AttachMovie("BuildingInfo_Icon", "GDIBuilding"$BuildingInfo_GDI.Length);
			
			LoadTexture("img://" $ PathName(Building.IconTexture), CurrentBuilding.Icon);

			BuildPosX = 0 - (25 * (BuildingInfo_GDI.Length));
			BuildPosY = 0;

			CurrentBuilding.Icon.SetPosition(BuildPosX, BuildPosY);
			CurrentBuilding.LastStatus = AssessBuildingStatus(CurrentBuilding.RelatedBuilding);
			CurrentBuilding.Icon.SetColorTransform(BColor[CurrentBuilding.LastStatus]);
			BuildingInfo_GDI.AddItem(CurrentBuilding);
		}

		else if (Building.GetTeamNum() == 1)
		{
			if(BuildingInfo_Nod.length + 1 <= BuildingInfo_Nod_OLD.Length)
				CurrentBuilding.Icon = BuildingInfo_Nod_OLD[BuildingInfo_Nod.length].Icon;
			else	
				CurrentBuilding.Icon = SBBuildContainer[1].AttachMovie("BuildingInfo_Icon", "NodBuilding"$BuildingInfo_Nod.Length);
			LoadTexture("img://" $ PathName(Building.IconTexture), CurrentBuilding.Icon);

			BuildPosX = 0 + (25 * (BuildingInfo_Nod.Length));
			BuildPosY = 0;

			CurrentBuilding.Icon.SetPosition(BuildPosX, BuildPosY);
			CurrentBuilding.LastStatus = AssessBuildingStatus(CurrentBuilding.RelatedBuilding);
			CurrentBuilding.Icon.SetColorTransform(BColor[CurrentBuilding.LastStatus]);
			BuildingInfo_Nod.AddItem(CurrentBuilding);
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

function int AssessBuildingStatus(Rx_Building Building)
{


	if( Building.IsDestroyed() )
		return 2;

	else if( Building.GetMaxArmor() <= 0 && Building.GetHealth() <= (Building.GetMaxHealth()/4))
		return 1;

	else if( Building.GetMaxArmor() > 0 && Building.GetArmor() <= 240)
		return 1;

	return 0;
}


function UpdateScoreboard()
{
	UpdateScoreboardCommon();
	UpdateBuildings();
}


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

	CurrentScore[0] = Rx_TeamInfo(GRI.Teams[0]).GetDisplayRenScore();
	CurrentScore[1] = Rx_TeamInfo(GRI.Teams[1]).GetDisplayRenScore();


	// check if update is needed
	if(LastTeamScore[0] != CurrentScore[0])
	{
		LastTeamScore[0] = CurrentScore[0];
		SBTeamScoreText[0].SetText(LastTeamScore[0]);
	}
	if(LastTeamScore[1] != CurrentScore[1])
	{
		LastTeamScore[1] = CurrentScore[1];
		SBTeamScoreText[1].SetText(LastTeamScore[1]);
	}

	CurrentPlayer[0] = Rx_TeamInfo(GRI.Teams[0]).ReplicatedSize;
	CurrentPlayer[1] = Rx_TeamInfo(GRI.Teams[1]).ReplicatedSize;

	if(LastPlayerNum[0] != CurrentPlayer[0])
	{
		LastPlayerNum[0] = CurrentPlayer[0];
		SBTeamScorePlayerNum[0].SetText(LastPlayerNum[0]);
	}
	if(LastPlayerNum[1] != CurrentPlayer[1])
	{
		LastPlayerNum[1] = CurrentPlayer[1];
		SBTeamScorePlayerNum[1].SetText(LastPlayerNum[1]);
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

	if(BuildingInfo_Nod.Length > 0)
	{
		for(i = 0; i < BuildingInfo_Nod.Length; i++)
		{
			NextStatus = AssessBuildingStatus(BuildingInfo_Nod[i].RelatedBuilding);
			
			if(NextStatus != BuildingInfo_Nod[i].LastStatus)
			{
				BuildingInfo_Nod[i].LastStatus = NextStatus;
				BuildingInfo_Nod[i].Icon.SetColorTransform(BColor[NextStatus]);
			}
		}
	}
}


exec function SetLivingHUDVisible(bool visible)
{
	if(RenxHUD.SystemSettingsHandler.bGameInfo)
		BottomInfo.SetVisible(visible);

	if(RenxHUD.SystemSettingsHandler.bPersonalInfo)
		ScoreContainer.SetVisible(visible);
}

function ResizedScreenCheck(optional bool bForce)
{
	// Resize the HUD after viewport size change
	local Vector2D ViewportSize;
//	local float x0, y0, x1, y1;
	local Vector2D HudMovieSize;
	local Vector2D PositionMod;
	local Vector2D LowerLeftCorner, UpperRightCorner;

	local float RatioDiscrepancy;
	local float SizeDiscrepancy;
	local float StageWidthPct, StageHeightPct;
	local float ResizerX, ResizerY;
	local ASDisplayInfo DI;
	local float HUDScale;
	
	GetGameViewportClient().GetViewportSize(ViewportSize);
//	GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = ViewportSize.X;
	HudMovieSize.Y = ViewportSize.Y;

	HUDScale = (FClamp(RenxHUD.SystemSettingsHandler.HUDScale, 75, 125)) / 100;
	
	if(LastResX != int(ViewportSize.X) || LastResY != int(ViewportSize.Y) || bForce)
	{

//		`Log("LastRes="@LastResX@LastResY@"ViewportSize="@ViewportSize.X@ViewportSize.Y);
		LastResX = ViewportSize.X;
		LastResY = ViewportSize.Y;

		SetViewport(0,0,int(ViewportSize.X),int(ViewportSize.Y));

		SetViewScaleMode(GFxScaleMode.SM_NoBorder);
		SetAlignment(GFxAlign.Align_Center);  



 
		StageWidthPct = HudMovieSize.X/1680;
		StageHeightPct = HudMovieSize.Y/1050;

		PositionMod.X = 0;
		PositionMod.Y = 0;

//		Handepsilon : This takes AGES to figure out. I pray that it works

		RatioDiscrepancy = (HudMovieSize.X/HudMovieSize.Y) - 1.6;

		if(RatioDiscrepancy > 0) //Height is smaller than in ratio
		{
			SizeDiscrepancy = (HudMovieSize.X / 1680 * 1050) - HudMovieSize.Y;
			PositionMod.Y = SizeDiscrepancy *  840 / HudMovieSize.X;
		}
		else if(RatioDiscrepancy < 0) //Width is smaller than in ratio
		{
			SizeDiscrepancy = (HudMovieSize.Y / 1050 * 1680) - HudMovieSize.X;
			PositionMod.X = SizeDiscrepancy *  525 / HudMovieSize.Y;

		}

		// Some of these will need manual rescaling to be readable on low res, unfortunately
		ResizerX = FClamp(StageWidthPct,0.9,1);
		ResizerY = FClamp(StageHeightPct,0.9,1);

//		`log("StageWidthPct : "$StageWidthPct@"StageHeightPct : "$StageHeightPct);
//		UpperLeftCorner.X = PositionMod.X;
//		UpperLeftCorner.Y = PositionMod.Y;
		UpperRightCorner.X = 1680 - PositionMod.X;
		UpperRightCorner.Y = PositionMod.Y;
		LowerLeftCorner.X = PositionMod.X;
		LowerLeftCorner.Y = 1050 - PositionMod.Y;
//		LowerRightCorner.X = 1680 - PositionMod.X;
//		LowerRightCorner.Y = 1050 - PositionMod.Y;


//		`log("StageHeightPct :"@StageHeightPct);
//		`log("StageWidthPct :"@StageWidthPct);
		`log("PositionModX :"@PositionMod.X);
		`log("PositionModY :"@PositionMod.Y);

		DI.HasXScale = true;
		DI.HasYScale = true;

		//HealthBlock
		DI.XScale = HUDScale * (100.f + (100.f * (1.0 - FMin(ResizerX,ResizerY))));
		DI.YScale = DI.XScale;

		if(RenxHUD.SystemSettingsHandler.bGameInfo)
		{
			BottomInfo.SetVisible(true);
			BottomInfo.SetDisplayInfo(DI);
			BottomInfo.SetPosition(LowerLeftCorner.X  - ((20 * HUDScale) - 20),LowerLeftCorner.Y + ((20 * HUDScale) - 20));
		}
		else
		{
			BottomInfo.SetVisible(false);
		}

		if(RenxHUD.SystemSettingsHandler.bPersonalInfo)
		{
			ScoreContainer.SetVisible(true);
			ScoreContainer.SetDisplayInfo(DI);
			ScoreContainer.SetPosition(UpperRightCorner.X + ((20 * HUDScale) - 20),UpperRightCorner.Y - ((20 * HUDScale) - 20));
		}
		else
		{
			ScoreContainer.SetVisible(false);
		}

		//Scoreboard
//		DI.XScale = 100.f + (100.f * (1.0 - FMin(StageHeightPct,StageWidthPct)));
//		DI.YScale = DI.XScale;
//		`log("Scoreboard Scale :"@DI.XScale@DI.YScale);
	//	Scoreboard.SetDisplayInfo(DI);

		DI.XScale = HUDScale * 100.f;
		DI.YScale = DI.XScale;

		if(RenxHUD.SystemSettingsHandler.bTeamInfo)
		{
			Scoreboard.SetVisible(true);
			Scoreboard.SetDisplayInfo(DI);
			Scoreboard.SetPosition(840,1050 - PositionMod.Y + ((20 * HUDScale) - 20)); // Lower Center
		}
		else
		{
			Scoreboard.SetVisible(false);
		}


	}
}


function int SortBuildingDelegate( coerce Rx_Building B1, coerce Rx_Building B2 )
{
	if (B1.myBuildingType > B2.myBuildingType)
		return 1;
	else if (B1.myBuildingType == B2.myBuildingType)
	{
		if(VSizeSq(BuildingDistanceAverage - B1.Location) > VSizeSq(BuildingDistanceAverage - B2.Location))
			return 1;

		else if(VSizeSq(BuildingDistanceAverage - B1.Location) == VSizeSq(BuildingDistanceAverage - B2.Location)) // should only happen when there are only 2 buildings existing
		{	
			if(B1.GetTeamNum() < B2.GetTeamNum()) // prioritize GDI (huehuehue~)
				return 1;

			else if (B1.GetTeamNum() == B2.GetTeamNum())
			{		
				//Uh oh! same team number! What happened there? (probably tests, either way, try to avoid crash)
				if(Asc(String(B1.Name)) < Asc(String(B1.Name))) // might be dodgy, but theoretically no name should ever be the same
					return 1;
				else
					return -1;
			}
			else
				return -1;
		}
		else
			return -1;
	}
	else
		return -1;


	return 0;
}

function int SortPriDelegate( coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2 )
{
	if (Rx_PRI(pri1) != none && Rx_PRI(pri2) != none)
	{
		if (Rx_PRI(pri1).GetRenScore() > Rx_PRI(pri2).GetRenScore())
		{
			return 1;
		} 
		else if (Rx_PRI(pri1).GetRenScore() == Rx_PRI(pri2).GetRenScore())
		{
			return 0;
		}
		else
		{
			return -1;
		}
	}
	return 0;
}

function LoadTexture(string pathName, GFxObject widget) 
{
	widget.ActionScriptVoid("loadTexture");
}

DefaultProperties
{
	bDisplayWithHudOff  = false
	MovieInfo           = SwfMovie'RenXHud.RenXGameinfoHud'

	CurrentNumMines     = -1
	CurrentMaxMines     = -1
	CurrentNumVehicles  = -1
	CurrentMaxVehicles  = -1
	currentScoreboard   = 1
	NumPlayerStats      = 16

	BColor[0] = (multiply=(R=1,G=1,B=1,A=1),add=(R=0,G=0,B=0,A=0))
	BColor[1] = (multiply=(R=1,G=0,B=0,A=1),add=(R=0.1,G=0,B=0,A=1))
	BColor[2] = (multiply=(R=0.5,G=0.5,B=0.3,A=1),add=(R=0,G=0,B=0.08,A=1))
}