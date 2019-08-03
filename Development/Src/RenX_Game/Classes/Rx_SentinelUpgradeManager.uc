//=============================================================================
// Handles creating inventory and weapons etc.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelUpgradeManager extends Actor;

/** Owning Sentinel. */
var Rx_Sentinel Cannon;
/** Linked list of upgrades (including current weapon). */
var Rx_SentinelUpgrade Upgrade;
/** Arrays holding allowed upgrades. Mostly for use by bots. */
var array< class<Rx_SentinelUpgrade> > UpgradeClasses, WeaponClasses;
///** DataStore that handles all the upgrade classes. */
//var class<UTUIDataStore_Rx_SentinelUpgrades> UpgradeDataStoreClass;

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		Cannon, Upgrade;
}

/**
 * Do any setting up necessary for upgrades.
 *
 * @param	S		owning Sentinel
 */
function InitializeFor(Rx_Sentinel S)
{
	local Rx_SentinelUpgrade U;

	SetOwner(S.InstigatorController);
	Instigator = S.Instigator;
	Cannon = S;

	SetBase(S);
	SetRelativeLocation(vect(0.0, 0.0, 0.0));
	SetRelativeRotation(rot(0, 0, 0));

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			U.InitializeFor(Cannon);
		}
	}

//	UpgradeClasses = UpgradeDataStoreClass.static.LoadUpgradeClasses('Upgrades');
//	WeaponClasses = UpgradeDataStoreClass.static.LoadUpgradeClasses('Weapons');
}

/**
 * Determines if there are any upgrades left to apply.
 *
 * @param	MaxCost		unapplied upgrades that cost more than this will be ignored
 * @param	B			set if this is being asked for a bot, in which case unapplied upgrades will be ignored if they have negative BotDesirability
 * @return	true if there are non-weapon upgrades left unapplied
 */
function bool IsFullyUpgraded(optional int MaxCost, optional UTBot B)
{
	local bool bFullyUpgraded;
	local class<Rx_SentinelUpgrade> UpgradeClass;

	bFullyUpgraded = true;

	foreach UpgradeClasses(UpgradeClass)
	{
		if(AllowUpgrade(UpgradeClass) && (MaxCost == 0 || MaxCost >= UpgradeClass.default.AmmoCost) && (B == none || UpgradeClass.static.BotDesirability(B, Cannon) >= 0.0))
		{
			bFullyUpgraded = false;
			break;
		}
	}

	return bFullyUpgraded;
}

/**
 * Returns an array of the classes of all applied upgrades, including the weapon.
 */
simulated function array< class<Rx_SentinelUpgrade> > GetAppliedUpgradeClasses()
{
	local array< class<Rx_SentinelUpgrade> > AppliedUpgradeClasses;
	local Rx_SentinelUpgrade U;

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			AppliedUpgradeClasses.AddItem(U.Class);
		}
	}

	return AppliedUpgradeClasses;
}

/**
 * Spawn an upgrade and add it to the list.
 *
 * @param	NewUpgradeClass		class of upgrade to spawn
 * @return	the upgrade that was spawned, if any
 */
