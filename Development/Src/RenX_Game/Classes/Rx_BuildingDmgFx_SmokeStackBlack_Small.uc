class Rx_BuildingDmgFx_SmokeStackBlack_Small extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Fire.P_SmokeStack_Thick'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_AmbiFx_SmallChimney'
	End Object

	SocketPattern="SSBlackSmall_"
	SpawnName="_SSBlackSmall"
}

