class Rx_DmgType_RanOver extends Rx_DmgType
	abstract;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local int KillCount;
	KillCount = KillerPRI.IncrementKillStat(static.GetStatsName('KILLS'));
	return KillCount;
}

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	Super.SpawnHitEffect(P,Damage,Momentum,BoneName,HitLocation);
	if(UTPawn(P) != none)
	{
		UTPawn(P).SoundGroupClass.Static.PlayCrushedSound(P);
	}
}

defaultproperties
{
	KillStatsName=EVENT_RANOVERKILLS
	DeathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	GibPerterbation=0.5
	bLocationalHit=false
	bNeverGibs=true
	bUseTearOffMomentum=true
	bExtraMomentumZ=false
	bVehicleHit=true
}
