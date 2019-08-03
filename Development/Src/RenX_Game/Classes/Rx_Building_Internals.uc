class Rx_Building_Internals extends Actor
	abstract;

/** Skeletal Mesh that contains all the bones for      *
  * spawn Doors, PT's, MCT's, Particle Systems, etc... */
var SkeletalMeshComponent                   BuildingSkeleton;

/** Used to replicate mesh to clients */
var repnotify transient SkeletalMesh        ReplicatedMesh;

/** Light Environment Component for lighting of the skeletal mesh */
var DynamicLightEnvironmentComponent        LightEnvironment;

/** For Debugging */
var bool                                    bBuildingDebug; 

/** The actor that spawns and owns this actor. It provides the static visual elements for this building */
var repnotify Rx_Building                   BuildingVisuals;

/** Team Numbers in handy ENUM form */
enum TEAM
{
	TEAM_GDI,
	TEAM_NOD,
	TEAM_UNOWNED
};

/** building belongs to team with this TeamID (normally 0 ->GDI, 1->NOD) */
var TEAM                                    TeamID;

/** Name of the building that is displayed on the HUD */
var localized const string                  BuildingName;

/*************************************************************/
/* Attachments - PT's, MCT, Doors, Particle Systems, etc...  */
/*************************************************************/
var array<Rx_BuildingAttachment>  BuildingAttachments;
var array< class<Rx_BuildingAttachment> >   AttachmentClasses;

var const string NodPTAttachment;
var const string GDIPTAttachment;

var array<vector>	Trace2dTargets;
const MAX_TRACE2D_TARGETS = 10;



replication
{
	
	if ( bNetDirty && Role == ROLE_Authority )
		BuildingVisuals,ReplicatedMesh;
		
	if ( bNetInitial && Role == ROLE_Authority )
		TeamID;
}

