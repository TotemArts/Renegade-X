//=============================================================================
// A bit like an Inventory item.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelUpgrade extends Actor
	abstract;

/** Display name for this upgrade. */
var string FriendlyName;
/** Description of this upgrade. */
var string Description;

/** Owning Sentinel. */
var repnotify Rx_Sentinel Cannon;
/** Next in linked list of upgrades. */
var Rx_SentinelUpgrade NextUpgrade;

/** Amount of Deployer ammo needed to apply this upgrade. */
var() int AmmoCost;
/** Types of Sentinel which this upgrade will fit. */
var() array< class<Rx_Sentinel> > CompatibleSentinels;
/** These upgrades must have been applied already for this upgrade to be allowed. */
var() array< class<Rx_SentinelUpgrade> > RequiredUpgrades;
/** These upgrades must not be present for this upgrade to be allowed. Note that an upgrade that is forbidden must itself forbid this upgrade, or it won't work properly. */
var() array< class<Rx_SentinelUpgrade> > ForbiddenUpgrades;

/** Played when upgrade is first applied. */
var() SoundCue ActivateSound;
/** Played when upgrade is removed. */
var() SoundCue DeactivateSound;


/** Maximum desireability this upgrade will ever have, before random variation. */
var() float MaxDesirability;
/** Represents how much stronger this upgrade makes the Sentinel in combat. Not used by default, subclasses may add this to "Strength" in "AdjustStrength". */
var() float ExtraStrength;

var bool bInitialized;
var	bool bRenderOverlays;

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		Cannon, NextUpgrade;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'Cannon')
	{
		if(Cannon != none && !bInitialized)
		{
			ClientInitializeFor();
		}
	}
}

function InitializeFor(Rx_Sentinel S)
{
	SetOwner(S.InstigatorController);
	Instigator = S.Instigator;
	Cannon = S;

	ClientInitializeFor();
}

/**
 * Called when Cannon is replicated, to allow client-side alterations to be made.
 */
simulated function ClientInitializeFor()
{
	bInitialized = true;

	if(ActivateSound != none)
	{
		PlaySound(ActivateSound, true,,, Cannon.GetPawnViewLocation());
	}
}

/**
 * Adds a new upgrade to the list. Note that the upgrade must be passed all the way along to the end of the list so that all upgrades receive notification.
 */
function AddUpgrade(Rx_SentinelUpgrade NewUpgrade)
{
	if(NextUpgrade == none)
	{
		NextUpgrade = NewUpgrade;
	}
	else
	{
		NextUpgrade.AddUpgrade(NewUpgrade);
	}
}

/**
 *
 */
function Rx_SentinelUpgrade DetachUpgrade(Rx_SentinelUpgrade UpgradeToDetach)
{
//	local Rx_SentinelUpgrade DetachedUpgrade;
//
//	if(UpgradeToDetach == self)
//	{
//		DetachedUpgrade = self;
//
//		OnDetach();
//	}
//	else if(NextUpgrade != none)
//	{
//		DetachedUpgrade = NextUpgrade.DetachUpgrade(UpgradeToDetach);
//
//		if(DetachedUpgrade != none && DetachedUpgrade == NextUpgrade)
//		{
//			NextUpgrade = NextUpgrade.NextUpgrade;
//		}
//	}
//
//	return DetachedUpgrade;
}



/**
 * @return	true if U is a prerequisite for this upgrade or any subsequent upgrade in the list, false otherwise.
 */
function bool RequiresUpgrade(Rx_SentinelUpgrade U)
{
	local class<Rx_SentinelUpgrade> UpgradeClass;
	local bool bRequired;

	foreach default.RequiredUpgrades(UpgradeClass)
	{
		if(U.Class == UpgradeClass)
		{
			bRequired = true;
			break;
		}
	}

	return bRequired || (NextUpgrade != none && NextUpgrade.RequiresUpgrade(U));
}

function int AmmoValue()
{
	return AmmoCost;
}

simulated function GetStatusText(out array<String> StatusStrings)
{
	if(NextUpgrade != none)
	{
		NextUpgrade.GetStatusText(StatusStrings);
	}
}

function ModifyPawnTargetPriority(out float Weight, Pawn PawnTarget)
{
	if(NextUpgrade != none)
		NextUpgrade.ModifyPawnTargetPriority(Weight, PawnTarget);
}

function AdjustStrength(out float Strength)
{
	if(NextUpgrade != none)
		NextUpgrade.AdjustStrength(Strength);
}

function bool CanDetect(Pawn P)
{
	return NextUpgrade != none && NextUpgrade.CanDetect(P);
}

