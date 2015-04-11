class Rx_BuildingDmgFx_HugeFire extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_Fire_Large'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_HugeFire'
	End Object

	SocketPattern="HugeFire_"
	SpawnName="_HugeFire"
}

