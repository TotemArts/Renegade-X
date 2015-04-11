class Rx_BuildingAttachment_RadialImpulse extends Rx_BuildingAttachment;

var RB_RadialImpulseComponent Impulse;

function Fire()
{
	Impulse.FireImpulse(Location);
}

DefaultProperties
{
	bSpawnOnClient=true

	SocketPattern="RadialImpulseSocket"
	SpawnName="RadialImpulse"

	Begin Object Class=RB_RadialImpulseComponent Name=ImpulseComp
		bCauseFracture=true
	End Object
	Impulse=ImpulseComp
	Components.Add(ImpulseComp)
}
