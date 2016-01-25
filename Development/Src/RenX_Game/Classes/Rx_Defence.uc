class Rx_Defence extends Rx_Vehicle
	abstract;

var AIController ai;
var bool bAIControl;
var class<Rx_Defence_Controller> DefenceControllerClass;

var const byte TeamID;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		bAIControl;
}

simulated function bool CanEnterVehicle(Pawn P)
{
	if (p.Controller.bIsPlayer && bAIControl)
		return false;

	return super.CanEnterVehicle(P);
}

simulated function PostBeginPlay()
{
	super(UTVehicle).PostBeginPlay();
	SetTimer(3.0,false,'Initialize');
}

function Tick( FLOAT DeltaSeconds )
{
	super(UTVehicle).Tick(DeltaSeconds);
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	return super(UTVehicle).Died(Killer,DamageType,HitLocation);
}

// Rx_Defence don't count towards CapturePoints, no need to notify.
function NotifyCaptuePointsOfDied(byte FromTeam);
function NotifyCaptuePointsOfTeamChange(byte from, byte to);

function startUpDriving() { }

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
								   const out CollisionImpactData Collision, int ContactIndex ) 
{
	super(UTVehicle).RigidBodyCollision(HitComponent,OtherComponent,Collision,ContactIndex);
}

simulated event SuspensionHeavyShift(float Delta) { }

simulated function DrivingStatusChanged() 
{
	super(UTVehicle).DrivingStatusChanged();
}


function bool TryToDrive(Pawn P)
{
    if(Rx_Controller(P.Controller) != None)
    	return false;
    if( WorldInfo.GRI.OnSameTeam(Self,P)){
        StopFiring();
        Seats[0].SeatPawn.DriverLeave(true);
        ai.GotoState('Idle');
    }
    return Super.TryToDrive(P);
}

function DriverLeft()
{
	Super.DriverLeft();

	if(!bAIControl) {
		bAIControl = true;
		ai.Possess(Self, true);
		ai.GotoState('Searching');
	}
	else
	{
		bAIControl = false;
	}
}

function bool AnySeatAvailable()
{
	local int i;
	for (i=0;i<Seats.Length;i++)
	{
		if( ( Seats[i].SeatPawn != none )
			&& ( Seats[i].SeatPawn.Controller==none || Rx_Defence_Controller(Seats[i].SeatPawn.Controller) != none)
			)
		{
			return true;
		}
	}
	return false;
}

function Initialize() {
	SetTeamNum(TeamID);
	ai = Spawn(DefenceControllerClass,self);
	ai.SetOwner(None);  // Must set ai owner back to None, because when the ai possesses this actor, it calls SetOwner - and it would fail due to Onwer loop if we still owned it.

	ai.Possess(self, true);
	bAIControl = true;
}

function bool DriverEnter(Pawn P)
{
	P.StopFiring();

	if (Seats[0].Gun != none)
	{
		InvManager.SetCurrentWeapon(Seats[0].Gun);
	}

	Instigator = self;

	if ( !Super(UTVehicle).DriverEnter(P) )
		return false;

	SetSeatStoragePawn(0,P);

	if (ParentFactory != None)
	{
		ParentFactory.TriggerEventClass(class'UTSeqEvent_VehicleFactory', None, 3);
	}

	if ( PlayerController(Controller) != None )
	{
		VehicleLostTime = 0;
	}
	
	StuckCount = 0;
	ResetTime = WorldInfo.TimeSeconds - 1;
	bHasBeenDriven = true;

	return true;
}

simulated function Destroyed()
{
	loginternal("Turret destroyed");
	if(ai != none)
		ai.UnPossess();
	super.Destroyed();
}

simulated function bool IsEffectedByEMP()
{
	return false;
}

// EMPs are not to affect automated defences
function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor)
{
	return false;
}

DefaultProperties
{
	DefenceControllerClass=class'Rx_Defence_Controller'
	bBlocksNavigation=true
	GroundSpeed=1
    AirSpeed=0
    MaxSpeed=0
    bReplicateMovement=false
    bAlwaysRelevant=true
	
}
