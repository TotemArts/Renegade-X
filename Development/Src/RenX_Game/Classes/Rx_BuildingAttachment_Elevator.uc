class Rx_BuildingAttachment_Elevator extends Rx_BuildingAttachment;

var float TopZ;
var float StayUpTime;
var float LiftSpeed;
var vector TopPosition;
var vector BottomPosition;
var SoundCue   				  	AscendingSound;
var SoundCue   				  	DescendingSound;
var LightEnvironmentComponent   LightComp;
var repnotify bool				bLiftActivated;

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		bLiftActivated;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bLiftActivated')
	{
		if(bLiftActivated)
		{
			Ascend();
		}
	}
}

simulated function Ascend();

simulated function PostBeginPlay()
{
	TopPosition = Location + (Vect(0,0,1) * TopZ);
	BottomPosition = Location;
}

auto state Bottom
{
	simulated function BeginState(Name PreviousStateName)
	{
		SetLocation(BottomPosition);

		if(WorldInfo.NetMode == NM_DedicatedServer)
			bLiftActivated = false;
	}

	simulated function Bump( Actor Other, PrimitiveComponent OtherComp, vector HitNormal )
	{
		if(Role == ROLE_Authority && Pawn(Other) != None && !IsTimerActive('Ascend'))
		{
			SetTimer(0.5,false,'Ascend');
		}
	}

	simulated function Ascend()
	{
		if(WorldInfo.NetMode == NM_DedicatedServer)
			bLiftActivated = true;

		GoToState('Ascending');	
		PlaySound(AscendingSound,true);
	}
}

state Ascending
{
	simulated function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		Velocity.z += Acceleration.z * DeltaTime;

		if(Location.z >= TopPosition.z)
		{
			Velocity = vect(0,0,0);
			Acceleration.z = 0.f;
			GoToState('Top');
		}
		else if(Location.z == BottomPosition.z + (TopZ/2))
		{
			Acceleration.z = -LiftSpeed;
			Velocity.z = FMax(Velocity.z,0);
		}
		else
		{
			Acceleration.z = LiftSpeed;

		}
	}
}

state Descending
{
	simulated function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		Velocity.z += Acceleration.z * DeltaTime;

		if(Location.z <= BottomPosition.z)
		{
			Velocity = vect(0,0,0);
			Acceleration.z = 0.f;
			GoToState('Bottom');
		}
		else if(Location.z == BottomPosition.z + (TopZ/2))
		{
			Acceleration.z = LiftSpeed;
			Velocity.z = FMin(Velocity.z,0);
		}
		else
		{
			Acceleration.z = -LiftSpeed;
		}
	}
}

state Top
{
	simulated function BeginState(Name PreviousStateName)
	{
		SetTimer(StayUpTime,false,'Descend');
		SetLocation(TopPosition);
	}

	simulated function Descend()
	{
		GoToState('Descending');
		PlaySound(DescendingSound,true);
	}
}

simulated function Tick(float DeltaTime)
{
	SetLocation(Location + Velocity);
}

DefaultProperties
{

	RemoteRole          = ROLE_SimulatedProxy
	bAlwaysRelevant     = True
	bCollideActors      = True
	bBlockActors        = True
	BlockRigidBody      = True
	bUpdateSimulatedPosition = true;
	NetUpdateFrequency = 1.0
}