//=============================================================================
// Particle system that activates when the owning Sentinel is damaged a certain
// amount.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelComponent_ParticleSystem_Damage extends UTParticleSystemComponent
	within Rx_Sentinel;

/** System will activate when Health drops below this fraction of MaxHealth. */
var() float DamageThreshold;

/**
 * Activates system if Health/HealthMax drops below DamageThreshold. Deactivates
 * system if it rises above DamageThreshold again, or Health drops below 0.
 */
function CheckDamage()
{
	SetActive(Health > 0 && ((float(Health) / float(HealthMax)) < DamageThreshold));
}

//TODO: Maybe when started, activate after a random time and play a sound, so that particle emmision and sound can be synchronized.

defaultproperties
{
	DamageThreshold=0.4
	bAutoActivate=false
}