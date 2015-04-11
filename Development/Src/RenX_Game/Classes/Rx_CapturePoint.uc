class Rx_CapturePoint extends Actor;

// TODO Saved list of PRIs who aided in the cap/neutralise for score distribution

// TODO Check whether progess stays displayed if a client is in cap zone in a vehicle, then the vehicle dies, and then they are ejected as infantry into the CP. (PawnDied in Rx_Controller)

var() byte InitialTeam;
var() bool bInfantryCanCap;
var() bool bVehiclesCanCap;

var bool bCaptured;	// is currently owned by CapturingTeam
var byte CapturingTeam;
var float CaptureProgress;

var float BaseCapRatePerSecond;		// Capture speed by a single person.
var float BonusCapRatePerSecond;	// Bonus capture speed added per extra person.
var float MaxCapRatePerSecond;		// Max capture rate speed possible. Caps bonus cap rate.
var float DrainRatePerSecond;
var float FullCaptureScore;	// The amount to give someone who solo'd a capture . This amount is then divided up and distributed on multiple cappers.
var float FullNeutralizeScore;	// Same as above but for neutralise.

var float ReplicatedProgress;
var float ReplicateProgressTime;

var array<Rx_Pawn> TouchingGDIPawns;
var array<Rx_Pawn> TouchingNodPawns;
var array<Rx_Vehicle> TouchingGDIVehicles;
var array<Rx_Vehicle> TouchingNodVehicles;
var int GDICount;
var int NodCount;

var array<Rx_PRI> CappingPRIs;	// Saved list of people who helped the capture/neutralise

var RxIfc_Capturable AssociatedActor;

`define CalcGDICount (TouchingGDIPawns.Length+TouchingGDIVehicles.Length)
`define CalcNodCount (TouchingNodPawns.Length+TouchingNodVehicles.Length)

`define GDICapRate FMin(BaseCapRatePerSecond + (GDICount - NodCount - 1)*BonusCapRatePerSecond, MaxCapRatePerSecond)
`define NodCapRate FMin(BaseCapRatePerSecond + (NodCount - GDICount - 1)*BonusCapRatePerSecond, MaxCapRatePerSecond)
`define OffendersCapRate FMin(BaseCapRatePerSecond + (Offenders - Defenders - 1)*BonusCapRatePerSecond, MaxCapRatePerSecond)
`define DefendersCapRate FMin(BaseCapRatePerSecond + (Defenders - Offenders - 1)*BonusCapRatePerSecond, MaxCapRatePerSecond)

