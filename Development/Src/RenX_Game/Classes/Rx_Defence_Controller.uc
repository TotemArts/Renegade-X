class Rx_Defence_Controller extends AIController;

var float time;
var float LastFireAttempt;
var bool bFireSuccess;
var float LastCanAttackCheckTime;
var bool bCanFire;
var Actor LastFireTarget;
var bool bStoppedFiring;
var Actor myFocus;
var UTPawn UTP;
var vector PlayerFeet;
var vector SocketLocation;
var vector Aim_Spot;
var rotator SocketRotation;	

var Rx_SmokeScreen DummyActor;
var Vector DummyHitLoc, DummyHitNorm;

var vector HitLocation, HitNormal;

/** Prediction will never see target as moving faster than this. */
var float MaxPredictionSpeed;
/** Proportion of targets velocity to take into account when predicting where to fire. */
var float AimAhead;
var rotator AimAheadAimRotation;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitPlayerReplicationInfo();
}

function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_DefencePRI', self);

	if (PlayerReplicationInfo != none) {
		PlayerReplicationInfo.SetPlayerName(Rx_Defence(Owner).GetHumanReadableName());
		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[Owner.GetTeamNum()]);
	}
}

function bool IsTargetRelevant( Pawn thisTarget )
{
	if (Rx_Pawn(thisTarget) != None && Rx_Pawn(thisTarget).isSpy()) // added spy exception
		return false;

	if(Rx_Defence_SAMSite(Pawn) == None && Rx_Defence_AATower(Pawn) == None) 
	{
		if(Rx_Vehicle_Air_Jet(thisTarget) != None || Rx_Vehicle_Air(thisTarget) != None) 
		{
			return false;
		}
	}
	
	if(Rx_VehicleSeatPawn(thisTarget) != none)
	{
		if(Rx_Vehicle_Air(Rx_VehicleSeatPawn(thisTarget).MyVehicle) != none || Rx_Vehicle_Air_Jet(Rx_VehicleSeatPawn(thisTarget).MyVehicle) != none) 
			return false;		
	}
	
	if (thisTarget != None && 
		FastTrace(thisTarget.location,pawn.location) &&
		(thisTarget.Controller != None) && 
		(thisTarget.GetTeamNum() != self.GetTeamNum()) &&
		(thisTarget.Health > 0) &&
		pawn.Weapon.CanAttack(thisTarget))
		//(VSize(thisTarget.Location-Pawn.Location) < Pawn.SightRadius*1.25) )
	{
		if ( Rx_Game(WorldInfo.Game).SmokeScreenCount > 0 )
		{
			foreach TraceActors(class'Rx_SmokeScreen', DummyActor, DummyHitLoc, DummyHitNorm, thisTarget.Location, Pawn.Location)
				return false;
		}
		return true;
	}
	return false;
}

/*
*  Normal IsAimCorrect in UTVehicleWeapon checks if were aiming at Focus, but here we need
*  to check if were aiming at Enemy instead, while Focus can be None.
*/
function bool IsAimCorrect()
{
	local vector DesiredAimPoint, RealAimPoint;

	DesiredAimPoint = Enemy.location;

	UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetFireStartLocationAndRotation(SocketLocation, SocketRotation);

	RealAimPoint = SocketLocation + Vector(SocketRotation) * UTVehicle(Pawn).Seats[0].Gun.GetTraceRange();
	return ((Normal(DesiredAimPoint - SocketLocation) dot Normal(RealAimPoint - SocketLocation)) >= UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetMaxFinalAimAdjustment());
}

auto state Searching
{
	
	event SeePlayer( Pawn Seen )
	{
		if ( IsTargetRelevant( Seen ) )
		{
			Enemy = Seen;
			Focus = Seen;
			GotoState('Engaged');
		}
	}
	
	event EnemyNotVisible()
	{
		super.EnemyNotVisible();
		Enemy = None;
		Focus = None;
	}

	function BeginState(Name PreviousStateName)
	{
		if(Pawn != None)
			self.StopFiring();
	}
	
	Begin:
	Focus = Enemy;
	Sleep(0.2);
	if ( Enemy != None && IsTargetRelevant( Enemy ) )
		GotoState('Engaged');
	Sleep(0.5 + 1.0*FRand());
	foreach WorldInfo.AllPawns(class'UTPawn', UTP,Pawn.location,pawn.SightRadius)
	{ 
		if(Rx_Pawn(UTP) != None && IsTargetRelevant(UTP))
		{
			GotoState('Engaged');	
			break;
		}
	}
	
	Goto('Begin');
}

