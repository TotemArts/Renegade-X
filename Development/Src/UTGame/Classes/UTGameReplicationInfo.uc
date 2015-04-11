/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTGameReplicationInfo extends GameReplicationInfo
	config(Game);

var float WeaponBerserk;
var int MinNetPlayers;
var int BotDifficulty;		// for bPlayersVsBots

var bool		bWarmupRound;	// Amount of Warmup Time Remaining
/** forces other players to be viewed on this machine with the default character */
var globalconfig bool bForceDefaultCharacter;

enum EFlagState
{
    FLAG_Home,
    FLAG_HeldFriendly,
    FLAG_HeldEnemy,
    FLAG_Down,
};

var EFlagState FlagState[2];

/** If this is set, the game is running in story mode */
var bool bStoryMode;

/** whether the server is a console so we need to make adjustments to sync up */
var bool bConsoleServer;

/** Which input types are allowed for this game **/
var bool bAllowKeyboardAndMouse;

/** set by level Kismet to disable announcements during tutorials/cinematics/etc */
var bool bAnnouncementsDisabled;

var string MutatorList;
var string RulesString;

/** weapon overlays that are available in this map - figured out in PostBeginPlay() from UTPowerupPickupFactories in the level
 * each entry in the array represents a bit in UTPawn's WeaponOverlayFlags property
 * @see UTWeapon::SetWeaponOverlayFlags() for how this is used
 */
var array<MaterialInterface> WeaponOverlays;
/** vehicle weapon effects available in this map - works exactly like WeaponOverlays, except these are meshes
 * that get attached to the vehicle mesh when the corresponding bit is set on the driver's WeaponOverlayFlags
 */
struct native MeshEffect
{
	/** mesh for the effect */
	var StaticMesh Mesh;
	/** material for the effect */
	var MaterialInterface Material;
};
var array<MeshEffect> VehicleWeaponEffects;

var bool bRequireReady;

/** Message of the Day */
var() globalconfig string MessageOfTheDay;

replication
{
	if (bNetInitial)
		WeaponBerserk, MinNetPlayers, BotDifficulty, bStoryMode, bConsoleServer, MutatorList, RulesString, bRequireReady,
		MessageOfTheDay;

	if (bNetDirty)
		bWarmupRound, FlagState, bAnnouncementsDisabled, bAllowKeyboardAndMouse;
}

simulated function PostBeginPlay()
{
	local UTPowerupPickupFactory Powerup;
	local Sequence GameSequence;
	local array<SequenceObject> AllFactoryActions;
	local SeqAct_ActorFactory FactoryAction;
	local UTActorFactoryPickup Factory;
	local int i;

	Super.PostBeginPlay();

	if( WorldInfo.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank
		MessageOfTheDay = "";
	}

	// using DynamicActors here so the overlays don't break if the LD didn't build paths
	foreach DynamicActors(class'UTPowerupPickupFactory', Powerup)
	{
		Powerup.AddWeaponOverlay(self);
	}

	// also check if any Kismet actor factories spawn powerups
	GameSequence = WorldInfo.GetGameSequence();
	if (GameSequence != None)
	{
		GameSequence.FindSeqObjectsByClass(class'SeqAct_ActorFactory', true, AllFactoryActions);
		for (i = 0; i < AllFactoryActions.length; i++)
		{
			FactoryAction = SeqAct_ActorFactory(AllFactoryActions[i]);
			Factory = UTActorFactoryPickup(FactoryAction.Factory);
			if (Factory != None && ClassIsChildOf(Factory.InventoryClass, class'UTInventory'))
			{
				class<UTInventory>(Factory.InventoryClass).static.AddWeaponOverlay(self);
			}
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SetTimer(1.0, false, 'CharacterProcessingComplete');
	}
}


/**
  * returns true if P1 should be sorted before P2
  */
simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	local LocalPlayer LP1, LP2;

	// spectators are sorted last
    if( P1.bOnlySpectator )
    {
		return P2.bOnlySpectator;
    }
    else if ( P2.bOnlySpectator )
	{
		return true;
	}

	// sort by Score
    if( P1.Score < P2.Score )
	{
		return false;
	}
    if( P1.Score == P2.Score )
    {
		// if score tied, use deaths to sort
		if ( P1.Deaths > P2.Deaths )
			return false;

		// keep local player highest on list
		if ( (P1.Deaths == P2.Deaths) && (PlayerController(P2.Owner) != None) )
		{
			LP2 = LocalPlayer(PlayerController(P2.Owner).Player);
			if ( LP2 != None )
			{
				if ( !class'Engine'.static.IsSplitScreen() || (LP2.ViewportClient.Outer.GamePlayers[0] == LP2) )
				{
					return false;
				}
				// make sure ordering is consistent for splitscreen players
				LP1 = LocalPlayer(PlayerController(P2.Owner).Player);
				return ( LP1 != None );
			}
		}
	}
    return true;
}