`define HudCondition (bInfantryCanCap && Rx_Pawn(P) != None && Rx_Pawn(P).Controller != None && Rx_Pawn(P).Controller.IsLocalPlayerController()) || (bVehiclesCanCap && Rx_Vehicle(P) != None && Rx_Defence(P) == None && Rx_Defence_Emplacement(P) == None && Rx_Vehicle(P).Controller != None && Rx_Vehicle(P).Controller.IsLocalPlayerController())

replication
{
	if (bNetDirty)
		bCaptured, CapturingTeam, ReplicatedProgress, GDICount, NodCount;
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	if (InitialTeam != 255)
	{
		CapturingTeam=InitialTeam;
		CaptureProgress=1;
		bCaptured=true;
		GotoState('CapturedIdle');
	}
	if (RxIfc_Capturable(Owner) != None)
		AssociatedActor = RxIfc_Capturable(Owner);
	SetTimer(ReplicateProgressTime, true, 'RepProgress');
}

function AddTouchingPawn(Rx_Pawn P, byte TeamIndex)
{
	if (TeamIndex == TEAM_GDI)
	{
		TouchingGDIPawns.AddItem(P);
		GDICount = `CalcGDICount;
	}
	else if (TeamIndex == TEAM_Nod)
	{
		TouchingNodPawns.AddItem(P);
		NodCount = `CalcNodCount;
	}
}
function RemoveTouchingPawn(Rx_Pawn P, byte TeamIndex)
{
	if (TeamIndex == TEAM_GDI)
	{
		TouchingGDIPawns.RemoveItem(P);
		GDICount = `CalcGDICount;
	}
	else if (TeamIndex == TEAM_Nod)
	{
		TouchingNodPawns.RemoveItem(P);
		NodCount = `CalcNodCount;
	}
}
function RemoveTouchingPawnBothTeams(Rx_Pawn P)
{
	TouchingGDIPawns.RemoveItem(P);
	GDICount = `CalcGDICount;
	TouchingNodPawns.RemoveItem(P);
	NodCount = `CalcNodCount;
}
function AddTouchingVehicle(Rx_Vehicle V, byte TeamIndex)
{
	if (TeamIndex == TEAM_GDI)
	{
		TouchingGDIVehicles.AddItem(V);
		GDICount = `CalcGDICount;
	}
	else if (TeamIndex == TEAM_Nod)
	{
		TouchingNodVehicles.AddItem(V);
		NodCount = `CalcNodCount;
	}
}
function RemoveTouchingVehicle(Rx_Vehicle V, byte TeamIndex)
{
	if (TeamIndex == TEAM_GDI)
	{
		TouchingGDIVehicles.RemoveItem(V);
		GDICount = `CalcGDICount;
	}
	else if (TeamIndex == TEAM_Nod)
	{
		TouchingNodVehicles.RemoveItem(V);
		NodCount = `CalcNodCount;
	}
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if (WorldInfo.NetMode != NM_Client)
	{
		if (bInfantryCanCap && Rx_Pawn(Other) != None)
			AddTouchingPawn(Rx_Pawn(Other), Other.GetTeamNum());
		else if (bVehiclesCanCap && Rx_Vehicle(Other) != None && Rx_Defence(Other) == None && Rx_Defence_Emplacement(Other) == None )
			AddTouchingVehicle(Rx_Vehicle(Other), Other.GetTeamNum());
		Wake();
	}
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (Pawn(Other) != None)
			TryDisplayHUD(Pawn(Other));
	}
}

simulated event UnTouch( Actor Other )
{
	if (WorldInfo.NetMode != NM_Client)
	{
		if (bInfantryCanCap && Rx_Pawn(Other) != None)
			RemoveTouchingPawn(Rx_Pawn(Other), Other.GetTeamNum());
		else if (bVehiclesCanCap && Rx_Vehicle(Other) != None && Rx_Defence(Other) == None && Rx_Defence_Emplacement(Other) == None )
			RemoveTouchingVehicle(Rx_Vehicle(Other), Other.GetTeamNum());
		Wake();
	}
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (Pawn(Other) != None)
			TryUndisplayHUD(Pawn(Other));
	}
}

simulated function bool TryDisplayHUD(Pawn P)
{
	// This condition won't work for vehicle passengers?
	if (`HudCondition)
	{
		Rx_Hud(UTPlayerController(P.Controller).myHud).DisplayCapturePoint(self);
		return true;
	}
	return false;
}

simulated function bool TryUndisplayHUD(Pawn P)
{
	if (P.Controller != None && P.Controller.IsLocalPlayerController())
	{
		Rx_Hud(UTPlayerController(P.Controller).myHud).UndisplayCapturePoint(self);
		return true;
	}
	return false;
}

function NotifyPawnDied(Rx_Pawn P, byte FromTeam)
{
	if (!bInfantryCanCap)
		return;

	// When a player changes team, the team change happens before the pawn is killed, so it'd try removing them from the newteam, but there pawn is in the oldteam array. So just attempt remove from both.
	RemoveTouchingPawnBothTeams(P);

	Wake();
}

function NotifyVehicleDied(Rx_Vehicle V, byte FromTeam)
{
	if (!bVehiclesCanCap)
		return;

	RemoveTouchingVehicle(V, FromTeam);

	Wake();
}

function NotifyVehicleTeamChange(Rx_Vehicle V, byte from, byte to)
{
	if (!bVehiclesCanCap)
		return;

	RemoveTouchingVehicle(V, from);
	AddTouchingVehicle(V, to);

	Wake();
}

