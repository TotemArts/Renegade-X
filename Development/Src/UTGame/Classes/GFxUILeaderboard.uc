/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2011-2015 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * Leaderboard implementation (currently based upon Scoreboard files and code)
 * Related Flash content:	ut3_scoreboard.fla
 * 
 */
Class GFxUILeaderboard extends UTGFxTweenableMoviePlayer;


var GFxObject RootMC;

var GFxObject LeaderboardMC;
var GFxObject OverlayMC;
var GFxObject TitleMC;
var GFxObject ListMC;

var GFxObject CountMC;
var GFxObject CountTF;

var GFxObject Title_TitleGMC;
var GFxObject TitleTF;
var GFxObject TitleGMC;

var GFxObject ListHeaderMC;
var GFxObject ListScoreTF;
var GFxObject ListTitleTF;

var GFxObject FooterMC;
var GFxObject FooterItemMC;

var GFxObject PlayerRow;
var bool bPlayerRowTween;


var GFxObject Footer_NameTF;
var GFxObject Footer_ScoreLabelTF;
var GFxObject Footer_ScoreTF;
var GFxObject Footer_RankLabelTF;
var GFxObject Footer_RankTF;


struct ListRow
{
	var GFxObject MovieClip;
	var GFxObject InnerMovieClip;
	var GFxObject RankTF;
	var GFxObject ScoreTF;
	var GFxObject NameTF;
};

var array<ListRow> ListItems;


var bool bInitialized;


/** The number of leaderboard entries to display */
var int				LeaderboardReadCount;


/** Struct representing a leaderboard entry */
struct UILeaderboardEntry
{
	var string PlayerName;
	var int Score;
	var int Rank;
	var bool bLocalPlayer;
};

var array<UILeaderboardEntry> LeaderboardData;

/** When the leaderboard results do not contain the local player, a new read is kicked off specifically to get the local players data */
var bool bResolvingLocalPlayer;

// Cached reference to the online stats interface
var OnlineStatsInterface OSI;

// Stores a reference to the current leaderboard stats read
var UTLeaderboardRead LeaderboardStatsRead;

// Holds a timestamp for the last leaderboard read attempt
var float LastInitialReadAttempt;

// The number of times leaderboard reads have been attempted
var int ReadAttemptCount;


function bool Start(optional bool StartPaused=False)
{
	OnlineInit();

	Super.Start();
	Advance(0);

	if (!bInitialized)
		ConfigLeaderboard();

	Draw();

	return true;
}

function PlayOpenAnimation()
{
	TitleMC.GotoAndPlay("open");
	FooterMC.GotoAndPlay("open");
	OverlayMC.GotoAndPlay("open");
}

function PlayCloseAnimation()
{
	TitleMC.GotoAndPlay("close");
	FooterMC.GotoAndPlay("close");
	OverlayMC.GotoAndPlay("close");
}


/*
 * Cache references to Leaderboard's MovieClips for later use.
 */
function ConfigLeaderboard()
{
	RootMC = GetVariableObject("_root");
	LeaderboardMC = RootMC.GetObject("scoreboard");

	// Scale and shift for 16:9. Last minute hack.
	RootMC.SetFloat("_xscale", 95);
	RootMC.SetFloat("_yscale", 95);
	RootMC.SetFloat("_y", RootMC.GetFloat("_y")+25);


	LeaderboardMC.GotoAndStop("dm");
	OverlayMC = LeaderboardMC.GetObject("dm");
	ListMC = LeaderboardMC.GetObject("dm");

	TitleMC = LeaderboardMC.GetObject("title");
	Title_TitleGMC = TitleMC.GetObject("title_g");
	TitleTF = Title_TitleGMC.GetObject("textField");

	CountMC = TitleMC.GetObject("time");
	CountTF = CountMC.GetObject("textField");

	FooterMC = LeaderboardMC.GetObject("footer");
	FooterItemMC = FooterMC.GetObject("footer_item");
	Footer_NameTF = FooterItemMC.GetObject("name");
	Footer_ScoreLabelTF = FooterItemMC.GetObject("tscore");
	Footer_ScoreTF = FooterItemMC.GetObject("score");
	Footer_RankLabelTF = FooterItemMC.GetObject("tdeaths");
	Footer_RankTF = FooterItemMC.GetObject("deaths");

	Footer_ScoreLabelTF.SetText("SCORE");
	Footer_RankLabelTF.SetText("RANK");


	SetupList();

	FloatLeaderboardAnimationX(True);
	FloatLeaderboardAnimationY(True);


	bInitialized = True;
}


