class Rx_BuildingDmgFx_SmokeStackBlack_Large extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_SmokeStack_Large'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_AmbiFx_SmallChimney'
	End Object

	SocketPattern="SSBlackLarge_"
	SpawnName="_SSBlackLarge"
}