function RepProgress()
{
	ReplicatedProgress=CaptureProgress;
	//`log("bCap:"$bCaptured$" CappinTeam:"$CapturingTeam$" Prog:"$CaptureProgress$" GDI:"$GDICount $" Nod:"$NodCount);
}

function Wake();

auto state NeutralIdle
{
	event Tick( float DeltaTime );

	function Wake()
	{
		if (GDICount > 0 || NodCount > 0)
			GotoState('NeutralActive');
	}
}

state NeutralActive
{
	event Tick( float DeltaTime )
	{		
		if (GDICount > NodCount)
		{
			if (CapturingTeam == TEAM_GDI)
			{
				CaptureProgress += DeltaTime * `GDICapRate;
				if (CaptureProgress >= 1)
				{
					CaptureProgress = 1;
					ReplicatedProgress = 1;
					CapturedBy(TEAM_GDI);
					GotoState('CapturedIdle');
				}
			}
			else
			{
				CaptureProgress -= DeltaTime * `GDICapRate;
				if (CaptureProgress <= 0)
				{
					CaptureProgress = 0;
					ReplicatedProgress = 0;
					BeginCaptureBy(TEAM_GDI);
				}
			}
		}
		else if (NodCount > GDICount)
		{
			if (CapturingTeam == TEAM_Nod)
			{
				CaptureProgress += DeltaTime * `NodCapRate;
				if (CaptureProgress >= 1)
				{
					CaptureProgress = 1;
					ReplicatedProgress = 1;
					CapturedBy(TEAM_Nod);
					GotoState('CapturedIdle');
				}
			}
			else
			{
				CaptureProgress -= DeltaTime * `NodCapRate;
				if (CaptureProgress <= 0)
				{
					CaptureProgress = 0;
					ReplicatedProgress = 0;
					BeginCaptureBy(TEAM_Nod);
				}
			}
		}
		else if (GDICount == 0 && NodCount == 0)
		{
			CaptureProgress -= DeltaTime*DrainRatePerSecond;
			if (CaptureProgress <= 0)
			{
				CaptureProgress = 0;
				ReplicatedProgress = 0;
				RestoredNeutral();
				GotoState('NeutralIdle');
			}
		}
		else	// implies (GDICount == NodCount && GDICount > 0 && NodCount > 0)
		{
			; // stalemate - do nothing.
		}
	}
}

state CapturedIdle
{
	event Tick( float DeltaTime );

	function Wake()
	{
		if (CapturingTeam == TEAM_GDI && NodCount > GDICount)
			GotoState('CapturedActive');
		else if (CapturingTeam == TEAM_Nod && GDICount > NodCount)
			GotoState('CapturedActive');
	}
}

state CapturedActive
{
	event Tick( float DeltaTime )
	{
		local int Defenders, Offenders;

		if (CapturingTeam == TEAM_GDI)
		{
			Defenders = GDICount;
			Offenders = NodCount;
		}
		else if (CapturingTeam == TEAM_Nod)
		{
			Defenders = NodCount;
			Offenders = GDICount;
		}

		if (Offenders > Defenders)
		{
			if (CaptureProgress >= 1)
				BeginNeutralizeBy( CapturingTeam == TEAM_GDI ? TEAM_Nod : TEAM_GDI );
			CaptureProgress -= DeltaTime * `OffendersCapRate;
			if (CaptureProgress <= 0)
			{
				CaptureProgress = 0;
				ReplicatedProgress = 0;
				NeutralizedBy( CapturingTeam == TEAM_GDI ? TEAM_Nod : TEAM_GDI );
				GotoState('NeutralActive');
			}
		}
		else if (Offenders == Defenders && Offenders > 0)
		{
			// Stalemate - do nothing
		}
		else	// implies (Defenders > Offenders || Defenders == 0 && Offenders == 0)
		{
			if (CaptureProgress < 1)
			{
				if (Defenders > Offenders)
					CaptureProgress += DeltaTime * `DefendersCapRate;
				else if (Defenders == 0)
					CaptureProgress += DeltaTime*DrainRatePerSecond;
			}
			if (CaptureProgress >= 1)
			{
				CaptureProgress = 1;
				ReplicatedProgress = 1;
				RestoredCaptured();
				GotoState('CapturedIdle');
			}
		}
	}
}

