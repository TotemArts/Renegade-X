class Rx_BuildingAttachment_Door extends Rx_BuildingAttachment
    abstract;

var SkeletalMeshComponent       DoorSkeleton;
var Rx_Buildings_DoorSensor     DoorSensor;
var LightEnvironmentComponent   LightComp;
var TEAM                        TeamID;
var int                         NumActorsTouching;
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
			OpenDoor();
		else
			CloseDoor();
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollision(true, true);

	DoorSensor = Spawn(class'Rx_Buildings_DoorSensor',self,,Location,Rotation);

	if ( DoorSensor != none )
	{
		DoorSensor.RegisterDoor(self);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer) 
	{
		AnimNode = DoorSkeleton.FindAnimNode(OpenAnimName);
	}
}

simulated event byte ScriptGetTeamNum()
{
    return TeamID;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, Vector HitLocation, Vector Momemtum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
}

simulated function SensorTouch( Actor Other )
{
	if( Rx_Vehicle(Other) != none && bOpenForVehicles == false)
			return;

	if( ClassIsChildOf(Other.Class,class'Pawn') )
	{
		if( NumActorsTouching == 0 )
		{
			if(Role == ROLE_Authority)
			{
				OpenDoor();
			}
		}
		NumActorsTouching++;
	}
}

simulated function SensorUnTouch( Actor Other )
{
	if( Rx_Vehicle(Other) != none && bOpenForVehicles == false)
			return;

	if(ClassIsChildOf(Other.Class,class'Pawn'))
	{
		if(NumActorsTouching >= 1) 
		{
			NumActorsTouching--;
			if( NumActorsTouching == 0 )
			{
				if(Role == ROLE_Authority)
				{
					CloseDoor();
				}
			}
		}
		
	}
}

simulated function OpenDoor()
{
	if (!bOpen)
	{
		SetCollision( False, False, False );
		bOpen=true;

		if(WorldInfo.NetMode != NM_DedicatedServer)
		{
			PlaySound(OpeningSound,true);
			DoorSkeleton.PlayAnim(OpenAnimName,DoorOpenTime, false,false, ,false);
		}
		else
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
		bOpen=false;

		if(WorldInfo.NetMode != NM_DedicatedServer)
		{
			PlaySound(ClosingSound,true);
			DoorSkeleton.PlayAnim(OpenAnimName,DoorOpenTime, false, false, ,true);
		}
		else
		{
			bServerOpen = false;
		}
	}
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
	
	/**
	OpeningSound=SoundCue'TS_BU_Barracks.Sounds.SC_Door_Open'
	ClosingSound=SoundCue'TS_BU_Barracks.Sounds.SC_Door_Close'*/
}
