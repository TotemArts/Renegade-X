//=============================================================================
// Attacking a pawn.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_TargetingPawn extends Rx_SentinelControllerComponent_Behaviour;

/** After this many seconds of not being visible, the current target will no longer be given priority over new targets. */
var() float LoseInterestTime;
/** How much the Sentinel wants to forget its current target and retaliate against someone inflicting damage. */
var() float DamageCauserExtraWeight;
/** DamageTypes in this array will not cause the Sentinel to attack the damage causer. */
var() array< class<DamageType> > IgnoredDamageTypes;


function BeginBehaviour()
{
	Focus = Enemy;
}

function EndBehaviour()
{
	ClearTimer('NotVisibleTimer');
}

function ComponentSeePlayer(Pawn Seen)
{

    //Check for best target.
	if(PossiblyTarget(Seen))
	{
        SetTargetInfo(Seen, true, Seen.Location, WorldInfo.TimeSeconds);
		ChangeBehaviourTo(self);
	}
}

function ComponentEnemyNotVisible()
{
	SetTargetInfo(Enemy, false, LastDetectedLocation, LastDetectedTime);
}

function ComponentHearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	//Allows tracking of invisible targets by sound alone.
	if(NoiseType != 'ChangedWeapon') //Why is changing weapons so noisy? Oh well, just ignore it.
	{
		if(PossiblyTarget(NoiseMaker.Instigator))
		{
			SetTargetInfo(NoiseMaker.Instigator, LineOfSightTo(Enemy), NoiseMaker.Location, WorldInfo.TimeSeconds);
			ChangeBehaviourTo(self);
		}
	}
}

function ComponentNotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> DamageType, Vector Momentum)
{
	//Target inflicter of damage if not otherwise engaged.
	if(InstigatedBy != none && IgnoredDamageTypes.Find(DamageType) == INDEX_NONE)
	{
		if(PossiblyTarget(InstigatedBy.Pawn, DamageCauserExtraWeight))
		{
			SetTargetInfo(InstigatedBy.Pawn, LineOfSightTo(Enemy), HitLocation, WorldInfo.TimeSeconds);
			ChangeBehaviourTo(self);
		}
	}
}

function ComponentNotVisibleTimer()
{
	ChangeBehaviourTo(IdleBehaviour);
}

function ComponentTick()
{
	local Vector AimSpot;
	local Rotator AimRotation;

	if(Enemy == none || Enemy.Health <= 0)
	{
		Enemy = none;
		ChangeBehaviourTo(IdleBehaviour);
		return;
	}
	else if(!bForceTarget || Focus == none)
	{
		Focus = Enemy;
	}

	AimingComponent.FindAimToHit(Focus, AimSpot, AimRotation);
	Cannon.DesiredAim = AimRotation;
	SetRotation(Cannon.GetViewRotation());
	SetFocalPoint(AimSpot);


    //Possibly fire.
	if((bEnemyIsVisible || Cannon.SWeapon.bCanFireBlind) && !bForceTarget && Cannon.SWeapon.bCanFire)
	{
		if(PossiblyTarget(Enemy))
		{
			ShotTarget = Enemy;

            if(Cannon.FireAt(AimSpot))
			{
				if(Enemy != none && bEnemyIsVisible)
				{
					SetTargetInfo(Enemy, true, Enemy.Location, WorldInfo.TimeSeconds);
				}
			}
			else
			{
                SetTargetInfo(Enemy, false, Enemy.Location, WorldInfo.TimeSeconds);
			}
		}
		else
		{
			Enemy = none;
		}
	}
}

/**
 * Set target-related variables.
 *
 * @param	NewTarget
 * @param	bCanSee
 * @param	DetectedLocation	location target detected at
 * @param	DetectedTime		time target was detected
 */