function BeginCaptureBy(byte TeamIndex)
{
	CapturingTeam = TeamIndex;
	if (AssociatedActor != None)
		AssociatedActor.NotifyBeginCaptureBy(TeamIndex);
}

function CapturedBy(byte TeamIndex)
{
	bCaptured = true;
	CapturingTeam = TeamIndex;
	if (AssociatedActor != None)
		AssociatedActor.NotifyCapturedBy(TeamIndex);

	if (TeamIndex == TEAM_GDI)
		GiveScore(FullCaptureScore, TEAM_GDI);
	else if (TeamIndex == TEAM_Nod)
		GiveScore(FullCaptureScore, TEAM_Nod);
}

function BeginNeutralizeBy(byte TeamIndex)
{
	if (AssociatedActor != None)
		AssociatedActor.NotifyBeginNeutralizeBy(TeamIndex);
}

function NeutralizedBy(byte TeamIndex)
{
	local byte PreviousOwner;
	PreviousOwner = CapturingTeam;
	
	bCaptured = false;
	CapturingTeam = TeamIndex;
	if (AssociatedActor != None)
		AssociatedActor.NotifyNeutralizedBy(TeamIndex, PreviousOwner);

	if (TeamIndex == TEAM_GDI)
		GiveScore(FullNeutralizeScore, TEAM_GDI);
	else if (TeamIndex == TEAM_Nod)
		GiveScore(FullNeutralizeScore, TEAM_Nod);
}

function RestoredNeutral()
{
	CapturingTeam = 255;
	if (AssociatedActor != None)
		AssociatedActor.NotifyRestoredNeutral();
}

function RestoredCaptured()
{
	if (AssociatedActor != None)
		AssociatedActor.NotifyRestoredCaptured();
}

function GiveScore(float Amount, byte ToTeam)
{
	local float share;
	local Rx_Pawn P;
	local Rx_Vehicle V;

	if (ToTeam == TEAM_GDI)
	{
		share = Amount / GDICount;
		foreach TouchingGDIPawns(P)
			Rx_PRI(P.PlayerReplicationInfo).AddScoreToPlayerAndTeam(share);
		foreach TouchingGDIVehicles(V)
		{
			// TODO add score to first occupied seat or split amongst vehicle?
		}
	}
	else if (ToTeam == TEAM_Nod)
	{
		share = Amount / NodCount;
		foreach TouchingNodPawns(P)
			Rx_PRI(P.PlayerReplicationInfo).AddScoreToPlayerAndTeam(share);
		foreach TouchingNodVehicles(V)
		{
			// TODO part 2
		}
	}
}

simulated function byte GetOwningTeam()
{
	if (bCaptured)
		return CapturingTeam;
	else
		return 255;
}

DefaultProperties
{
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=512.0
		CollisionHeight=256.0
		BlockNonZeroExtent=true
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=true
		bDrawBoundingBox=true
		bDrawNonColliding=true
		HiddenGame=false
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bOnlyDirtyReplication=true
	NetUpdateFrequency=8
	RemoteRole=ROLE_SimulatedProxy
	bHidden=false
	NetPriority=+1.0
	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false



	bAlwaysRelevant=true

	bCaptured=false
	CapturingTeam=255
	CaptureProgress=0
	ReplicateProgressTime=0.5

	FullCaptureScore=100
	FullNeutralizeScore=100
	BaseCapRatePerSecond=0.1
	BonusCapRatePerSecond=0.02
	MaxCapRatePerSecond=0.2
	DrainRatePerSecond=0.05

	bInfantryCanCap=true
	bVehiclesCanCap=false
	InitialTeam=255
}