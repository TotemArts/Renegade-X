/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Manages clientside tracking and updating of achievements
 *
 * How to use: (requires Steam partner access and appid)
 * 1: Extend this class, and setup the achievements:
 *	- Setup an enum listing your achievements
 *	- Add your achievements to 'AchievementsArray'
 *		(see 'UTAchievements')
 *	- In DefaultEngine.ini setup AchievementMappings
 *		(see 'OnlineSubsystemSteamworks.AchievementMappings')
 *		- 'AchievementName' is the Steam achievement API Name
 *	- NOTE: By default, this class does not handle progress toasts
 *		(set them up in 'AchievementMappings' instead)
 *
 * 2: Configure storage:
 *	- Setup a custom 'OnlineStatsRead' subclass
 *		(see 'UTStatsReadAchievements')
 *		- Add the achievement enums to 'ColumnIds'
 *		- Add the achievement enums to 'ColumnMappings'
 *			- Id and Name should match enums
 *		- Set 'ViewId'
 *			- AchievementMappings should use same ViewId
 *		- Stats name format: ViewId_ColumnId
 *			(same as ViewId_AchievementId)
 *			- With ViewId=30, stat names are:
 *				- 30_0 (first achievement)
 *				- 30_1 (second achievement)
 *				- etc.
 *	- Setup a custom 'OnlineStatsWrite' subclass
 *		(see 'UTStatsWriteAchievements')
 *		- Add achievement enums to 'Properties'
 *			- Must match stats read achievement order
 *		- Set 'ViewIds'
 *	- Set 'AchievementStatsReadClass':
 *		Should match custom OnlineStatsRead class
 *	- Set 'AchievementStatsWriteClass':
 *		Should match custom OnlineStatsWrite class
 *
 * 3: Setup achievements and stats on the Steam backend:
 *	- Stats tab:
 *		- Add stats entries for all achievements
 *		- API Name format: ViewId_AchievementId
 *			(see step 2)
 *		- Must be INT, and must be set by Client
 *	- Achievements tab:
 *		- Add all achievement details/icons
 *		- Achievements must have icons set
 *		- 'Set By' should always read 'Client'
 *		- API Name must match AchievementName in
 *			AchievementMappings
 *		- Optional: Link achievements to their stats
 *			- Max should match UnlockCriteria
 *
 * 4: Use 'UpdateAchievement' to increment achievement progress
 *	- Implement gameplay logic for achievements
 *	- Call 'UpdateAchievement' where appropriate
 */
Class UTAchievementsBase extends object within UTPlayerController;


/**
 * The methods used for unlocking achievements
 * NOTE: OnlineSubsystemSteamworks can handle EAUT_Count achievements automatically; see OnlineSubsystemSteamworks.AchievementMappings
 */
enum EAchievementUnlockType
{
	EAUT_Count,	// Event must be performed 'x' times to unlock achievement
	EAUT_Bitmask,	// Bitmask which stored achievement value must match in order to unlock
	EAUT_ByteCount	// Achievement int value is treated as 4 byte sized counters, which is compared against a bitmask value
};

/**
 * Struct for holding achievement ID and unlock data for online storage
 * NOTE: OnlineSubsystemSteamworks.AchievementMappings can be setup to automatically handle unlocks and progress toasts for EAUT_Count achievements
 */
struct AchievementData
{
	var int				Id;			// The achievement Id

	var EAchievementUnlockType	UnlockType;		// Method used for interpreting the unlock criteria
	var int				UnlockCriteria;		// Value used to determine when an achievement should be unlocked

	var int				ProgressCriteria;	// Value used to determine when the player should receive a progress message.
								//	A value of '5' will show a message to the player each time 5 steps
								//	have been taken towards unlocking the achievement.
								//	(e.g. a message is shown at 5/20 steps, 10/20 steps and 15/20 steps)
								//	For UnlockType 'EAUT_Bitmask', each added bit counts as a step

	var bool			bDoUnlock;		// whether or not the achievement manager should handle unlocks for this acheivement
								//	(achievements can be setup so OnlineSubsystemSteamworks handles this)
	var bool			bDoProgress;		// whether or not the achievement manager should handle progress toasts for this
								//	achievement (can be setup so OnlineSubsystemSteamworks handles this)
};