function SetTargetInfo(Pawn NewTarget, bool bCanSee, Vector DetectedLocation, float DetectedTime)
{
	Enemy = NewTarget.DrivenVehicle != none ? NewTarget.DrivenVehicle : NewTarget;
	LastDetectedLocation = DetectedLocation;
	LastDetectedTime = DetectedTime;
	bEnemyIsVisible = bCanSee && Cannon.CanDetect(Enemy);

	if(bEnemyIsVisible)
	{
		Cannon.SetTarget(Enemy, Enemy.GetHumanReadableName());
		LastSeenTime = DetectedTime;
		ClearTimer('NotVisibleTimer');
	}
	else if(!IsTimerActive('NotVisibleTimer'))
	{
		Cannon.SetTarget(Enemy);
		//If enemy not re-detected before timer goes off, give up.
		SetTimer(TargetWaitTime, false, 'NotVisibleTimer');
	}
}

/**
 * Decide whether the detected pawn can be shot at or not.
 *
 * @param	PotentialTarget		pawn to check
 * @param	ExtraWeight		bias towards PotentialTarget
 * @return	true if pawn could be attacked, false otherwise
 */
function bool PossiblyTarget(Pawn PotentialTarget, optional int ExtraWeight)
{

    if(PotentialTarget == none) //|| !PotentialTarget.IsValidTargetFor(Cannon.InstigatorController))
		return false;
		
	if(PotentialTarget.Health <= 0) {
		return false;
	}

	//Don't target owner or owner's Sentinels (non-team games).
	if(Cannon.IsSameTeam(PotentialTarget))
		return false;

	//Don't target pawns outside of range (particularly important for Grenade Launcher).
	if(VSize(PotentialTarget.Location - Cannon.Location) > Cannon.GetRange())
		return false;

	//Hook to allow for gun specific visibility checks 
	if(!Cannon.IsVisibleFromGuns(PotentialTarget)) {
		return false;
	}

	//Don't target pawns closer then minimal range (no hurt radius arround Ob and AGT).
	if(!Cannon.IsOutsideMinimalDistToOwner(PotentialTarget)) {
		return false;
	}
	if(!Cannon.SWeapon.CanHit(PotentialTarget)) {
		if(SeenButCoveredPawns.Find(PotentialTarget) == -1) {
			SeenButCoveredPawns.addItem(PotentialTarget);
			if(!IsTimerActive('CheckPreviouslyCoveredTargets')) {
				SetTimer(0.2, true, 'CheckPreviouslyCoveredTargets');
			}
		}
		return false;
	}

	if ( Rx_Game(WorldInfo.Game).SmokeScreenCount > 0 )
	{
		foreach TraceActors(class'Rx_SmokeScreen', DummyActor, DummyHitLoc, DummyHitNorm, PotentialTarget.Location, Cannon.GetPawnViewLocation())
			return false;
	}

	//Always change if current target is dead or nonexistent.
	if(Enemy == none || Enemy.Health <= 0)
		return true;

	//Keep dishing out the punishment until they die or otherwise go away.
	if(PotentialTarget == Enemy)
		return true;

	//Change if new target is more important than current target.
	if(PawnTargetPriority(PotentialTarget, ExtraWeight) > PawnTargetPriority(Enemy))
		return true;

	return false;
}

/**
 * Returns a number representing how important it is to attack the pawn.
 *
 * @param		ExtraWeight		bias towards PawnTarget
 */
function float PawnTargetPriority(Pawn PawnTarget, optional int ExtraWeight)
{
	local float Weight;

	Weight = ExtraWeight;
	//Better to target someone who's nearly dead.
	Weight += 1.0 - (float(PawnTarget.Health) / float(PawnTarget.HealthMax));
	//Prefer closer targets.
	Weight += 1.0 - (VSize(PawnTarget.Location - Cannon.Location) / Cannon.GetRange());
	//Prefer targets that require less rotation to aim at.
	Weight += ((Normal(PawnTarget.GetTargetLocation() - Cannon.GetPawnViewLocation()) dot Vector(Cannon.CurrentAim)) + 1.0) / 2.0;

	if(PawnTarget == Enemy)
	{
		//Prefer to stay on target.
		Weight += 1.0;
		//Less weight for an enemy who has moved out of sight.
		if(!bEnemyIsVisible)
		{
			Weight -= `TimeSince(LastSeenTime) / LoseInterestTime;
		}
	}

	Cannon.UpgradeManager.ModifyPawnTargetPriority(Weight, PawnTarget);

	return Weight;
}

defaultproperties
{
	LoseInterestTime=2.5
	DamageCauserExtraWeight=0.7
}