function Rx_SentinelUpgrade CreateUpgrade(class<Rx_SentinelUpgrade> NewUpgradeClass)
{
	local Rx_SentinelUpgrade NewUpgrade;

	if(AllowUpgrade(NewUpgradeClass))
	{
		NewUpgrade = Spawn(NewUpgradeClass, Cannon);

		if(NewUpgrade != none)
		{
			AddUpgrade(NewUpgrade);
		}
		else
		{
			`warn("Failed to create an upgrade:"@NewUpgradeClass@"for:"@Instigator.Controller);
		}
	}
	else
	{
		`warn("Tried to create a disallowed upgrade:"@NewUpgradeClass@"for:"@Instigator.Controller);
	}

	return NewUpgrade;
}

/**
 * Add an upgrade to the list. If it's a new weapon, the Sentinel's existing weapon will be removed.
 *
 * @param	NewUpgrade	upgrade to add to the list
 */
function AddUpgrade(Rx_SentinelUpgrade NewUpgrade)
{
	NewUpgrade.SetBase(Cannon);
	NewUpgrade.SetRelativeLocation(vect(0.0, 0.0, 0.0));
	NewUpgrade.SetRelativeRotation(rot(0, 0, 0));
	NewUpgrade.InitializeFor(Cannon);
	NewUpgrade.NextUpgrade = none; //Prevent list becoming circular. Well, you never know, it could happen.

	if(Upgrade == none)
		Upgrade = NewUpgrade;
	else
		Upgrade.AddUpgrade(NewUpgrade);

	LogInternal(upgrade@"upgrade...");

	if(NewUpgrade.IsA('Rx_SentinelWeapon'))
	{
		if(Cannon.SWeapon != none)
		{
			RemoveUpgrade(Cannon.SWeapon);
		}

		Cannon.SetWeapon(Rx_SentinelWeapon(NewUpgrade));
		Cannon.UpdateRange(); 
	}

	ForceUpgradeNetUpdates();
}

/**
 * Determines if an upgrade may be applied to the owning Sentinel
 *
 * @param	NewUpgradeClass		class of upgrade to check
 * @return	true if all conditions for allowing the upgrade are met, false otherwise
 */
simulated function bool AllowUpgrade(class<Rx_SentinelUpgrade> NewUpgradeClass)
{
//	local bool bResult;

    return true;

//	bResult = NewUpgradeClass != none;
//	//Can't have upgrades which are already applied.
//	bResult = bResult && !HasUpgrade(NewUpgradeClass);
//	//Ask upgrade if it will fit.
//	bResult = bResult && NewUpgradeClass.static.AllowUpgrade(Cannon);
//
//	return bResult;
}

/**
 * Determines if an upgrade is already in the possession of the owning Sentinel
 *
 * @param	NewUpgradeClass		class of upgrade to look for
 * @param	bIncludeSubclasses	if true, then subclasses of NewUpgradeClass are considered to be equivalent, otherwise only an exact class match is counted
 * @return	true if upgrade found, false otherwise
 */
simulated function bool HasUpgrade(class<Rx_SentinelUpgrade> NewUpgradeClass, optional bool bIncludeSubclasses)
{
	local Rx_SentinelUpgrade U;

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			if(U.Class == NewUpgradeClass || (bIncludeSubclasses && ClassIsChildOf(U.Class, NewUpgradeClass)))
			{
				return true;
			}
		}
	}

	return false;
}

/**
 * @return	an upgrade of class UpgradeClass, or none if this Sentinel doesn't have one.
 */
simulated function Rx_SentinelUpgrade GetUpgrade(class<Rx_SentinelUpgrade> UpgradeClass)
{
	local Rx_SentinelUpgrade U;

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			if(U.Class == UpgradeClass)
			{
				break;
			}
		}
	}

	return U;
}

/**
 * @param	U		an upgrade currently applied to this Sentinel
 * @return	true if the upgrade should not be removed, either because it's a default upgrade or it is a prerequisite for another upgrade
 */
function bool RequiresUpgrade(Rx_SentinelUpgrade U)
{
	return Upgrade.RequiresUpgrade(U) || Cannon.DefaultUpgradeClasses.Find(U.Class) != INDEX_NONE;
}

/**
 * Removes an upgrade from the list and destroys it.
 *
 * @param	UpgradeToRemove		upgrade to remove
 */
function RemoveUpgrade(Rx_SentinelUpgrade UpgradeToRemove)
{
	local Rx_SentinelUpgrade U;

	U = DetachUpgrade(UpgradeToRemove);

	if(U != none)
	{
		U.Destroy();
		ForceUpgradeNetUpdates();
	}
}

/**
 * Removes an upgrade from the list, but does not destroy it, so it can potentially be used elsewhere.
 * Please note that any upgrade that is removed from the list in any way should first be detached via this function so that all other upgrades know it has been removed.
 * @todo	Maybe reinitialize all upgrades in case the removed one reset a variable or something.
 *
 * @param	UpgradeToDetach		the upgrade to detach
 * @return	the detached upgrade, or none if it wasn't in the list
 */
function Rx_SentinelUpgrade DetachUpgrade(Rx_SentinelUpgrade UpgradeToDetach)
{
	local Rx_SentinelUpgrade DetachedUpgrade;

	DetachedUpgrade = Upgrade != none ? Upgrade.DetachUpgrade(UpgradeToDetach) : none;

	if(DetachedUpgrade != none)
	{
		if(DetachedUpgrade == Upgrade)
		{
			Upgrade = DetachedUpgrade.NextUpgrade;
		}

		DetachedUpgrade.NextUpgrade = none;

		ForceUpgradeNetUpdates();
	}

	return DetachedUpgrade;
}

/**
 * Destroys an upgrade that is not a weapon or a default upgrade, and not a prerequisite for any other applied upgrades.
 */
function DestroyRandomUpgrade()
{
	local Rx_SentinelUpgrade U;
	local array<Rx_SentinelUpgrade> DestroyableUpgrades;

	U = Upgrade;

	while(U != none)
	{
		if(Rx_SentinelWeapon(U) == none && !RequiresUpgrade(U))
		{
			DestroyableUpgrades.AddItem(U);
		}

		U = U.NextUpgrade;
	}

	if(DestroyableUpgrades.Length > 0)
	{
		RemoveUpgrade(DestroyableUpgrades[Rand(DestroyableUpgrades.Length - 1)]);
	}
}