/**
 * Current value of an in-progress achievement
 */
struct AchievementValue
{
	var int Id;	// The achievement id
	var int	Value;	// The current achievement value, as retrieved by the AchievementStatsRead object
};


// ===== Variables which should be set in default properties

/** List of achievement data templates, to be used for online storage */
var array<AchievementData> AchievementsArray;


/** Class used for reading achievement stats */
var class<OnlineStatsRead> AchievementStatsReadClass;

/** Class used for writing achievement stats */
var class<OnlineStatsWrite> AchievementStatsWriteClass;


// ===== Runtime variables


/** Runtime storage of achievement values */
var array<AchievementValue> AchievementValues;

/** Whether or not the 'AchievementValues' list has been initialized, by the AchievementStatsRead object */
var bool bInitializedAchievementValues;

/** 'UpdateAchievement' calls, which have been deffered due to 'AchievementValues' not being initialized */
var array<AchievementValue> DeferredAchievementUpdates;

/** StatsRead object containing achievement stats */
var OnlineStatsRead AchievementStatsRead;

/** The number of times stats reads have been tried */
var int ReadStatsCount;


/**
 * Initializes achievement data, if necessary
 */
function Initialize()
{
	ReadAchievementStats();
}

/**
 * Cleans up any runtime variables/delegates, which have not yet been unset
 */
function Cleanup()
{
	AchievementStatsRead = none;

	if (OnlineSub != none)
	{
		OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate(ReadAchievementStatsComplete);
		OnlineSub.StatsInterface.ClearFlushOnlineStatsCompleteDelegate(FlushAchievementStatsComplete);
		OnlineSub.PlayerInterface.ClearUnlockAchievementCompleteDelegate(0, AchievementDone);
	}

	ClearTimer('ReadAchievementStats', Self);
}

// ===== UTPlayerController related achievement functions

/**
 * Updates an achievement value, storing it on the backend, and displaying a progress message or unlocking it where necessary
 *
 * @param AchievementId		The id of the achievement to update (as set in the 'AchievementsArray' list)
 * @param Value			The achievement update value (incremental)
 * @param bSkipCommit		If True, skips writing data to the backend; useful for batch achievement value updates
 */