function NotifyTakeDamage(out int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if(NextUpgrade != none)
		NextUpgrade.NotifyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function NotifyNewTarget(Actor NewTarget)
{
	if(NextUpgrade != none)
		NextUpgrade.NotifyNewTarget(NewTarget);
}

function NotifyFired()
{
	if(NextUpgrade != none)
		NextUpgrade.NotifyFired();
}

function NotifyWaiting()
{
	if(NextUpgrade != none)
		NextUpgrade.NotifyWaiting();
}

function NotifyDied(Controller Killer, out class<DamageType> DamageType, Vector HitLocation)
{
	bRenderOverlays = false;

	if(NextUpgrade != none)
		NextUpgrade.NotifyDied(Killer, DamageType, HitLocation);
}

/**
 * Determines if this upgrade class is permitted to be applied to the given Sentinel.
 *
 * @param	S		Sentinel that wants this upgrade
 * @return	true if all requirements for this upgrade met, false otherwise
 */
static function bool AllowUpgrade(Rx_Sentinel S)
{
	local bool bResult;
	local class<Rx_Sentinel> CompatibleSentinelClass;
	local class<Rx_SentinelUpgrade> UpgradeClass;

	return true; // xxx

	//Sentinel must be of the correct type.
	foreach default.CompatibleSentinels(CompatibleSentinelClass)
	{
		if(ClassIsChildOf(S.Class, CompatibleSentinelClass))
		{
			bResult = true;
			break;
		}
	}

	if(bResult)
	{
		//Prerequisites must be met.
		foreach default.RequiredUpgrades(UpgradeClass)
		{
			if(!S.UpgradeManager.HasUpgrade(UpgradeClass))
			{
				bResult = false;
				break;
			}
		}

		if(bResult)
		{
			//Incompatible upgrades not allowed together.
			foreach default.ForbiddenUpgrades(UpgradeClass)
			{
				if(S.UpgradeManager.HasUpgrade(UpgradeClass))
				{
					bResult = false;
					break;
				}
			}
		}
	}

	return bResult;
}

/**
 * Determines how much a bot should want this upgrade.
 * Positive return values should have a random variability of approximately +/-20%.
 * The return value should be either always positive or always negative for a given Sentinel.
 * The return value should be negative if S is owned by a human and this upgrade class has forbidden upgrade classes.
 *
 * @param	B	the bot that is considering this upgrade
 * @param	S	the Sentinel that the bot wants to apply this upgrade to
 * @return	a number representing the desirability of this upgrade. <0.0 => the bot should not apply this upgrade at all. 0.5 => neutral desirability. 1.0+ => highly desirable
 */
static function float BotDesirability(UTBot B, Rx_Sentinel S)
{
	local float Desirability;

	if(default.ForbiddenUpgrades.length > 0 && PlayerController(S.InstigatorController) != none)
	{
		Desirability = -1.0;
	}
	else
	{
		Desirability = default.MaxDesirability + ((FRand() - 0.5) * default.MaxDesirability * 0.2);
	}

	return Desirability;
}

/**
 * Allows upgrade to render to the HUD.
 */
simulated function RenderOverlays(HUD H);

/**
 * Finds all allied deployers and adds this upgrade to their UpgradesToRender arrays. If bRenderOverlays is true, the Deployers will then call RednderOverlays when needed, and this upgrade can render some stuff to the HUD.
 */
simulated function FindDeployersToRenderFor()
{
//	local PlayerController PC;
//	local UTWeap_SentinelDeployer Deployer;
//
//	if(Cannon != none)
//	{
//		foreach LocalPlayerControllers(class'PlayerController', PC)
//		{
//			if(PC.Pawn != none && Cannon.IsSameTeam(PC.Pawn))
//			{
//				Deployer = UTWeap_SentinelDeployer(PC.Pawn.Weapon);
//
//				if(Deployer != none && Deployer.UpgradesToRender.Find(self) == INDEX_NONE)
//				{
//					Deployer.UpgradesToRender.AddItem(self);
//				}
//			}
//		}
//	}
}



/**
 * Callback from the configuration menu when it is closed.
 */
simulated function ConfigurationMenuClosed(){}

/**
 * Callback from the configuration menu when it is deactivated.
 */
simulated function ConfigurationMenuDeactivated(){}

simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated, optional float VisibleCullDistance=5000.0, optional float HiddenCullDistance=350.0 )
{
	return Cannon.EffectIsRelevant(SpawnLocation, bForceDedicated, VisibleCullDistance, HiddenCullDistance);
}

simulated function Destroyed()
{
	bRenderOverlays = false;



	super.Destroyed();
}

defaultproperties
{
//	CompatibleSentinels.Add(class'Sentinel_Floor')
//	CompatibleSentinels.Add(class'Sentinel_Ceiling')

	MaxDesirability=0.5

	bHardAttach=true
	bNoEncroachCheck=true
	bIgnoreEncroachers=true
	bPushedByEncroachers=false
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true

	
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=1.4
	NetUpdateFrequency=20
	
}
