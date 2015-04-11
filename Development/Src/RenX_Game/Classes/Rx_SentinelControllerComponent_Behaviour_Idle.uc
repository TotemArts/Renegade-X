//=============================================================================
// Waiting for something interesting to happen.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour_Idle extends Rx_SentinelControllerComponent_Behaviour;

function BeginBehaviour()
{
	bEnemyIsVisible = false;
	Enemy = none;
	Focus = none;
	Cannon.SetWaiting();

	//Shouldn't ever be true here, but it happens sometimes for some reason.
	if(WorldInfo.Game.bGameEnded)
	{
		GameHasEnded();
	}
}

function ComponentSeePlayer(Pawn Seen)
{
	PawnTargetingBehaviour.ComponentSeePlayer(Seen);
}

function ComponentHearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	PawnTargetingBehaviour.ComponentHearNoise(Loudness, NoiseMaker, NoiseType);
}

function ComponentNotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> DamageType, Vector Momentum)
{
	PawnTargetingBehaviour.ComponentNotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

function ComponentTick()
{
	local Vector poop;
	SetRotation(Cannon.GetViewRotation());
	poop = Cannon.GetPawnViewLocation() + 512.0 * Vector(Rotation);
	SetFocalPoint(poop);
}

defaultproperties
{
}