function UpdateAchievement(int AchievementId, optional int Value = 1, optional bool bSkipCommit)
{
	local bool bUnlockedAchievement;
	local int i, UnlockType, Progress, MaxProgress;
	local byte bUnlockEnabled, bProgressEnabled;

	// If the achievement progress is not yet ready to be updated, defer calls to this function
	if (!bInitializedAchievementValues)
	{
		i = DeferredAchievementUpdates.Length;
		DeferredAchievementUpdates.Length = i+1;

		DeferredAchievementUpdates[i].Id = AchievementId;
		DeferredAchievementUpdates[i].Value = Value;

		return;
	}


	// Check the special case of -1 which means the unlock criteria has already been checked, so just unlock it
	if (Value != -1)
	{
		if (GetAchievementUnlockType(AchievementId, UnlockType, bUnlockEnabled))
		{
			if (UnlockType == EAUT_Count)
				bUnlockedAchievement = UpdateAchievementCount(AchievementId, Value, Progress, MaxProgress, bProgressEnabled);
			else if (UnlockType == EAUT_BitMask)
				bUnlockedAchievement = UpdateAchievementBitMask(AchievementId, Value, Progress, MaxProgress, bProgressEnabled);
			else if (UnlockType == EAUT_ByteCount)
				bUnlockedAchievement = UpdateAchievementByteCount(AchievementId, Value);


			if (!bSkipCommit)
			{
				// Save the updated achievement values
				WriteAchievementStats();
			}
		}
		else
		{
			`log("Failed to get unlock type for achievement "$AchievementId);
		}
	}
	else
	{
		// Special case for the 64 bit bitmask achievements, just unlock it
		bUnlockedAchievement = True;
	}

	// If in updating, you exceeded the unlock requirement, unlock the achievement
	if (bUnlockedAchievement)
	{
		if (bool(bUnlockEnabled))
			UnlockAchievement(AchievementId);
	}
	// If the achievement is due a progress status update, display this
	else if (Progress != -1)
	{
		if (bool(bProgressEnabled))
			DisplayAchievementProgress(AchievementId, Progress, MaxProgress);
	}
}


// ===== Code for handling achievement progress notification and unlocks

/**
 * Unlocks the specified achievement through the online subsystem
 * NOTE: For mods which can't use Steam achievements, this function can be overridden to implement your own unlock functionality
 *
 * @param AchievementId		The achievement id to unlock (as specified by the 'AchievementsArray' list)
 */
function UnlockAchievement(int AchievementId)
{
	if (OnlineSub != none && OnlineSub.PlayerInterface != none)
	{
		OnlineSub.PlayerInterface.AddUnlockAchievementCompleteDelegate(LocalPlayer(Player).ControllerId, AchievementDone);

		if (!OnlineSub.PlayerInterface.UnlockAchievement(LocalPlayer(Player).ControllerId, AchievementId))
			AchievementDone(False);
	}
	else
	{
		`log("No online subsystem. Can't unlock an achievement");
	}
}

/**
 * Notification that gets called when an attempt to unlock an achievement has completed
 *
 * @param bWasSuccessful	Whether or not the unlock was successful
 */
function AchievementDone(bool bWasSuccessful)
{
	if (!bWasSuccessful)
		`log("UTAchievements: Achievement unlock attempt has failed");

	if (OnlineSub != None && OnlineSub.PlayerInterface != None)
		OnlineSub.PlayerInterface.ClearUnlockAchievementCompleteDelegate(0, AchievementDone);
}


/**
 * Displays a toast popup, which notifies the player of their progress with an achievement
 * NOTE: For mods which can't use Steam achievements, this function can be overridden to implement your own progress display functionality
 *
 * @param AchievementId		The achievement id which is to receive a progress update (as specified by the 'AchievementsArray' list)
 * @param Progress		The current number of steps completed
 * @param MaxProgress		The total number of steps needed to unlock the achievement
 */
function DisplayAchievementProgress(int AchievementId, int Progress, int MaxProgress)
{
	// NOTE: This has been disabled, so as not to reference OnlineSubsystemSteamworks directly.
	//		All EAUT_Count achievements can instead utilize OnlineSubsystemSteamworks.AchievementMappings to popup toasts automatically;
	//		however, if you want to have progress toasts for EAUT_Bitmask, you need to uncomment the code below, and disable automatic
	//		progress messages in AchievementMappings

	//if (OnlineSub != none && OnlineSubsystemSteamworks(OnlineSub) != none)
	//	OnlineSubsystemSteamworks(OnlineSub).DisplayAchievementProgress(AchievementId, Progress, MaxProgress);
}


// ===== Achievement functions related to progress tracking

/**
 * Update an achievement int by treating it as a bitmask
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param BitMask		The bitmask value to apply to the current achievement value
 * @param Progress		If the achievement should have it's progress announced, returns the current progress (-1 otherwise)
 * @param MaxProgress		The unlock criteria for the achievement
 * @param bProgressEnabled	whether or not progress toasts are enabled for this achievement
 * @return			Returns True if the achievement should be unlocked, False otherwise
 */
function bool UpdateAchievementBitMask(int AchievementId, int BitMask, optional out int Progress, optional out int MaxProgress,
					optional out byte bProgressEnabled)
{
	local bool bUnlocked;
	local int OldValue, Value, UnlockCriteria, ProgressCriteria, i, BitCount, BitMax;

	Progress = -1;
	MaxProgress = -1;

	if (GetAchievementValue(AchievementId, Value))
	{
		if (GetAchievementUnlockCriteria(AchievementId, UnlockCriteria))
		{
			// Always mask out any bits outside the unlock criteria
			OldValue = Value;
			Value = Value | (BitMask & UnlockCriteria);

			if (OldValue != Value)
			{
				if (SetAchievementValue(AchievementId, Value))
				{
					bUnlocked = (Value & UnlockCriteria) == UnlockCriteria;

					if (!bUnlocked && GetAchievementProgressCriteria(AchievementId, ProgressCriteria, bProgressEnabled) &&
						ProgressCriteria > 0)
					{
						// Count the number of unlocked bits, and the maximum bitcount
						for (i=1; i<=UnlockCriteria; i=i<<1)
						{
							if (bool(Value & i))
								++BitCount;

							++BitMax;
						}

						if ((BitCount % ProgressCriteria) == 0)
						{
							Progress = BitCount;
							MaxProgress = BitMax;
						}
					}
				}
				else
				{
					`warn("Failed to set achievement bitmask for"@AchievementId);
				}
			}
		}
		else
		{
			`warn("Failed to find achievement"@AchievementId@"in achievements array");
		}
	}
	else
	{
		`warn("Failed to get achievement bitmask for"@AchievementId);
	}


	return bUnlocked;
}

