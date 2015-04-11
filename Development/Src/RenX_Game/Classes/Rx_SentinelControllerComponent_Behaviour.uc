//=============================================================================
// Component that implements a Sentinel's reaction to various stimuli etc.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Behaviour extends Component
	within Rx_SentinelController
	abstract;

/**
 * Any setting up that needs to be done.
 */
function BeginBehaviour();

/**
 * Any cleaning up that needs to be done.
 */
function EndBehaviour();

function ComponentSeeMonster(Pawn Seen)
{
	//Default behaviour is to treat monsters the same as players. Standard UT3 has no monsters, but this helps with mods that do.
	SeePlayer(Seen);
}

function ComponentSeePlayer(Pawn Seen);
function ComponentEnemyNotVisible();
function ComponentHearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType);
function ComponentNotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> DamageType, Vector Momentum);

function ComponentNotVisibleTimer();

/**
 * Do targeting logic here. Called every tick.
 */
function ComponentTick();

defaultproperties
{
}