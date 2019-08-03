class Rx_Mutator extends UTMutator
	abstract;

function OnBuildingDestroyed(PlayerReplicationInfo Destroyer, Rx_Building_Team_Internals BuildingInternals, Rx_Building Building, class<DamageType> DamageType)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBuildingDestroyed(Destroyer, BuildingInternals, Building, DamageType);
	}
}

function OnPlayerKill(Controller Killer, Controller Victim, Pawn KilledPawn, class<DamageType> damageType)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnPlayerKill(Killer, Victim, KilledPawn, damageType);
	}
}

function OnMatchStart()
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnMatchStart();
	}
}

function OnMatchEnd()
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnMatchEnd();
	}
}

function OnPlayerDisconnect(Controller PlayerLeaving)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnPlayerDisconnect(PlayerLeaving);
	}
}

function OnPlayerConnect(PlayerController NewPlayer, string SteamID)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnPlayerConnect(NewPlayer, SteamID);
	}
}

function OnTeamSurrender(int TeamID)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnTeamSurrender(TeamID);
	}
}

function Rx_CrateType OnDetermineCrateType(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		return Rx_Mut.OnDetermineCrateType(Recipient, CratePickup);
	} else
		return None;
}

function string OnCratePickupMessageBroadcastPre(int CrateMesageID, PlayerReplicationInfo PRI)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		return Rx_Mut.OnCratePickupMessageBroadcastPre(CrateMesageID, PRI);
	} else
		return "";
}

function bool OverridesPawnInFriendlyBase()
{
	return false;
}

function bool PawnInFriendlyBase(coerce string LocationInfo, Pawn P)
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		return Rx_Mut.PawnInFriendlyBase(LocationInfo, P);
	} else
		return false;
}

function OnBeforeTeamShuffling()
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBeforeTeamShuffling();
	}
}

function OnAfterTeamShuffling()
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetNextRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnAfterTeamShuffling();
	}
}

function bool ShuffleTeamsNextMatch()
{
	return false;
}

function bool AdjustTeamBalance()
{
	return false;
}

function bool AdjustTeamSize()
{
	return false;
}

/** Gets the next Rx_Mutator in the list (required for Rx_Mutator specific hooks) */
function Rx_Mutator GetNextRxMutator()
{
	local Mutator M;

	for (M = NextMutator; M != None; M = M.NextMutator)
	{
		if (Rx_Mutator(M) != None)
			return Rx_Mutator(M);
	}

	return None;
}

function String GetAdditionalServersettings();
function InitRconCommands();