/**
 * Increment an achievement value (e.g. to keep track of how many times a particular event has happened)
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param Count			The amount to increment by
 * @param Progress		If the achievement should have it's progress announced, returns the current progress (-1 otherwise)
 * @param MaxProgress		The unlock criteria for the achievement
 * @param bProgressEnabled	whether or not progress toasts are enabled for this achievement
 * @return			Returns True if the achievement should be unlocked, False otherwise
 */
function bool UpdateAchievementCount(int AchievementId, optional int Count=1, optional out int Progress, optional out int MaxProgress,
					optional out byte bProgressEnabled)
{
	local bool bUnlocked;
	local int Value, UnlockCriteria, ProgressCriteria;

	Progress = -1;
	MaxProgress = -1;

	if (GetAchievementValue(AchievementId, Value))
	{
		if (Count != 0)
		{
			Value += Count;

			if (SetAchievementValue(AchievementId, Value))
			{
				if (GetAchievementUnlockCriteria(AchievementId, UnlockCriteria))
				{
					bUnlocked = Value >= UnlockCriteria;

					if (!bUnlocked && GetAchievementProgressCriteria(AchievementId, ProgressCriteria, bProgressEnabled) &&
						ProgressCriteria > 0)
					{
						if ((Value % ProgressCriteria) == 0)
						{
							Progress = Value;
							MaxProgress = UnlockCriteria;
						}
					}
				}
				else
				{
					`warn("Failed to find achievement"@AchievementId@"in achievements array");
				}
			}
			else
			{
				`warn("Failed to set achievement count for"@AchievementId);
			}
		}
	}
	else
	{
		`warn("Failed to get achievement count for"@AchievementId);
	}


	return bUnlocked;
}

/**
 * Update an achievement int by treating it as 4 byte sized counters, and comparing the value against a bitmask
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param Counter		The achievement counter index to be updated
 * @return			Returns True if the achievement should be unlocked, False otherwise
 */
function bool UpdateAchievementByteCount(int AchievementId, int Counter)
{
	local bool bUnlocked;
	local int Value, Mask, OldValue, UnlockCriteria, i;
	local byte bUnlockedByte[4];

	if (GetAchievementValue(AchievementId, Value))
	{
		// Add to the appropriate counter and don't wrap the counter
		Mask = 0xFF << (Counter * 8);

		if ((Value & Mask) != Mask)
		{
			OldValue = Value;
			Value += 1 << (Counter * 8);

			if (Value != OldValue)
			{
				if (SetAchievementValue(AchievementId, Value))
				{
					if (GetAchievementUnlockCriteria(AchievementId, UnlockCriteria))
					{
						for (i=0; i<4; ++i)
						{
							Mask = 0xFF << (i * 8);
							bUnlockedByte[i] = byte((Value & Mask) >= (UnlockCriteria & Mask));
						}

						bUnlocked = bool(bUnlockedByte[0] + bUnlockedByte[1] + bUnlockedByte[2] + bUnlockedByte[3]);
					}
					else
					{
						`warn("Failed to find achievement"@AchievementId@"in achievements array");
					}
				}
				else
				{
					`warn("Failed to set achievement count for"@AchievementId);
				}
			}
		}
	}
	else
	{
		`warn("Failed to get achievement count for"@AchievementId);
	}


	return bUnlocked;
}

