//=============================================================================
// Controls Sentinels. What did you think it did?
// All decision making is delegated to components.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelController extends AIController;

/** Component for calculating aim. */
var() const Rx_SentinelControllerComponent_Aiming AimingComponent;

/** Default behaviour is to do nothing. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour NoBehaviour;
/** Behaviour with no target. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour IdleBehaviour;
/** Behaviour when attacking a pawn. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour_TargetingPawn PawnTargetingBehaviour;
/** Behaviour when attacking an objective. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour_TargetingObjective ObjectiveTargetingBehaviour;
/** Behaviour when attacking a location. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour_TargetingLocation LocationTargetingBehaviour;
/** Behaviour when the round/game has ended. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour RoundEndedBehaviour;

/** Current Behaviour. Can be set to anything via ChangeBehaviourTo, not just the ones declared above. Note that the Behaviour's Outer must be this controller. */
var(Behaviour) Rx_SentinelControllerComponent_Behaviour CurrentBehaviour;

/** Sentinel being controlled. */
var Rx_Sentinel Cannon;

/** Maximum time to wait for a hidden target before giving up completely. */
var() float TargetWaitTime;

/** Time when target was last seen. */
var float LastSeenTime;
/** Time when target was last detected at all (seen, heard or otherwise). */
var float LastDetectedTime;
/** Location where target was at LastDetectedTime. */
var Vector LastDetectedLocation;
/** Target is currently within line of sight. */
var bool bEnemyIsVisible;

/** Set to true to force the Sentinel to target an actor that it does not considered its best target. */
var bool bForceTarget;
var array<Pawn> SeenButCoveredPawns;

var Rx_SmokeScreen DummyActor;
var Vector DummyHitLoc, DummyHitNorm;

function PostBeginPlay()
{
	//Not entirely sure what this does, but Controller.uc suggests it's a good idea.
	SightCounter = 0.2 * FRand();
}


function Possess(Pawn inPawn, bool bVehicleTransition)
{
	Cannon = Rx_Sentinel(inPawn);
	InitPlayerReplicationInfo();

	if(inPawn.Controller != none && inPawn.Controller != self)
	{
		inPawn.Controller.UnPossess();
	}

	inPawn.PossessedBy(self, bVehicleTransition);
	Pawn = inPawn;

	SetFocalPoint(Pawn.Location + 512*vector(Pawn.Rotation));
	Restart(bVehicleTransition);
}

function InitPlayerReplicationInfo()
{
	if(Cannon == none)
	{
		`warn("InitPlayerReplicationInfo called with no Sentinel");
		Destroy();
	}
	else if(false) //if(Cannon.InstigatorController == none)
	{
		`warn("InitPlayerReplicationInfo called with no InstigatorController");
		Cannon.Suicide();
	}
	else
	{
		if(PlayerReplicationInfo != none)
		{
			CleanupPRI();
		}
		PlayerReplicationInfo = Spawn(class'Rx_DefencePRI', self);

		if (PlayerReplicationInfo != none)
		{
			if(Rx_Sentinel_AGT_MG_Base(Cannon) != None || Rx_Sentinel_AGT_Rockets_Base(Cannon) != None)
				PlayerReplicationInfo.SetPlayerName("AGT");
			else
				PlayerReplicationInfo.SetPlayerName("Obelisk");	

			PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[Cannon.GetTeamNum()]);
		}
	}
}

simulated function String GetHumanReadableName()
{
	return (Pawn != none ? Pawn.GetHumanReadableName() : super.GetHumanReadableName());
}

function Controller GetKillerController()
{
	return none;   // my change
    return Cannon.InstigatorController;
}

simulated function GetPlayerViewPoint(out vector out_Location, out Rotator out_Rotation)
{
	out_Location = Cannon.GetPawnViewLocation();
	out_Rotation = Cannon.GetViewRotation();
}

function PawnDied(Pawn P)
{
	LogInternal("...........................died");
	Destroy();
}

/**
 * Forces the Sentinel to aim at the given actor even if it is not its current target. Call with 'none' to revert to normal behaviour.
 */
function ForceTarget(Actor ForcedTarget)
{
	bForceTarget = ForcedTarget != none;
	Focus = ForcedTarget;
}

/**
 * Change the behaviour component. Does nothing if the new bahaviour is the same as the current one.
 */
