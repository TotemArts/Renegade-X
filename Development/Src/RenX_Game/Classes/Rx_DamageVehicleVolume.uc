
class Rx_DamageVehicleVolume extends PhysicsVolume
	placeable;

function CausePainTo(Actor Other)
{
	if(Rx_Vehicle(Other) == None)
		return;
	super.CausePainTo(Other);
}

defaultproperties
{
	bPainCausing = true
	DamagePerSec = 10.0f
	PainInterval = 1.0f
}