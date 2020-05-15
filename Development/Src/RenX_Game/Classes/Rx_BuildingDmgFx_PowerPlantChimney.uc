class Rx_BuildingDmgFx_PowerPlantChimney extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_PowerPlant_Chimney'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_AmbiFx_PPChimney'
	End Object

	SocketPattern="PPChimney_"
	SpawnName="_PPChimney"
}