state Engaged
{
	
	ignores SeePlayer;
	
	function EnemyNotVisible()
	{
		if ( IsTargetRelevant( Enemy ) )
		{
			Focus = None;
			GotoState('WaitForTarget');
			return;
		}
	}

	function BeginState(Name PreviousStateName)
	{
		SetTimer(0.1, true, 'TryToAttackFocus');
	}
	function EndState(Name NextStateName)
	{
		ClearTimer('TryToAttackFocus');
	}


	Begin:
	Focus = Enemy;
	Sleep(0.1);
	//	if(Trace(HitLocation, HitNormal, Focus.Location - vect(0,0,60), UTVehicle(Pawn).Seats[0].Gun.GetPhysicalFireStartLoc(), true,,, TRACEFLAG_Bullet) == Enemy);
	//     	FocalPoint.z = FocalPoint.z-60;
	
	UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetFireStartLocationAndRotation(SocketLocation, SocketRotation);
	
	if(AimAhead > 0.0 && Enemy != None && Focus != None) {
		FindAimToHit(Enemy, SocketLocation, Aim_Spot, AimAheadAimRotation);
		self.FocalPosition.Position = Aim_Spot;
	}
	
	if(UTVehicle(Enemy) == None && Rx_Defence_GuardTower(Pawn) == None)
	{
		PlayerFeet = self.FocalPosition.Position;
		PlayerFeet.Z -= 50;
		if(FastTrace(PlayerFeet,SocketLocation)) {
			self.FocalPosition.Position.Z -= 50;	// If Enemy is Infantry, aim more at the feet, if its a Vehicle aim at the middle
		}
	}
	// This 'manually' Points the Turret to where the Controller is Aiming
	UTVehicle(Pawn).ForceWeaponRotation(0, UTVehicle(Pawn).GetWeaponAim(UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun)));
	Focus = None;
	Sleep(1.2);
	if ( !IsTargetRelevant( Enemy )) {
		GotoState('Searching');
	}
	Goto('Begin');
}

function TryToAttackFocus(){
	if((Enemy != None)  && IsAimCorrect() && UTVehicle(Pawn).Seats[0].Gun.CanAttack(Enemy))
	{
		Pawn.BotFire(false);
	}
	else
	{
		self.StopFiring();
	} 
}

State WaitForTarget
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( IsTargetRelevant( SeenPlayer ) )
		{
			Enemy = SeenPlayer;
			GotoState('Engaged');
		}
	}

Begin:
	Sleep( GetWaitForTargetTime() );
	GotoState('Searching');
}

function float GetWaitForTargetTime()
{
	return (3 + 5 * FRand());
}

/**
 * Determines the best place to shoot at to hit the target.
 */
function FindAimToHit(Actor A, Vector Origin, out Vector AimSpot, out Rotator AimRotation)
{
	PredictTargetLocation(A, Origin, AimSpot);
	AimRotation = Rotator(AimSpot - Origin);
}

/**
 * Predicts where the target will be based on its velocity. Only call this if the Sentinel is using a projectile weapon.
 */
function PredictTargetLocation(Actor A, Vector Origin, out Vector AimSpot)
{
	local float PredictionTime;
	local Vector PredictionVelocity;

	AimSpot = A.GetTargetLocation();

	//How long it will take for projectile to reach target.
	
	PredictionTime = GetPredictionTime(AimSpot, Origin);

	//Where the target will probably be by then.
	if(VSize(A.Velocity) > MaxPredictionSpeed)
		PredictionVelocity = Normal(A.Velocity) * MaxPredictionSpeed;
	else
		PredictionVelocity = A.Velocity;

	AimSpot += PredictionVelocity * PredictionTime * AimAhead;
}

function float GetPredictionTime(vector AimSpot, Vector Origin) {
	local float ret;
	ret = class'Rx_Defence_Turret_Projectile'.static.StaticGetTimeToLocation(AimSpot, Origin, Self);
	ret += 0.5 * ret;
	return ret;
}

/*
Is set, when a Player is controlling the Turret
*/
state Idle
{
}

defaultproperties
{
	bIsPlayer = false
	RotationRate=(Pitch=32768,Yaw=60000,Roll=0)
	bSeeFriendly=false
	MaxPredictionSpeed=1000.0
	AimAhead = 1.0	
}