function ChangeBehaviourTo(Rx_SentinelControllerComponent_Behaviour NewBehaviour)
{
	if(NewBehaviour == none)
	{
		`warn("Tried to change behaviour to none.");
	}
	else if(CurrentBehaviour != NewBehaviour)
	{
		CurrentBehaviour.EndBehaviour();
		CurrentBehaviour = NewBehaviour;
		CurrentBehaviour.BeginBehaviour();
	}
}

/**
 * Notification from the cannon that it is spawning in, so don't do anything.
 */
function CannonSpawning()
{
	ChangeBehaviourTo(NoBehaviour);
}

/**
 * Notification from the cannon that it has finished spawning, so go to idle state.
 */
function CannonSpawned()
{
	ChangeBehaviourTo(IdleBehaviour);
}

function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	ChangeBehaviourTo(RoundEndedBehaviour);
}

function RoundHasEnded(optional Actor EndRoundFocus)
{
	ChangeBehaviourTo(RoundEndedBehaviour);
}

function SeeMonster(Pawn Seen)
{
	CurrentBehaviour.ComponentSeeMonster(Seen);
}


function SeePlayer(Pawn Seen)
{
	//halo2pac - added check to make sure Seen != None to prevent logs from filling up.
	if (Seen == None)
		return;
	
	if(Cannon != None && (Cannon.IsSameTeam(Seen) || (Rx_Pawn(Seen) != None && Rx_Pawn(Seen).isSpy()))) { // added spy exception
		return;
	}
	/**
	if(Cannon != None && Rx_Pawn(Seen) != None && UTPawn(Seen).Groundspeed >= 290) {
			UTPawn(Seen).Groundspeed = 290;
			Rx_Pawn(Seen).ClientStopSprint();
	} 
	*/
	
	CurrentBehaviour.ComponentSeePlayer(Seen);
}

function EnemyNotVisible()
{
	CurrentBehaviour.ComponentEnemyNotVisible();
}

function HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	//CurrentBehaviour.ComponentHearNoise(Loudness, NoiseMaker, NoiseType);
}

function NotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> DamageType, Vector Momentum)
{
	CurrentBehaviour.ComponentNotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

/** Call this TargetWaitTime after target goes out of sight. */
function NotVisibleTimer()
{
	CurrentBehaviour.ComponentNotVisibleTimer();
}

function Tick(float DeltaTime)
{
	CurrentBehaviour.ComponentTick();
}

//Overriden to prevent removing self from team (never added in the first place, so it messes up team size) and logging out.
function Destroyed()
{
	LogInternal("...........................destroyed2");
	if(Role == ROLE_Authority)
	{
		if(PlayerReplicationInfo != none)
		{
			CleanupPRI();
		}
	}

	Cannon = none;
}

function CheckPreviouslyCoveredTargets() 
{
	local Pawn P;
	foreach SeenButCoveredPawns(P) {
		if((UTVehicle(P) != None && !UTVehicle(P).bDriving) || !CanSee(P)) {
			SeenButCoveredPawns.removeItem(P);
			continue;
		}
		if(Enemy == None && PawnTargetingBehaviour.PossiblyTarget(P)) {
	        PawnTargetingBehaviour.SetTargetInfo(P, true, P.Location, WorldInfo.TimeSeconds);
			ChangeBehaviourTo(PawnTargetingBehaviour);
		} 	
	}
	if(SeenButCoveredPawns.length == 0) {
		ClearTimer('CheckPreviouslyCoveredTargets');
	}
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(HUD, out_YL, out_YPos);

	HUD.Canvas.SetDrawColor(255, 0, 0);

	HUD.Canvas.DrawText("Focus:"@Focus);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("Enemy:"@Enemy);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("bEnemyIsVisible:"@bEnemyIsVisible);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("bForceTarget:"@bForceTarget);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("Current Behaviour:"@CurrentBehaviour);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);

}

defaultproperties
{
	TargetWaitTime=5.0
	bSlowerZAcquire=false

	//PlayerReplicationInfoClass=none
	bIsPlayer=false

	Begin Object Class=Rx_SentinelControllerComponent_Aiming Name=AimingComponent0
	End Object
	AimingComponent=AimingComponent0

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_None Name=Behaviour0
	End Object
	NoBehaviour=Behaviour0
	CurrentBehaviour=Behaviour0

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_Idle Name=Behaviour1
	End Object
	IdleBehaviour=Behaviour1

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_TargetingPawn Name=Behaviour2
	End Object
	PawnTargetingBehaviour=Behaviour2

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_TargetingObjective Name=Behaviour3
	End Object
	ObjectiveTargetingBehaviour=Behaviour3

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_TargetingLocation Name=Behaviour4
	End Object
	LocationTargetingBehaviour=Behaviour4

	Begin Object Class=Rx_SentinelControllerComponent_Behaviour_RoundEnded Name=Behaviour5
	End Object
	RoundEndedBehaviour=Behaviour5
}
