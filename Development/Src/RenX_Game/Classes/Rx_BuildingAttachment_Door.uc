class Rx_BuildingAttachment_Door extends Rx_BuildingAttachment
    abstract;

var SkeletalMeshComponent       DoorSkeleton;

var LightEnvironmentComponent   LightComp;
var TEAM                        TeamID;
var bool                        bOpen;
var repnotify bool              bServerOpen;
var const float                 SensorRadius;
var const float                 SensorHeight;

var name                        OpenAnimName;
var name                        ClosedAnimName;
var AnimNode                    AnimNode;

var float                       DoorOpenTime;

var SoundCue   				  	OpeningSound;
var SoundCue   				  	ClosingSound;

var bool                        bOpenForVehicles;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		bServerOpen;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bServerOpen')
	{
		if (bServerOpen)
		{
			OpenDoor();
		}
		else
		{
			CloseDoor();
		}
			
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollision(true, true);

	if (WorldInfo.NetMode != NM_DedicatedServer) 
	{
		AnimNode = DoorSkeleton.FindAnimNode(OpenAnimName);
	}
}

simulated function CheckGameStart()
{
	if (WorldInfo.GRI.bMatchHasBegun)
	{
		bWorldGeometry = true;
		ClearTimer(nameof(CheckGameStart));
	}
}

simulated event byte ScriptGetTeamNum()
{
    return TeamID;
}

simulated function UpdateActorCountTouchingDoor(int actorTouchingDoorCount)
{
	if (Role != ROLE_Authority) {
		return;
	}

	if (actorTouchingDoorCount > 0)
	{
		OpenDoor();
	}
	else
	{
		CloseDoor();
	}
}

simulated function OpenDoor()
{
	if (!bOpen)
	{
		SetCollision( False, False, False );
		bOpen = true;

		if(WorldInfo.NetMode != NM_DedicatedServer )
		{
			PlaySound(OpeningSound, true);
			DoorSkeleton.PlayAnim(OpenAnimName, DoorOpenTime, false, false, ,false);
		}
		else if (Role == ROLE_Authority)
		{
			bServerOpen = true;
		}
	}
}

simulated function CloseDoor()
{
	if (bOpen)
	{
		SetCollision( True, True, True );
		bOpen = false;

		if(WorldInfo.NetMode != NM_DedicatedServer)
		{
			PlaySound(ClosingSound, true);
			DoorSkeleton.PlayAnim(OpenAnimName, DoorOpenTime, false, false, ,true);
		}
		else
		{
			bServerOpen = false;
		}
	}
}

// Override this function to change who is allowed to trigger door
simulated function bool ShouldAllowActor(Actor actor) 
{
	local bool isVehicle;
	local bool isPlayer;

	isVehicle = Rx_Vehicle(actor) != none && bOpenForVehicles;
	isPlayer = Rx_Pawn(actor) != none;

	return isPlayer || isVehicle;
}

simulated function float GetSensorHeight()
{
	return SensorHeight;
}

simulated function float GetSensorRadius()
{
	return SensorRadius;
}

defaultproperties
{
	RemoteRole          = ROLE_SimulatedProxy
	bCollideWhenPlacing = False
	CollisionType       = COLLIDE_CustomDefault
	bAlwaysRelevant     = True
	bCollideActors      = True
	bBlockActors        = true
	bOpenForVehicles    = true

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled                        = True
		bSynthesizeSHLight              = True
		bUseBooleanEnvironmentShadowing = False
		bCastShadows 					= False
	End Object
	LightComp = MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=DoorSkelCmp
		LightEnvironment = MyLightEnvironment
	End Object
	Components.Add(DoorSkelCmp)
	DoorSkeleton = DoorSkelCmp
	
	OpeningSound=SoundCue'rx_bu_door.Sounds.SC_Door_Open'
	ClosingSound=SoundCue'rx_bu_door.Sounds.SC_Door_Open'
}