/**
 * Returns the stored achievement value
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param Value			Returns the stored value for this achievement
 * @return			Returns True if successful, False otherwise
 */
function bool GetAchievementValue(int AchievementId, out int Value)
{
	local bool bSuccess;
	local int AchievementIdx;

	if (bInitializedAchievementValues)
	{
		AchievementIdx = AchievementValues.Find('Id', AchievementId);

		if (AchievementIdx != INDEX_None)
		{
			Value = AchievementValues[AchievementIdx].Value;
			bSuccess = True;
		}
	}

	return bSuccess;
}

/**
 * Sets the stored value for an achievement
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param Value			The value to store for this achievement
 * @return			Returns True if successful, False otherwise
 */
function bool SetAchievementValue(int AchievementId, int Value)
{
	local bool bSuccess;
	local int AchievementIdx;

	if (bInitializedAchievementValues)
	{
		AchievementIdx = AchievementValues.Find('Id', AchievementId);

		if (AchievementIdx != INDEX_None)
		{
			AchievementValues[AchievementIdx].Value = Value;
			bSuccess = True;
		}
	}

	return bSuccess;
}

/**
 * Returns the unlock criteria value for an achievement
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param UnlockCriteria	Returns the unlock criteria for this achievement
 * @return			Returns True if successful, False otherwise
 */
final function bool GetAchievementUnlockCriteria(int AchievementId, out int UnlockCriteria)
{
	local bool bSuccess;
	local int i;

	for (i=0; i<AchievementsArray.Length; ++i)
	{
		if (AchievementId == AchievementsArray[i].Id)
		{
			UnlockCriteria = AchievementsArray[i].UnlockCriteria;
			bSuccess = True;

			break;
		}
	}


	return bSuccess;
}

/**
 * Returns the progress criteria value for an achievement
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param ProgressCriteria	Returns the progress criteria for this achievement
 * @param bProgressEnabled	whether or not progress toasts are enabled for this achievement
 * @return			Returns True if successful, False otherwise
 */
final function bool GetAchievementProgressCriteria(int AchievementId, out int ProgressCriteria, optional out byte bProgressEnabled)
{
	local bool bSuccess;
	local int i;

	for (i=0; i<AchievementsArray.Length; ++i)
	{
		if (AchievementId == AchievementsArray[i].Id)
		{
			ProgressCriteria = AchievementsArray[i].ProgressCriteria;
			bProgressEnabled = byte(AchievementsArray[i].bDoProgress);
			bSuccess = True;

			break;
		}
	}


	return bSuccess;
}

/**
 * Returns the unlock type for an achievement
 *
 * @param AchievementId		The ID of the achievement, as determined by the 'AchievmentsArray' list
 * @param UnlockType		Returns the unlock type for this achievement
 * @param bUnlockEnabled	whether or not unlocking is enabled for this achievement
 * @return			Returns True if successful, False otherwise
 */
final function bool GetAchievementUnlockType(int AchievementId, out int UnlockType, optional out byte bUnlockEnabled)
{
	local bool bSuccess;
	local int i;

	for (i=0; i<AchievementsArray.Length; ++i)
	{
		if (AchievementId == AchievementsArray[i].Id)
		{
			UnlockType = AchievementsArray[i].UnlockType;
			bUnlockEnabled = byte(AchievementsArray[i].bDoUnlock);
			bSuccess = True;

			break;
		}
	}


	return bSuccess;
}


// ===== Code for setting/getting achievement progress data to/from the stats system

/**
 * Kicks off a stats read within the online subsystem, for retrieving the currently stored achievement progress stats
 * NOTE: ReadAchievementStatsComplete is called when this finishes
 */
