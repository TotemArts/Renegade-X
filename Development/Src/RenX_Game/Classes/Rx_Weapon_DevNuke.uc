class Rx_Weapon_DevNuke extends Rx_Weapon_DeployedNukeBeacon;

function Explosion()
{
	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	else
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location);
	bExplode = true; // trigger client replication
	if (WorldInfo.NetMode != NM_DedicatedServer)
		PlayExplosionEffect();

	if (Rx_VehicleSeatPawn(InstigatorController.Pawn) != None)
		Rx_VehicleSeatPawn(InstigatorController.Pawn).DriverLeave(true);
	else if (Vehicle(InstigatorController.Pawn) != None)
		InstigatorController.Pawn.Died(InstigatorController, DamageTypeClass, InstigatorController.Pawn.Location);

	InstigatorController.Pawn.Died(InstigatorController, DamageTypeClass, InstigatorController.Pawn.Location);
	SetTimer(0.5f, false, 'ToDestroy');
}

DefaultProperties
{
	bBroadcastPlaced = false

	PartSysTemplate=ParticleSystem'RX_WP_Nuke.Effects.P_Nuke_Falling_Fast'
	NukeParticleLength = 2

	BeepCue = SoundCue'RX_WP_Nuke.Sounds.Nuke_BeepsCue_Immediate'

	TimeUntilExplosion = 3;
}
