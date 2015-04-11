//=============================================================================
// Describes a fire mode for a Rx_SentinelWeapon.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeaponComponent_FireInfo extends Component;

/** Minimum time between shots. */
var() float FireInterval;
/** Projectile weapons should have this set, leave none for instant-hit weapons. */
var() class<Projectile> ProjectileClass;
/** Projectile spawn/trace start relative to the weapon. */
var() Vector FireOffset;
/** Damage for instant-hit fire. */
var() float Damage;
/** Momentum for instant-hit fire. */
var() float Momentum;
/** Damage type for instant-hit fire. */
var() class<DamageType> DamageType;
/** Calculated from projectile class if one is set, or set explicitly. */
var() float MaxRange;
/** Cone of fire. */
var() float Spread;
/** Sound to play when firing. */
var() SoundCue FireSound;
/** Loudness when firing, for AI hearing. */
var() float FireLoudness;
/** Sentinel can fire when within this many degrees of perfect aim. */
var() float MaxAimError;
/** Sound to play when a shot passes near a player. */
var() SoundCue BulletWhip;
/** Sentinel will stop rotating for this many seconds after firing. */
var() float RotationStopTime;

/**
 * Calculates MaxRange if necessary, and possibly other properties.
 */
function Initialize()
{
	if(ProjectileClass != none && MaxRange == 0)
	{
		MaxRange = ProjectileClass.static.GetRange();
	}
}

//Mostly copied from UTWeaponAttachment.uc
function CheckBulletWhip(Vector FireLocation, Vector HitLocation)
{
	local UTPlayerController PC;
	local Vector FireDir;

	if(BulletWhip != none)
	{
		FireDir = Normal(HitLocation - FireLocation);

		foreach Actor(Outer).LocalPlayerControllers(class'UTPlayerController', PC)
		{
			PC.CheckBulletWhip(BulletWhip, FireLocation, FireDir, HitLocation);
		}
	}
}

defaultproperties
{
	FireLoudness=1.0
	MaxAimError=18.0

	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'
}