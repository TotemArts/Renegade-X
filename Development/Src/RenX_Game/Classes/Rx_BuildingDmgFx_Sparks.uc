class Rx_BuildingDmgFx_Sparks extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_Sparks_Random'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_Sparks'
	End Object

	SocketPattern="Sparks_"
	SpawnName="_Sparks"
}
