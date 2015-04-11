class Rx_BuildingDmgFx_ElectricalDamage extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_ElectricalDamage'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_ElectricalSparks'
	End Object

	SocketPattern="ElectricalDamage_"
	SpawnName="_ElectricalDamage"
}