/**
 * Cache references to MovieClips used for the leaderboard list
 */
function SetupList()
{
	local byte i;
	local ListRow NullRow;
	local ASDisplayInfo dI;
	local GFxObject TempObj;

	for (i = 0; i < 12; i++)
	{
		ListItems[i] = NullRow;

		TempObj = ListMC.GetObject("item"$(i+1));
		ListItems[i].MovieClip = TempObj;

		if (TempObj != none)
		{
			ListItems[i].MovieClip.SetFloat("_z", 200);

			// Give 50% Alpha blend to all rows.
			// Non-empty rows will be corrected to 100% later.
			dI = ListItems[i].MovieClip.GetDisplayInfo();
			dI.Alpha = 50.0f;

			ListItems[i].MovieClip.SetDisplayInfo(dI);
		}

		TempObj = ListItems[i].MovieClip.GetObject("item_g");;
		ListItems[i].InnerMovieClip	= TempObj;

		if (TempObj != none)
		{
			ListItems[i].RankTF		= ListItems[i].InnerMovieClip.GetObject("deaths");
			ListItems[i].ScoreTF		= ListItems[i].InnerMovieClip.GetObject("score");
			ListItems[i].NameTF		= ListItems[i].InnerMovieClip.GetObject("name");
		}
	}

	ListHeaderMC = ListMC.GetObject("header");

	TempObj = ListHeaderMC.GetObject("header1");

	if (TempObj != none)
		TempObj.SetFloat("_z", 200);

	TempObj = ListHeaderMC.GetObject("score");

	if (TempObj != none)
		ListScoreTF = TempObj.GetObject("textField");

	TempObj = ListHeaderMC.GetObject("title");

	if (TempObj != none)
		ListTitleTF = TempObj.GetObject("textField");
}

/*
 * Initial setup of Leaderboard
 */
function Draw()
{
	TitleTF.SetText(GetPC().WorldInfo.GetGameClass().default.GameName);

	UpdateLeaderboardLists();
	UpdateHeaders();
}


/**
 * Updates/draws the cached leaderboard entries
 */
function UpdateLeaderboardLists()
{
	local int i;
	local UILeaderboardEntry NullEntry;

	for (i=0; i<ListItems.Length; ++i)
	{
		if (LeaderboardData.Length > i)
		{
			UpdateRow(ListItems[i], LeaderboardData[i]);

			// If the current entry is for the local player, update the footer for that player too
			if (LeaderboardData[i].bLocalPlayer)
			{
				SetPlayerRow(ListItems[i].MovieClip);
				UpdateFooter(LeaderboardData[i]);
			}
		}
		else
		{
			UpdateRow(ListItems[i], NullEntry);
		}
	}
}


/**
 * Updates the specified leaderboard row
 * NOTE: Drawing should only occur once, so no data is cached to avoid unneeded UI updates
 *
 * @param CurRow	Cached references to the GFx UI elements which make up this row, and which will be drawn to
 * @param CurData	The cached row data which is to be drawn
 */
