//=============================================================================
// FoliageCollisionVolume: a vehicle collision solution
// used to collide certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes
// Created by Pinheiro, https://forums.epicgames.com/threads/91 ... on-foliage 
// Heavily modified by Ruud033 & Handepsilon
// Thanks Crnyo and nameloc for the additional help
//=============================================================================

class FoliageCollisionVolume extends Volume
placeable;
var BlockingMesh CreatedBlockingMesh;
var Array<BlockingMesh> SpawnedBlockingMeshes;
var bool bBlockersHaveSpawned; //Check if blockers have already spawned. If it has, no need to spawn more
var Array<Vehicle> VehiclesInVolume;

static final function vector MatrixGetScale(Matrix TM)
{
local Vector s;
s.x = sqrt(TM.XPlane.X**2 + TM.XPlane.Y**2 + TM.XPlane.Z**2);
s.y = sqrt(TM.YPlane.X**2 + TM.YPlane.Y**2 + TM.YPlane.Z**2);
s.z = sqrt(TM.ZPlane.X**2 + TM.ZPlane.Y**2 + TM.ZPlane.Z**2);
return s;
}

//Search for each tree apart, the code goes trough the volume and searches each tree.
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local InstancedFoliageActor ac;
	local InstancedStaticMeshComponent comp;
	local vector loc, scale;
	local Rotator rot;
	local int i, j;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	If(Other.IsA('Vehicle'))
	{
	VehiclesInVolume.AddItem(Vehicle(Other));
	
		if(!bBlockersHaveSpawned)
		{
		bBlockersHaveSpawned = true;

			//look for the InstancedFoliageActor
			foreach AllActors(class'InstancedFoliageActor',ac)
			{
				//iterate through the various foliage components
				for(i=0; i<ac.InstancedStaticMeshComponents.Length; i++)
				{
					comp = ac.InstancedStaticMeshComponents[i];
					
					if (comp.StaticMesh.BodySetup != none)
					{
						//iterate through the various meshes in this component, if it has a collision model
						for (j=0; j<comp.PerInstanceSMData.Length; j++)
						{
							//decompose the instance's transform matrix
							loc = MatrixGetOrigin(comp.PerInstanceSMData[j].Transform);
							if (ContainsPoint(loc)) //check if this instance is within the volume
							{
							rot = MatrixGetRotator(comp.PerInstanceSMData[j].Transform);
							scale = MatrixGetScale(comp.PerInstanceSMData[j].Transform);
							CreatedBlockingMesh = Spawn(class'BlockingMesh',ac,,loc,rot);
							CreatedBlockingMesh.StaticMeshComponent.SetStaticMesh(comp.StaticMesh);
							CreatedBlockingMesh.SetDrawScale3D(scale);
							SpawnedBlockingMeshes.AddItem(CreatedBlockingMesh);
							}
						}
					}
				}
			}
		}
	}
}

//Destroy the spawned meshes once untouched
event Untouch( Actor Other )
{
local int i;
Super.Untouch(Other);

	VehiclesInVolume.RemoveItem(Vehicle(Other));
	if(VehiclesInVolume.Length <= 0)
	{
		for(i=0; i < SpawnedBlockingMeshes.Length; i++)
		{
		SpawnedBlockingMeshes[i].Destroy();//if bNoDelete is set to false in defaultproperties; this deletes it
		// Ok removed SpawnedBlockingMeshes.Remove(i--,1); // Hande's note : This is not necessary as the below function will automatically empty the array
		}
	SpawnedBlockingMeshes.Length = 0;
	bBlockersHaveSpawned = false;
	}
}

defaultproperties
{
bColored=true
BrushColor=(R=0,G=255,B=255,A=255)

bCollideActors=true
SupportedEvents.Empty
SupportedEvents(0)=class'SeqEvent_Touch'
}