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
	CounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(1);
	CounterTens = Mesh.CreateAndSetMaterialInstanceConstant(2);
	CountIt();
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

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	
	//super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if (!CanDisarmMe(DamageCauser))
	{
		ImpactedActor.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		return;
	}
	
	super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
      return;

	HP -= DamageAmount;

	if (HP <= 0)
	{
		BroadcastDisarmed(EventInstigator);
		if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
			bDisarmed = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
			PlayDisarmedEffect();      
			ClearTimer('Explosion');

		
		if (EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum)
		{
			Rx_Controller(EventInstigator).DisseminateVPString( "[C4 Disarmed]&" $ class'Rx_VeterancyModifiers'.default.Ev_C4Disarmed $ "&");
			Rx_Pri(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(DisarmScoreReward,true);
			Rx_PRI(EventInstigator.PlayerReplicationInfo).AddMineDisarm();
		}
		
		SetTimer(0.1, false, 'DestroyMe'); // delay it a bit so disappearing blends a littlebit better with the disarmed effects
	}
	
	if (!CanDisarmMe(DamageCauser))
	{
		if(ImpactedActor != None)
			ImpactedActor.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
		return;
	}
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