/**
 * Destroys all upgrades.
 */
function DestroyAllUpgrades()
{
//	while(Upgrade != none)
//	{
		RemoveUpgrade(Upgrade);
//	}
}

/**
 * Force an immediate net update for all upgrades, self and Sentinel.
 * @todo	This doesn't really help much.
 */
function ForceUpgradeNetUpdates()
{
	local Rx_SentinelUpgrade U;

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			U.bForceNetUpdate = true;
			U.bNetDirty = true;
		}
	}

	bForceNetUpdate = true;
	bNetDirty = true;

	Cannon.bForceNetUpdate = true;
	Cannon.bNetDirty = true;
}

/**
 * Determines how much ammo these upgrades might yield if recycled.
 *
 * @return	value of all upgrades in ammo
 */
function int AmmoValue()
{
	local int value;
	local Rx_SentinelUpgrade U;

	if(Upgrade != none)
	{
		for(U = Upgrade; U != none; U = U.NextUpgrade)
		{
			value += U.AmmoValue();
		}
	}

	return value;
}

simulated function GetStatusText(out array<String> StatusStrings)
{
	if(Upgrade != none)
	{
		Upgrade.GetStatusText(StatusStrings);
	}
}

//=============================================================================
// Hooks:
//=============================================================================

/**
 * Allows upgrades to influence controller target choice.
 */
function ModifyPawnTargetPriority(out float Weight, Pawn PawnTarget)
{
	if(Upgrade != none)
		Upgrade.ModifyPawnTargetPriority(Weight, PawnTarget);
}

/**
 * Called when a bot wants to determine its strength relative to the Sentinel. Upgrades should add to Strength if they increase the Sentinel's combat power.
 */
function AdjustStrength(out float Strength)
{
	if(Upgrade != none)
		Upgrade.AdjustStrength(Strength);
}

/**
 * Allows upgrades to sense normally undetectable (i.e. invisible) pawns.
 */
function bool CanDetect(Pawn P)
{
	return Upgrade != none && Upgrade.CanDetect(P);
}

/*
 * A chance for upgrades to modify damage taken by Sentinel.
 */
function NotifyTakeDamage(out int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if(Upgrade != none)
		Upgrade.NotifyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

/*
 * Notifies upgrades that a new enemy has been targeted. Do not call this with a NewTarget of none!
 */
function NotifyNewTarget(Actor NewTarget)
{
	if(Upgrade != none)
		Upgrade.NotifyNewTarget(NewTarget);
}

/*
 * Notifies upgrades that the owning Sentinel fired its weapon.
 */
function NotifyFired()
{
	if(Upgrade != none)
		Upgrade.NotifyFired();
}

/*
 * Notifies upgrades that the owning Sentinel has become idle.
 */
function NotifyWaiting()
{
	if(Upgrade != none)
		Upgrade.NotifyWaiting();
}

/*
 * Notifies upgrades that the owning Sentinel has been destroyed.
 */
function NotifyDied(Controller Killer, out class<DamageType> DamageType, vector HitLocation)
{
	if(Upgrade != none)
	{
		Upgrade.NotifyDied(Killer, DamageType, HitLocation);
	}

	//Detach the weapon so it can still be accessed by the Sentinel, for effects.
	if(Cannon.SWeapon != none)
	{
		Cannon.SWeapon.LifeSpan = Cannon.DeadLifeSpan;
		DetachUpgrade(Cannon.SWeapon);
	}
}

simulated function Destroyed()
{
	DestroyAllUpgrades();
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local Rx_SentinelUpgrade U;

	HUD.Canvas.SetDrawColor(255, 255, 0);
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("Weapon:");
	out_YPos += out_YL;
	HUD.Canvas.SetPos(8, out_YPos);

	HUD.Canvas.DrawText(Cannon.SWeapon);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("Upgrades:");
	out_YPos += out_YL;
	HUD.Canvas.SetPos(8, out_YPos);

	for(U = Upgrade; U != none; U = U.NextUpgrade)
	{
		if(Rx_SentinelWeapon(U) == none)
		{
			HUD.Canvas.DrawText(U);
			out_YPos += out_YL;
			HUD.Canvas.SetPos(8, out_YPos);
		}
	}
}

defaultProperties
{
//	UpgradeDataStoreClass=class'UTUIDataStore_Rx_SentinelUpgrades'

	bHardAttach=true
	bNoEncroachCheck=true
	bIgnoreEncroachers=true
	bPushedByEncroachers=false
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true


	RemoteRole=ROLE_SimulatedProxy
	NetPriority=1.4
	NetUpdateFrequency=1

}
