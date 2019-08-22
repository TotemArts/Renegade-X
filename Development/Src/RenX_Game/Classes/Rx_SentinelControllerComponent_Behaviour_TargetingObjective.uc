//=============================================================================
// Trying to shoot at an objective, e.g. a Power Node.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_TargetingObjective extends Rx_SentinelControllerComponent_Behaviour;

/** Objective that the Sentinel is attacking. */
var UTGameObjective Objective;

function BeginBehaviour()
{
	Enemy = none;
	Focus = Objective;
	bEnemyIsVisible = true;
	Cannon.SetTarget(Objective, Objective.GetHumanReadableName());
}

function EndBehaviour()
{
	Objective = none;
	ClearTimer('NotVisibleTimer');
}

function ComponentSeePlayer(Pawn Seen)
{
	PawnTargetingBehaviour.ComponentSeePlayer(Seen);
}

function ComponentNotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> DamageType, Vector Momentum)
{
	PawnTargetingBehaviour.ComponentNotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

function ComponentNotVisibleTimer()
{
	ChangeBehaviourTo(IdleBehaviour);
}

function ComponentTick()
{
	local Vector AimSpot;
	local Rotator AimRotation;
	local bool bCanHit;

	if(Objective == none)
	{
		ChangeBehaviourTo(IdleBehaviour);
		return;
	}
	else if(!bForceTarget || Focus == none)
	{
		Focus = Objective;
	}

	bCanHit = AimingComponent.FindAimToHit(Focus, AimSpot, AimRotation);
	Cannon.DesiredAim = AimRotation;
	SetRotation(Cannon.GetViewRotation());
	SetFocalPoint(AimSpot);

	//Possibly fire.
	if(bCanHit && !bForceTarget && Cannon.SWeapon.bCanFire)
	{
		if(IsValidObjective(Objective))
		{
			if(LineOfSightTo(Objective) && Cannon.FireAt(AimSpot))
			{
				ClearTimer('NotVisibleTimer');
			}
			else if(!IsTimerActive('NotVisibleTimer'))
			{
				SetTimer(TargetWaitTime, false, 'NotVisibleTimer');
			}
		}
		else
		{
			Objective = none;
		}
	}
}

/**
 * Returns a number representing how important it is to attack the objective.
 */
function float ObjectiveTargetPriority(UTGameObjective ObjectiveTarget)
{
	local float Weight;

	//Closer objectives are better.
	Weight = 1.0 - (VSize(ObjectiveTarget.Location - Cannon.Location) / Cannon.GetRange());
	//Prefer higher priority objectives.
	Weight += FMin(1.0, float(ObjectiveTarget.DefensePriority) / 5.0);

	return Weight;
}

/**
 * Checks that the objective is currently attackable.
 */
function bool IsValidObjective(UTGameObjective PotentialObjective)
{
	local bool bResult;

	bResult = true;

	if(PotentialObjective == none || PotentialObjective.bIsDisabled || !PotentialObjective.Shootable())
	{
		bResult = false;
	}
	else if(PotentialObjective.DefenderTeamIndex == GetTeamNum())
	{
		bResult = false;
	}
	/*if(PotentialObjective.IsA('UTOnslaughtObjective') && !UTOnslaughtObjective(PotentialObjective).PoweredBy(GetTeamNum()))
	{
		bResult = false;
	}*/
	else if(VSizeSq(PotentialObjective.Location - Cannon.Location) > Square(Cannon.GetRange()))
	{
		bResult = false;
	}

	return bResult;
}

defaultproperties
{
}