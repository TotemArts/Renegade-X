class Rx_Weapon_DeployedTimedC4 extends Rx_Weapon_DeployedC4
	implements (RxIfc_TargetedDescription);

/** Countdown to explosion */
var repnotify int Count;

/** MIC for ramping colour */
var MaterialInstanceConstant	ChargeMI, CounterTens, CounterOnes;
var name                      SecondClamp, TenSecondClamp;

var SoundCue CountdownBeep;
var SoundCue ImminentBeeps;

replication
{
	if (bNetDirty)
		Count;
}

simulated event ReplicatedEvent(name VarName) {
	if (VarName == 'Count') {
		CountIt();
	}
	else {
		super.ReplicatedEvent(VarName);
	}
}

simulated function CountIt()
{
	local int TimeSec, TimeTenSec;
	TimeSec = Count % 10;
	TimeTenSec = (Count / 10);
	CounterOnes.SetScalarParameterValue('SecondClamp', Float(TimeSec));
	CounterTens.SetScalarParameterValue('TenSecondClamp', Float(TimeTenSec));

	switch (Count)
	{
		case 25:
			CountdownBeep.PitchMultiplier = 1;
			PlaySound(CountdownBeep);
			break;
		case 20:
			CountdownBeep.PitchMultiplier = 1.2;
			PlaySound(CountdownBeep);
			break;
		case 15:
			CountdownBeep.PitchMultiplier = 1.4;
			PlaySound(CountdownBeep);
			break;
		case 10:
			CountdownBeep.PitchMultiplier = 1.6;
			PlaySound(CountdownBeep);
			break;
		case 5:
			PlaySound(ImminentBeeps);
			break;
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ChargeMI = Mesh.CreateAndSetMaterialInstanceConstant(0);
	CounterTens = Mesh.CreateAndSetMaterialInstanceConstant(1);
	CounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(2);
}

function Landed(vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	SetTimer(1.0, true, 'CountDown');
}

function CountDown()
{
	Count--;
	if (Worldinfo.NetMode != NM_DedicatedServer )
		CountIt();
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if ( PlayerPerspective.GetTeamNum() == GetTeamNum() )
		return string(Count);
	else
		return "";
}


defaultproperties
{
	DeployableName="Timed C4"
	Count=30.0
	DmgRadius=360
	BuildingDmgRadius = 360
	HP = 200
    Damage=400
    DamageMomentum=8000.0

    DisarmScoreReward = 40	

    ImpactSound=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Plant'
	ChargeDamageType=class'Rx_DmgType_TimedC4'

	Begin Object Name=DeployableMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TimedC4.Mesh.SK_WP_TimedC4_Deployed'
		PhysicsAsset=PhysicsAsset'RX_WP_TimedC4.Mesh.SK_WP_TimedC4_Deployed_Physics'
		Scale=1.0
	End Object

	//SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Plant'

	CountdownBeep=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_SlowBeep'

	ImminentBeeps=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_ImminentBeep'
}