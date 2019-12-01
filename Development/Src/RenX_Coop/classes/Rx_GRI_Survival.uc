class Rx_GRI_Survival extends Rx_GRI_Coop;

var int WaveNumber;
var float TimeUntilNextWave;
var bool bNearWaveEnd;

replication
{
	if (bNetDirty)
		WaveNumber,TimeUntilNextWave, bNearWaveEnd;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if(TimeUntilNextWave > 0)
		TimeUntilNextWave = FMax(TimeUntilNextWave - DeltaTime,0);
}

DefaultProperties
{
	WaveNumber = 1;
}