function UpdateRow(ListRow CurRow, UILeaderboardEntry CurData)
{
	local ASDisplayInfo DI;
	local array<ASValue> Args;
	local UILeaderboardEntry NullEntry;
	local bool bNullEntry;

	bNullEntry = CurData == NullEntry;

	// Initialize the rows displayinfo
	DI = CurRow.MovieClip.GetDisplayInfo();
	DI.Alpha = 100.0;

	CurRow.MovieClip.SetDisplayInfo(DI);


	// Set the values (@todo JohnB: Are ScoreTF and DeathTF necessary? not sure I need to update these, as another bit updates later)
	if (bNullEntry)
	{
		CurRow.ScoreTF.SetText("");
		CurRow.RankTF.SetText("");
	}
	else
	{
		CurRow.ScoreTF.SetText(string(CurData.Score));
		CurRow.RankTF.SetText(string(CurData.Rank));
	}

	CurRow.InnerMovieClip.SetString("PlayerName", CurData.PlayerName);

	if (bNullEntry)
	{
		CurRow.InnerMovieClip.SetString("PlayerScore", "");
		CurRow.InnerMovieClip.SetString("PlayerDeaths", "");
	}
	else
	{
		CurRow.InnerMovieClip.SetString("PlayerScore", string(CurData.Score));
		CurRow.InnerMovieClip.SetString("PlayerDeaths", string(CurData.Rank));
	}

	Args.Length = 0;
	CurRow.InnerMovieClip.Invoke("UpdateAfterStateChange", Args);
}

/**
 * Manage this player's row. The this row will have a 3D Tween and yellow text
 */
function SetPlayerRow(GFxObject UpdatedPlayerRow)
{
	if (PlayerRow != none)
	{
		ClearsTweensOnMovieClip(PlayerRow);

		// Force the Z change if the TweenManager refuses to behave
		PlayerRow.SetFloat("_z", 200);
		PlayerRow.GetObject("item_g").GotoAndStop("default");
	}

	PlayerRow = UpdatedPlayerRow;

	if (PlayerRow != none)
	{
		TweenPlayerRow(UpdatedPlayerRow);
		PlayerRow.GetObject("item_g").GotoAndStop("player");
	}
}

/**
 * Updates topmost headers
 */
function UpdateHeaders()
{
	local int LeaderboardCount;

	// NOTE: LeaderboardCount can be set using OnlineSubsystemSteamworks.LeaderboardList.LeaderboardSize when ReadOnlineStatsComplete
	//		returns, but this is not implemented, because UTGame must not reference OnlineSubsystemSteamworks directly
	LeaderboardCount = INDEX_None;

	// Display the range of displayed entries, and the total size of the leaderboard
	if (LeaderboardCount != INDEX_None)
	{
		if (LeaderboardData.Length != 0)
			CountTF.SetText("1-"$LeaderboardReadCount$"/"$LeaderboardCount);
		else
			CountTF.SetText(string(LeaderboardCount));
	}
	else
	{
		CountTF.SetText("");
	}
}

/**
 * Updates the footer with information relevant to the player
 */
function UpdateFooter(UILeaderboardEntry FooterData)
{
	Footer_ScoreTF.SetText(string(FooterData.Score));
	Footer_NameTF.SetText(FooterData.PlayerName);
	Footer_RankTF.SetText(string(FooterData.Rank));
}


/**
 * Tween for constant _xrotation of Scoreboard
 */
function FloatLeaderboardAnimationX(bool direction)
{
	if (direction)
		TweenTo(LeaderboardMC, 5.0, "_xrotation", 4, TWEEN_Linear, "FloatScoreboard1");
	else
		TweenTo(LeaderboardMC, 5.0, "_xrotation", -4, TWEEN_Linear, "FloatScoreboard2");
}

/**
 * Tween for constant _yrotation of Scoreboard
 */
function FloatLeaderboardAnimationY(bool direction)
{
	if (direction)
		TweenTo(LeaderboardMC, 7.0, "_yrotation", 7.0, TWEEN_Linear, "FloatScoreboard3");
	else
		TweenTo(LeaderboardMC, 7.0, "_yrotation", -7.0, TWEEN_Linear, "FloatScoreboard4");
}

/**
 * Z tween for the player's row
 */
function TweenPlayerRow(GFxObject RowMC)
{
	if (bPlayerRowTween)
		TweenTo(RowMC, 1.5, "_z", -450, TWEEN_Linear, "TweenPlayerRow");
	else
		TweenTo(RowMC, 1.5, "_z", 0, TWEEN_Linear, "TweenPlayerRow");

	bPlayerRowTween = !bPlayerRowTween;
}

