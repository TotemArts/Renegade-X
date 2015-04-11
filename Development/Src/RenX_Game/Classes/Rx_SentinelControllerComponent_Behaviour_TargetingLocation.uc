//=============================================================================
// Firing at a location, possibly one that is not visible to the Sentinel.
// Since Sentinels require an actor to focus on, a LocationMarker must be
// placed at the desired location.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_TargetingLocation extends Rx_SentinelControllerComponent_Behaviour;

/** Actor placed at location that the Sentinel is attacking. */
var Rx_Sentinel_LocationMarker TargetLocationMarker;

function BeginBehaviour()
{
	Enemy = none;
	Focus = TargetLocationMarker;
	Cannon.SetTarget(TargetLocationMarker, "");
}

function EndBehaviour()
{
	if(TargetLocationMarker != none)
	{
		TargetLocationMarker.Destroy();
	}

	ClearTimer('NotVisibleTimer');
}

/**
 * Set a location to attack. Must be followed by a call to ChangeBehaviourTo to this behaviour, unless this is the current behaviour already.
 *
 * @param	NewTargetLocation	location to attack
 * @param	AttackTime			time to spend attacking the location before going idle again. Pass 0 or omit completely to attack indefinitely
 */
function SetTargetLocation(Vector NewTargetLocation, optional float AttackTime)
{
	if(TargetLocationMarker == none)
	{
		TargetLocationMarker = Spawn(class'Rx_Sentinel_LocationMarker');
	}

	TargetLocationMarker.SetLocation(NewTargetLocation);

	LastDetectedLocation = NewTargetLocation;
	LastDetectedTime = WorldInfo.TimeSeconds;

	if(AttackTime > 0.0)
	{
		SetTimer(AttackTime, false, 'NotVisibleTimer');
	}
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

	if(TargetLocationMarker == none)
	{
		ChangeBehaviourTo(IdleBehaviour);
		return;
	}
	else if(!bForceTarget || Focus == none)
	{
		Focus = TargetLocationMarker;
	}

	AimingComponent.FindAimToHit(TargetLocationMarker, AimSpot, AimRotation);
	Cannon.DesiredAim = AimRotation;
	SetRotation(Cannon.GetViewRotation());
	SetFocalPoint(AimSpot);

	//Possibly fire.
	if(!bForceTarget && Cannon.SWeapon.bCanFire)
	{
		if(!Cannon.FireAt(AimSpot))
		{
			if(!IsTimerActive('NotVisibleTimer'))
			{
				SetTimer(TargetWaitTime, false, 'NotVisibleTimer');
			}
		}
		else
		{
			ClearTimer('NotVisibleTimer');
		}
	}
}

defaultproperties
{
}