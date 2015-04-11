class Rx_BuildingDmgFx_DeathExplosion extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_Explosion'
	End Object
	DrawScale = 2

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_DeathExplosion'
	End Object

	bNonLooping=true

	SocketPattern="DeathExplosion_"
	SpawnName="_DeathExplosion"
}
