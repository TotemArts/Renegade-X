class Rx_BuildingAttachment_DmgFx_WithSound extends Rx_BuildingAttachment_DmgFx
	abstract;

var AudioComponent Sound;

simulated function StartEffects()
{
	super.StartEffects();
	Sound.Play();
}

simulated function StopEffects()
{
	super.StopEffects();
	Sound.Stop();
}

DefaultProperties
{
	Begin Object Class=AudioComponent Name=AudioComp
		bAutoPlay=false
	End Object
	Components.Add(AudioComp)
	Sound=AudioComp
}