simulated event ReplicatedEvent( name VarName )
{
	if ( VarName == 'ReplicatedMesh' )
	{
		BuildingSkeleton.SetSkeletalMesh(ReplicatedMesh);
	}
	if ( VarName == 'BuildingVisuals' )
	{
		Init(BuildingVisuals,false);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	// Gotta send the skeletal mesh to the client so they can see it
	if (Role == ROLE_Authority && BuildingSkeleton != None)
	{
		ReplicatedMesh = BuildingSkeleton.SkeletalMesh;
	}
	
	//Init(BuildingVisuals,false);
}

simulated event Tick (float DeltaTime)
{
	BuildingVisuals.TickBuilding(DeltaTime);
	super.Tick(DeltaTime);
}

// Initialize the building and set the visual section of the building
simulated function Init(Rx_Building Visuals, bool isDebug )
{
	BuildingVisuals = Visuals;
	bBuildingDebug = isDebug;
	GetPTClasses();
	SetupBuildingComponents();
	SetupTrace2dTargets();
}

simulated function GetPTClasses()
{
	local class<Rx_BuildingAttachment> pt;
	if ( GetTeamNum() == TEAM_GDI )
	{
		pt = class<Rx_BuildingAttachment>( DynamicLoadObject( GDIPTAttachment, class'Class' ) );
	}
	else
	{
		pt = class<Rx_BuildingAttachment>( DynamicLoadObject( NodPTAttachment, class'Class' ) );
	}

	if ( pt != none )
	{
		AttachmentClasses.AddItem(pt);
	}
	
}

simulated function SetupBuildingComponents()
{
   local SkeletalMeshSocket SMS;
   local class<Rx_BuildingAttachment> attachClass;
   local Vector V;
   local Rotator R;

	`Log ("Spawning Attachments for"@self.Class, bBuildingDebug,'Buildings');

	foreach BuildingSkeleton.SkeletalMesh.Sockets(SMS)
	{
		`Log ("Checking socket -"@SMS.SocketName@"for attachment to spawn.", bBuildingDebug, 'Buildings');
		BuildingSkeleton.GetSocketWorldLocationAndRotation(SMS.SocketName, V, R);
		foreach AttachmentClasses(attachClass)
		{
			if (attachClass.default.bSpawnOnClient)
			{
				if (WorldInfo.NetMode == NM_DedicatedServer)
					continue;
			}
			else if (WorldInfo.NetMode == NM_Client)
				continue;
			
			if ( InStr(Caps(SMS.SocketName), Caps(attachClass.default.SocketPattern)) >= 0 )
			{
				`log("Spawning Attachment"@attachClass.Name,bBuildingDebug,'Buildings');
				SpawnBuildingAttachment(attachClass, V, R, SMS.SocketName);
			}
		}
	}
}

simulated function SpawnBuildingAttachment( class<Rx_BuildingAttachment> attachmentClass, Vector L, Rotator R, name SocketName )
{
	local Rx_BuildingAttachment attachClass;
	attachClass = Spawn(attachmentClass,self,name(self.Name$attachmentClass.default.SpawnName),L,R);
	if ( attachClass != none )
	{
		attachClass.Init(self, SocketName);
		BuildingAttachments.AddItem(attachClass);
		`log("Spawned"@attachmentClass.Name@"At"@L@"With a Rotation of"@R,bBuildingDebug,'Buildings');
	} 
	else
	{
		`log("CRITICAL ERROR: Could not spawn "@attachmentClass.Name@"At"@L@"With a Rotation of"@R,,'Buildings');
	}
}

simulated function SetupTrace2dTargets()
{
	local int index, i;
	local string s;
	local SkeletalMeshSocket SMS;
	local array<vector> temp;
	local array<int> indices;
	local vector V;
	local rotator R;

	temp.Length = MAX_TRACE2D_TARGETS;

	foreach BuildingSkeleton.SkeletalMesh.Sockets(SMS)
	{
		if ( InStr(SMS.SocketName, "Trace2d_") >= 0 )
		{
			s = Split(SMS.SocketName, "Trace2d_", true);
			index = int(s);
			if ( (index > 0 || Left(s, 1) == "0") && index < MAX_TRACE2D_TARGETS )
			{
				BuildingSkeleton.GetSocketWorldLocationAndRotation(SMS.SocketName, V, R);
				temp[index] = V;
				indices.AddItem(index);
			}
		}
	}

	if (indices.Length <= 0)
	{
		`log("BUILDING ERROR: No Trace2d_X sockets exist in "$self);
	}
	else
	{
		while (indices.Length > 0)
		{
			index = 0;
			for (i=1; i<indices.Length; ++i)
			{
				if (indices[i] < indices[index])
					index = i;
			}
			Trace2dTargets.AddItem(temp[indices[index]]);
			indices.Remove(index, 1);
		}
	}
}

simulated event byte ScriptGetTeamNum()
{
	return TeamID;
}

simulated function int GetHealth();

simulated function int GetMaxHealth();

simulated function int GetTrueMaxHealth(); //Max Health minus armor

simulated function int GetArmor();

simulated function int GetMaxArmor();


simulated function string GetBuildingName()
{
	return BuildingName;
}

simulated function bool IsDestroyed()
{
	return false;
}

simulated function OnBuildingDestroyed();

DefaultProperties
{
	/***************************************************/
	/*              Actor Settings                     */
	/***************************************************/
	RemoteRole               = ROLE_SimulatedProxy
	Physics                  = PHYS_None
	bStatic                  = False
	bCollideActors           = True
	bBlockActors             = True
	bWorldGeometry           = False
	bCollideWorld            = False
	bNoEncroachCheck         = True
	bProjTarget              = True
	bUpdateSimulatedPosition = False
	bAlwaysRelevant          = True
	bGameRelevant            = True
	NetUpdateFrequency	     = 10
	bOnlyDirtyReplication    = True
	
	/***************************************************/
	/*               Building Variables                */
	/***************************************************/	
	bBuildingDebug           = False
	NodPTAttachment          = "RenX_Game.Rx_BuildingAttachment_PT_Nod"
	GDIPTAttachment          = "RenX_Game.Rx_BuildingAttachment_PT_GDI"
	AttachmentClasses.Add(Rx_BuildingAttachment_MCT)

	AttachmentClasses.Add(Rx_BuildingDmgFx_DeathExplosion)
	AttachmentClasses.Add(Rx_BuildingDmgFx_ElectricalDamage)
	AttachmentClasses.Add(Rx_BuildingDmgFx_ElectricalSparks)
	AttachmentClasses.Add(Rx_BuildingDmgFx_LargeSmoke)
	AttachmentClasses.Add(Rx_BuildingDmgFx_HugeFire)
	AttachmentClasses.Add(Rx_BuildingDmgFx_LargeFire)
	AttachmentClasses.Add(Rx_BuildingDmgFx_MediumFire)
	AttachmentClasses.Add(Rx_BuildingDmgFx_SmallFire)
	AttachmentClasses.Add(Rx_BuildingDmgFx_SmallSmoke)
	AttachmentClasses.Add(Rx_BuildingDmgFx_Sparks)
	AttachmentClasses.Add(Rx_BuildingDmgFx_SteamSmoke)
	AttachmentClasses.Add(Rx_BuildingDmgFx_AlarmLarge)
	AttachmentClasses.Add(Rx_BuildingDmgFx_AlarmSmall)

	/***************************************************/
	/*                Building Skeleton                */
	/***************************************************/
	Begin Object Class=AnimNodeSequence Name=AnimNodeSeq0
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled            = True
		bDynamic            = True
		bSynthesizeSHLight  = True
		bCastShadows 		= False
		TickGroup           = TG_DuringAsyncWork
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment = MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=BuildingSkeletalMeshComponent
		Animations                  = AnimNodeSeq0
		bUpdateSkelWhenNotRendered  = False
		CollideActors               = false
		BlockActors                 = False
		BlockZeroExtent             = True
		BlockNonZeroExtent          = False
		BlockRigidBody              = False
		AlwaysLoadOnServer          = true
		LightEnvironment            = MyLightEnvironment
		RBChannel                   = RBCC_GameplayPhysics
		RBCollideWithChannels       = (Default=True,BlockingVolume=True,GameplayPhysics=True,EffectPhysics=True)
		Translation					= (Z=-150)
	End Object
	BuildingSkeleton   = BuildingSkeletalMeshComponent
	CollisionComponent = BuildingSkeletalMeshComponent
	Components.Add(BuildingSkeletalMeshComponent)
		
}
