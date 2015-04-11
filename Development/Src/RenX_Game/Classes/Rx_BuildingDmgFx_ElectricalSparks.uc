class Rx_BuildingDmgFx_ElectricalSparks extends Rx_BuildingAttachment_DmgFx_WithSound;

DefaultProperties
{
	Begin Object Name=ParticleComp
		Template=ParticleSystem'rx_fx_envy.Buildings.P_ElectricSparks'
	End Object

	Begin Object Name=AudioComp
		SoundCue=SoundCue'RX_AmbientSounds.Buildings.SC_Building_DmgFx_ElectricalSparks'
	End Object

	SocketPattern="ElectricalSparks_"
	SpawnName="_ElectricalSparks"
}
