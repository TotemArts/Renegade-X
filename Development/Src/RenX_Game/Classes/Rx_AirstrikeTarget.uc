class Rx_AirstrikeTarget extends Actor
	abstract;

var ParticleSystemComponent PS;

function ActivatePS()
{
	PS.ActivateSystem();
}

function DeactivatePS()
{
	PS.DeactivateSystem();
}

DefaultProperties
{
	RemoteRole=ROLE_None

	Begin Object Class=ParticleSystemComponent Name=ParticleComp
		bAutoActivate=false
		DepthPriorityGroup=SDPG_Foreground
	End Object
	Components.Add(ParticleComp)
	PS=ParticleComp
}
