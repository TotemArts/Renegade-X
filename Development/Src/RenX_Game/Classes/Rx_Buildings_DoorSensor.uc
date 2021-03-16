class Rx_Buildings_DoorSensor extends Actor;

var repnotify Rx_BuildingAttachment_LockableDoor door;

var CylinderComponent           CollisionCylinder;

replication
{
	if ((bNetInitial || bNetDirty) && Role == ROLE_Authority)
		door;
}

simulated function RegisterDoor( Rx_BuildingAttachment_LockableDoor inDoor )
{
	door = inDoor;
	door.DoorSensor = self;
	CollisionCylinder.SetCylinderSize(door.GetSensorRadius(), door.GetSensorHeight());
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	DoCollide(none);
}

simulated event UnTouch( Actor Other )
{	
	DoCollide(Other);
}

simulated function DoCollide(Actor ignoredActor) 
{
	local int authorizedActorCount;
	local Actor loopActor;

	if (door == none) 
	{
		return;
	}

	authorizedActorCount = 0;

	ForEach TouchingActors(class'Actor', loopActor) {
		if (!door.ShouldAllowActor(loopActor) || loopActor == IgnoredActor) {
			continue;
		}

		authorizedActorCount++;
	}

	door.UpdateActorCountTouchingDoor(authorizedActorCount);
}

DefaultProperties
{
	RemoteRole          = ROLE_SimulatedProxy
	CollisionType       = COLLIDE_TouchAllButWeapons
	bCollideActors      = True 

	Begin Object Class=CylinderComponent Name=CollisioncMP
		CollisionRadius     = 350.0f
		CollisionHeight     = 100.0f
		BlockNonZeroExtent  = True
		BlockZeroExtent     = false
		bDrawNonColliding   = True
		bDrawBoundingBox    = False
		BlockActors         = False
		CollideActors       = True
	End Object
	CollisionComponent = CollisionCmp
	CollisionCylinder  = CollisionCmp
	Components.Add(CollisionCmp)
	
	bAlwaysRelevant     	= True
	bOnlyDirtyReplication 	= True
	NetUpdateFrequency  	= 20
	
}