/**
 * Callback processor for TweenManager. Interface from UTGFxTweenableMoviePlayer
 */
function ProcessTweenCallback(String Callback, GFxObject TargetMC)
{
	switch(Callback)
	{
	case ("TweenPlayerRow"):
		TweenPlayerRow(TargetMC);
		break;

	case ("FloatScoreboard1"):
		FloatLeaderboardAnimationX(False);
		break;

	case ("FloatScoreboard2"):
		FloatLeaderboardAnimationX(True);
		break;

	case ("FloatScoreboard3"):
		FloatLeaderboardAnimationY(False);
		break;

	case ("FloatScoreboard4"):
		FloatLeaderboardAnimationY(True);
		break;

	default:
		break;
	}
}


/**
 * Complete close of Scoreboard. Fired from Flash when the "close" animation is finished.
 * NOTE: Requires that ExternalInterface is not set, as otherwise these calls are redirected to the specified ExternalInterface
 */
function OnCloseAnimComplete()
{
	OnlineCleanup();

	// Close the leaderboard but keep it in memory
	Close(False);
}

/**
 * Complete open of Scoreboard. Fired from Flash when the "open" animation is finished.
 * NOTE: Requires that ExternalInterface is not set, as otherwise these calls are redirected to the specified ExternalInterface
 */
function OnOpenAnimComplete()
{
}


// *** Leaderboards online subsystem interaction

/**
 * Initialization of online variables etc.
 */
function OnlineInit()
{
	local Class<OnlineStatsWrite> CurWriteClass;

	OSI = Class'GameEngine'.static.GetOnlineSubsystem().StatsInterface;

	if (OSI != none)
	{
		// Initiate the leaderboard read
		CurWriteClass = GetPC().WorldInfo.GetGameClass().default.OnlineStatsWriteClass;

		if (CurWriteClass != none)
		{
			LeaderboardStatsRead = new Class'UTLeaderboardRead';
			LeaderboardStatsRead.ViewId = CurWriteClass.default.ViewIds[0];

			DoInitialLeaderboardRead();
		}
		else
		{
			`log("Failed to read leaderboard data, OnlineStatsWriteClass is not set");
		}
	}
}

/**
 * Kicks off a leaderboard stats read
 */
function DoInitialLeaderboardRead()
{
	// Setup the delegate
	OSI.AddReadOnlineStatsCompleteDelegate(ReadOnlineStatsComplete);

	if (!OSI.ReadOnlineStatsByRank(LeaderboardStatsRead, 1, LeaderboardReadCount))
	{
		OSI.ClearReadOnlineStatsCompleteDelegate(ReadOnlineStatsComplete);

		// Setup a retry attempt for later
		if (ReadAttemptCount < 15)
		{
			ReadAttemptCount++;
			LastInitialReadAttempt = GetPC().WorldInfo.RealTimeSeconds;
		}
		else
		{
			`log("Call to 'ReadOnlineStatsByRank' failed; can't read leaderboard data");

			ReadAttemptCount = 0;
			LastInitialReadAttempt = -1.0;
		}
	}
	else
	{
		ReadAttemptCount = 0;
		LastInitialReadAttempt = -1.0;
	}
}

/**
 * Handles leaderboard read retries
 */
function Tick(float DeltaTime)
{
	local float CurTimeStamp;

	if (LastInitialReadAttempt != -1.0 && OSI != none)
	{
		CurTimeStamp = GetPC().WorldInfo.RealTimeSeconds;

		if (CurTimeStamp - LastInitialReadAttempt > 1.0)
			DoInitialLeaderboardRead();
	}

	Super.Tick(DeltaTime);
}

/**
 * Clear online delegates etc.
 */
function OnlineCleanup()
{
	// Clear the delegate
	if (OSI != none)
	{
		OSI.ClearReadOnlineStatsCompleteDelegate(ReadOnlinestatsComplete);
		OSI = none;
	}

	LeaderboardStatsRead = none;
}

