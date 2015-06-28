class Rx_Weapon_CrateNuke extends Rx_Weapon_DeployedNukeBeacon;

DefaultProperties
{
	bBroadcastPlaced = false

	PartSysTemplate=ParticleSystem'RX_WP_Nuke.Effects.P_Nuke_Falling_Fast'
	NukeParticleLength = 2

	BeepCue = SoundCue'RX_WP_Nuke.Sounds.Nuke_BeepsCue_Immediate'

	TimeUntilExplosion = 3;
}
