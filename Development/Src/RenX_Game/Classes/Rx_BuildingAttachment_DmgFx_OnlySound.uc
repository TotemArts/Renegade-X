class Rx_BuildingAttachment_DmgFx_OnlySound extends Rx_BuildingAttachment_DmgFx_WithSound
	abstract;

simulated function StartEffects()
{
	Sound.Play();
}

simulated function StopEffects()
{
	Sound.Stop();
}

DefaultProperties
{
	Particles=None
	Components.Remove(ParticleComp)
}
