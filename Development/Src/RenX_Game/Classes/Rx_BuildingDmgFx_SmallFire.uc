class Rx_BuildingDmgFx_SmallFire extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_SmallFire'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_SmallFire'
	End Object

	SocketPattern="SmallFire_"
	SpawnName="_SmallFire"
}
