class Rx_BuildingDmgFx_MediumFire extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_MediumFire'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_MediumFire'
	End Object

	SocketPattern="MediumFire_"
	SpawnName="_MediumFire"
}