/**
 * Online subsystem callback, called when the leaderboard stats read is complete
 *
 * @param bWasSuccessful	Whether or not the leaderboard stats read was successful
 */
function ReadOnlineStatsComplete(bool bWasSuccessful)
{
	local int i;
	local UniqueNetId CurID;
	local UILeaderboardEntry CurEntry;
	local bool bKickoffLocalQuery;
	local SettingsData RankData;

	if (bWasSuccessful)
	{
		// Only looking for the local players data
		if (bResolvingLocalPlayer)
		{
			for (i=0; i<LeaderboardStatsRead.Rows.Length; ++i)
			{
				CurID = LeaderboardStatsRead.Rows[i].PlayerId;

				if (CurID == GetPC().PlayerReplicationInfo.UniqueId)
				{
					CurEntry.PlayerName = LeaderboardStatsRead.Rows[i].NickName;
					CurEntry.Score = LeaderboardStatsRead.GetScore(CurID);

					RankData = LeaderboardStatsRead.Rows[i].Rank;

					if (LeaderboardStatsRead.Rows[i].Rank.Type == SDT_Int32)
						CurEntry.Rank = Class'Settings'.static.GetSettingsDataInt(RankData);
					else
						CurEntry.Rank = -1;

					CurEntry.bLocalPlayer = True;

					// Update the footer with the current players data
					UpdateFooter(CurEntry);

					break;
				}
			}

			bResolvingLocalPlayer = False;
		}
		else
		{
			bKickoffLocalQuery = True;

			LeaderboardData.Length = LeaderboardStatsRead.Rows.Length;

			for (i=0; i<LeaderboardStatsRead.Rows.Length; ++i)
			{
				CurID = LeaderboardStatsRead.Rows[i].PlayerId;

				LeaderboardData[i].PlayerName = LeaderboardStatsRead.Rows[i].NickName;
				LeaderboardData[i].Score = LeaderboardStatsRead.GetScore(CurID);

				RankData = LeaderboardStatsRead.Rows[i].Rank;

				if (LeaderboardStatsRead.Rows[i].Rank.Type == SDT_Int32)
					LeaderboardData[i].Rank = Class'Settings'.static.GetSettingsDataInt(RankData);
				else
					LeaderboardData[i].Rank = -1;

				// If the current entry is the logged in players entry, update the footer data
				if (CurID == GetPC().PlayerReplicationInfo.UniqueId)
				{
					LeaderboardData[i].bLocalPlayer = True;
					bKickoffLocalQuery = False;
				}
			}
		}


		// Redraw the lists
		Draw();
	}
	else
	{
		// Don't spit out an error if we were resolving the local player, as it just means the player is not in the leaderboard yet
		if (!bResolvingLocalPlayer)
			`log("ReadOnlineStatsComplete: Failed to read leaderboard data");

		bResolvingLocalPlayer = False;
	}


	// If the local player was not found in the current leaderboard results, kickoff a query to search for the local player
	if (bKickoffLocalQuery)
	{
		bResolvingLocalPlayer = True;

		// @todo JohnB: Add code for retrying this if it fails, eventually (not essential, as the main leaderboard has retry code);
		//		also, this should very very rarely fail, if at all, seeing as it's immediately kicked off after the previous read
		if (!OSI.ReadOnlineStatsByRankAroundPlayer(0, LeaderboardStatsRead, 0))
		{
			LeaderboardStatsRead = none;
			OSI.ClearReadOnlineStatsCompleteDelegate(ReadOnlineStatsComplete);
			OSI = none;
		}
	}
	else if (OSI != none)
	{
		LeaderboardStatsRead = none;
		OSI.ClearReadOnlineStatsCompleteDelegate(ReadOnlineStatsComplete);
		OSI = none;
	}
}


defaultproperties
{
	bDisplayWithHudOff=True
	bEnableGammaCorrection=False

	MovieInfo=SwfMovie'UDKHUD.UDK_ScoreBoard'

	LastInitialReadAttempt=-1.0

	LeaderboardReadCount=10
}
