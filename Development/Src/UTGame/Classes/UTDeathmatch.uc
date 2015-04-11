/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTDeathmatch extends UTGame
	config(game);

function bool WantsPickups(UTBot B)
{
	return true;
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	local float ScoreDiff;

	if ( Other.PlayerReplicationInfo == None )
	{
		return 0;
	}

	// base handicap on how far pawn is behind top scorer
	UTGameReplicationInfo(GameReplicationInfo).SortPRIArray();
	ScoreDiff = GameReplicationInfo.PriArray[0].Score - Other.PlayerReplicationInfo.Score;

	if ( ScoreDiff < 3 )
	{
		// ahead or close
		return 0;
	}
	return ScoreDiff/3;
}

function WriteOnlineStats()
{
	// Hook in achievement updates
	CheckAchievements();

	Super.WriteOnlineStats();
}

// Called when endgame stats are writing, to update achievements
function CheckAchievements()
{
	if (BaseMutator != none)
		CheckSpiceOfLifeAchievement();
}

function CheckSpiceOfLifeAchievement()
{
	local Mutator M;
	local int i;
	local int MutatorBitMask;
	local UTPlayerController PC;

	for (M=BaseMutator; M!=none; M=M.NextMutator)
	{
		if ( UTMutator_BigHead(M) != None)
			i = 0;
		else if ( UTMutator_Handicap(M) != None)
			i = 1;
		else if ( UTMutator_LowGrav(M) != None)
			i = 2;
		else if ( UTMutator_NoPowerups(M) != None)
			i = 3;
		else if ( UTMutator_Slomo(M) != None)
			i = 4;
		else if ( UTMutator_SlowTimeKills(M) != None)
			i = 5;
		else if ( UTMutator_SpeedFreak(M) != None)
			i = 6;
		else if ( UTMutator_SuperBerserk(M) != None)
			i = 7;
		else if ( UTMutator_WeaponsRespawn(M) != None)
			i = 8;
		else
			i = -1;

		if (i != -1)
			MutatorBitMask = MutatorBitMask | (1 << i);
	}

	if (MutatorBitMask != 0)
	{
		foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
		{
			// Spectators don't get achievements
			if (PC.PlayerReplicationInfo.bOnlySpectator)
				continue;

			PC.ClientUpdateSpiceOfLife(MutatorBitMask);
		}
	}
}

defaultproperties
{
	Acronym="DM"
	MapPrefixes[0]="DM"

	// Default set of options to publish to the online service
	OnlineGameSettingsClass=class'UTGame.UTGameSettingsDM'

	bScoreDeaths=true

	// Deathmatch games don't care about teams for voice chat
	bIgnoreTeamForVoiceChat=true
	
	bGivePhysicsGun=false

	OnlineStatsWriteClass=Class'UTStatsWriteDM'
}
