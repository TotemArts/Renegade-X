/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * UT3 specific achievements implementation
 */
Class UTAchievements extends UTAchievementsBase within UTPlayerController;

/**
 * UT3 achievement defines
 */
enum EUTGameAchievements
{
	EUTA_EXPLORE_EveryMutator,
	EUTA_WEAPON_DontTaseMeBro,
	EUTA_WEAPON_StrongestLink,
	EUTA_WEAPON_HaveANiceDay,
	EUTA_VEHICLE_Armadillo,
	EUTA_POWERUP_DeliveringTheHurt,
	EUTA_HUMILIATION_SerialKiller,
	EUTA_HUMILIATION_OffToAGoodStart
};


/**
 * Updates the 'Spice of Life' achievement value, with an added mutator bitmask
 *
 * @param MutatorBitMask	The new mutator bitmask to add to the achievement value
 */
function UpdateSpiceOfLife(int MutatorBitMask)
{
	local int CurrentMask;
	local int i;
	local int MutatorBit;

	if (GetAchievementValue(EUTA_EXPLORE_EveryMutator, CurrentMask))
	{
		for (i=0; i<31; i++)
		{
			MutatorBit = 1 << i;

			if((MutatorBitMask & MutatorBit) == MutatorBit && (CurrentMask & MutatorBit) == 0)
			{
				UpdateAchievement(EUTA_EXPLORE_EveryMutator, MutatorBit);
				break;
			}
		}
	}
}


defaultproperties
{
	AchievementStatsReadClass=Class'UTStatsReadAchievements'
	AchievementStatsWriteClass=Class'UTStatsWriteAchievements'

	// The list of achievements
	AchievementsArray.Add((Id=EUTA_EXPLORE_EveryMutator,UnlockType=EAUT_BitMask,UnlockCriteria=0x1ff,ProgressCriteria=3,bDoUnlock=True,bDoProgress=True))

	// The below achievements are setup so the achievement manager does not handle unlocks/progress-toasts for these achievements;
	//	instead, this is handled by OnlineSubsystemSteamworks automatic achievement progress/unlock handling.
	//	To regain control of unlocks/progress from here, bAutoUnlock (and ProgressCount, if you want control of progress toasts) must be
	//	unset in AchievementMappings in DefaultEngine.ini, and bDoUnlock/bDoProgress must be set to True here
	AchievementsArray.Add((Id=EUTA_WEAPON_DontTaseMeBro,UnlockType=EAUT_Count,UnlockCriteria=4,ProgressCriteria=2,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_WEAPON_StrongestLink,UnlockType=EAUT_Count,UnlockCriteria=4,ProgressCriteria=2,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_WEAPON_HaveANiceDay,UnlockType=EAUT_Count,UnlockCriteria=4,ProgressCriteria=2,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_VEHICLE_Armadillo,UnlockType=EAUT_Count,UnlockCriteria=4,ProgressCriteria=2,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_POWERUP_DeliveringTheHurt,UnlockType=EAUT_Count,UnlockCriteria=60,ProgressCriteria=30,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_HUMILIATION_SerialKiller,UnlockType=EAUT_Count,UnlockCriteria=1,ProgressCriteria=0,bDoUnlock=False,bDoProgress=False))
	AchievementsArray.Add((Id=EUTA_HUMILIATION_OffToAGoodStart,UnlockType=EAUT_Count,UnlockCriteria=1,ProgressCriteria=0,bDoUnlock=False,bDoProgress=False))
}