function ReadAchievementStats()
{
	local array<UniqueNetId> UIDList;

	ClearTimer('ReadAchievementStats', Self);

	if (OnlineSub != none)
	{
		AchievementStatsRead = new AchievementStatsReadClass;

		if (AchievementStatsRead != none)
		{
			OnlineSub.StatsInterface.AddReadOnlineStatsCompleteDelegate(ReadAchievementStatsComplete);

			UIDList.AddItem(PlayerReplicationInfo.UniqueId);

			if (!OnlineSub.StatsInterface.ReadOnlineStats(UIDList, AchievementStatsRead))
			{
				OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate(ReadAchievementStatsComplete);

				// Wait 15 seconds for the current read to complete
				if (ReadStatsCount < 15)
				{
					ReadStatsCount++;
					SetTimer(1.0, True, nameof(ReadAchievementStats), Self);
				}
				else
				{
					`log("UTAchievements: Failed to read achievement stats from online subsystem");
					ReadStatsCount = 0;
				}
			}
			else
			{
				ReadStatsCount = 0;
			}
		}
	}
}

/**
 * Callback which is triggered when the online subsystem finishes reading stats into the 'AchievementStatsRead' object
 *
 * @param bWasSuccessful	Whether or not the stats read was successful
 */
function ReadAchievementStatsComplete(bool bWasSuccessful)
{
	local int i, j, CurValue;

	if (!bWasSuccessful)
	{
		`log("UTAchievements: Failed to read online achievement stats");
		return;
	}

	// Read all the achievements (based on the 'AchievmentsArray' list) into the 'AchievementValues' array
	for (i=0; i<AchievementsArray.Length; ++i)
	{
		j = AchievementStatsRead.ColumnIds.Find(AchievementsArray[i].Id);

		if (j != INDEX_NONE)
		{
			if (AchievementStatsRead.GetIntStatValueForPlayer(PlayerReplicationInfo.UniqueId, j, CurValue))
			{
				j = AchievementValues.Length;
				AchievementValues.Length = j+1;

				AchievementValues[j].Id = AchievementsArray[i].Id;
				AchievementValues[j].Value = CurValue;
			}
		}
	}

	bInitializedAchievementValues = True;

	AchievementStatsRead = none;
	OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate(ReadAchievementStatsComplete);


	// If there are any deferred calls to 'UpdateAchievement' pending, call them now
	for (i=0; i<DeferredAchievementUpdates.Length; ++i)
	{
		UpdateAchievement(DeferredAchievementUpdates[i].Id, DeferredAchievementUpdates[i].Value,
					i != (DeferredAchievementUpdates.Length-1));
	}

	DeferredAchievementUpdates.Length = 0;
}

/**
 * Takes the achievement values within the 'AchievementValues' array, and writes them out to the online subsystem stats
 * NOTE: FlushAchievementStatsComplete is called when this finishes
 */
function WriteAchievementStats()
{
	local OnlineStatsWrite StatsWriteObj;
	local int i;

	if (AchievementValues.Length > 0)
	{
		StatsWriteObj = new AchievementStatsWriteClass;

		if (StatsWriteObj != none)
		{
			for (i=0; i<AchievementValues.Length; ++i)
				StatsWriteObj.SetIntStat(AchievementValues[i].Id, AchievementValues[i].Value);

			if (OnlineSub.StatsInterface.WriteOnlineStats('Game', PlayerReplicationInfo.UniqueId, StatsWriteObj))
			{
				OnlineSub.StatsInterface.AddFlushOnlineStatsCompleteDelegate(FlushAchievementStatsComplete);

				if (!OnlineSub.StatsInterface.FlushOnlineStats('Game'))
				{
					OnlineSub.StatsInterface.ClearFlushOnlineStatsCompleteDelegate(FlushAchievementStatsComplete);

					`log("UTAchievements: Failed to flush achievement stats to online subsystem backend");
				}
			}
			else
			{
				`log("UTAchievements: Failed to write achievment stats to online subsystem");
			}
		}
	}
}

/**
 * Called when an attempt to write the achievement stats to the online subsystem backend has completed
 *
 * @param bWasSuccessful	Whether or not the stats write/flush completed successfully
 */
function FlushAchievementStatsComplete(name SessionName, bool bWasSuccessful)
{
	if (!bWasSuccessful)
		`log("UTAchievements: Achievement stats flush attempt failed");

	OnlineSub.StatsInterface.ClearFlushOnlineStatsCompleteDelegate(FlushAchievementStatsComplete);
}




