
class Rx_CustomVehicleDamageVolume extends PhysicsVolume
placeable;

var() array<class<Rx_Vehicle> > VehiclesToDamage;
var() array<class<Rx_Vehicle> > VehiclesNotToDamage;

function CausePainTo(Actor Other)
{
	if (VehiclesToDamage.Find(Other.Class) != INDEX_NONE && VehiclesNotToDamage.Find(Other.Class) == INDEX_NONE)
	{
		if (DamagePerSec > 0)
		{
			if ( WorldInfo.bSoftKillZ && (Other.Physics != PHYS_Walking) )
				return;
			if ( (DamageType == None) || (DamageType == class'DamageType') )
				`log("No valid damagetype ("$DamageType$") specified for "$PathName(self));
			Other.TakeDamage(DamagePerSec*PainInterval, DamageInstigator, Location, vect(0,0,0), DamageType,, self);
		}
		else
		{
			Other.HealDamage(-DamagePerSec * PainInterval, DamageInstigator, DamageType);
		}
	}
}

defaultproperties
{
	bPainCausing = true
	DamagePerSec = 10.0f
	PainInterval = 1.0f
}