/** 
  * Sort the PRI Array based on InOrder() prioritization
  */
simulated function SortPRIArray()
{
	local int i, j;
	local PlayerReplicationInfo P1, P2;

	for (i=0; i<PRIArray.Length-1; i++)
	{
		P1 = PRIArray[i];
		for (j=i+1; j<PRIArray.Length; j++)
		{
			P2 = PRIArray[j];
			if( !InOrder( P1, P2 ) )
			{
				PRIArray[i] = P2;
				PRIArray[j] = P1;
				P1 = P2;
			}
		}
	}
}

//Signal that all player controllers character processing is complete
simulated function CharacterProcessingComplete()
{
	local UTPlayerController UTPC;

	foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
	{
		UTPC.CharacterProcessingComplete();
	}
}

function SetFlagHome(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_Home;
	bForceNetUpdate = TRUE;
}

simulated function bool FlagIsHome(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_Home );
}

simulated function bool FlagsAreHome()
{
	return ( FlagState[0] == FLAG_Home && FlagState[1] == FLAG_Home );
}

function SetFlagHeldFriendly(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_HeldFriendly;
}

simulated function bool FlagIsHeldFriendly(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_HeldFriendly );
}

function SetFlagHeldEnemy(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_HeldEnemy;
}

simulated function bool FlagIsHeldEnemy(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_HeldEnemy );
}

function SetFlagDown(int TeamIndex)
{
	FlagState[TeamIndex] = FLAG_Down;
}

simulated function bool FlagIsDown(int TeamIndex)
{
	return ( FlagState[TeamIndex] == FLAG_Down );
}

simulated function Timer()
{
	local byte TimerMessageIndex;
	local PlayerController PC;

	super.Timer();

	if ( WorldInfo.NetMode == NM_Client )
	{
		if ( bWarmupRound && RemainingTime > 0 )
			RemainingTime--;
	}

	// check if we should broadcast a time countdown message
	if (WorldInfo.NetMode != NM_DedicatedServer && (bMatchHasBegun || bWarmupRound) && !bStopCountDown && !bMatchIsOver && Winner == None)
	{
		switch (RemainingTime)
		{
			case 300:
				TimerMessageIndex = 16;
				break;
			case 180:
				TimerMessageIndex = 15;
				break;
			case 120:
				TimerMessageIndex = 14;
				break;
			case 60:
				TimerMessageIndex = 13;
				break;
			case 30:
				TimerMessageIndex = 12;
				break;
			default:
				if (RemainingTime <= 10 && RemainingTime > 0)
				{
					TimerMessageIndex = RemainingTime;
				}
				break;
		}
		if (TimerMessageIndex != 0)
		{
			foreach LocalPlayerControllers(class'PlayerController', PC)
			{
				PC.ReceiveLocalizedMessage(class'UTTimerMessage', TimerMessageIndex);
			}
		}
	}
}

/**
 * Open the mid-game menu
 */
simulated function ShowMidGameMenu(UTPlayerController InstigatorPC, optional name TabTag,optional bool bEnableInput)
{
	if ( TabTag == 'ScoreTab' )
	{
		InstigatorPC.myHUD.SetShowScores(true);
	}
	else
	{
		UTHUDBase(InstigatorPC.myHUD).ShowMenu();
	}
}

simulated function SetHudShowScores(bool bShow)
{
	local UTPlayerController PC;
	foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
	{
		if ( PC.MyHUD != none )
		{
			PC.MyHud.bShowScores = bShow;
		}
	}
}

function AddGameRule(string Rule)
{
	RulesString $= ((RulesString != "") ? "\n" : "")$Rule;
}

defaultproperties
{
	WeaponBerserk=+1.0
	BotDifficulty=-1
	FlagState[0]=FLAG_Home
	FlagState[1]=FLAG_Home
	TickGroup=TG_PreAsyncWork
}
