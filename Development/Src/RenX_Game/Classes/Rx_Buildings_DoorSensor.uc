class Rx_Buildings_DoorSensor extends Actor;

var repnotify Rx_BuildingAttachment_Door  Door;
var CylinderComponent           CollisionCylinder;

simulated function RegisterDoor( Rx_BuildingAttachment_Door inDoor )
{
	Door = inDoor;
	Door.DoorSensor = self;
	CollisionCylinder.SetCylinderSize(Door.GetSensorRadius(),Door.GetSensorHeight());
	//`log ("Door registered" @ Door.GetSensorRadius());
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if( Door != none )
	{
		if(Pawn(Other) != None && Rx_Bot(Pawn(Other).Controller) != None) {
			Rx_Bot(Pawn(Other).Controller).setStrafingDisabled(true);
		}		
		Door.SensorTouch(Other);
	}
}

simulated event UnTouch( Actor Other )
{	
	if ( Door != none )
	{
		if(Pawn(Other) != None && Rx_Bot(Pawn(Other).Controller) != None
				&& !Rx_Bot(Pawn(Other).Controller).IsInBuilding()) {
			Rx_Bot(Pawn(Other).Controller).setStrafingDisabled(false);
		}
		Door.SensorUnTouch(Other);
	}	
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
