class Rx_CommanderSupportBeacon extends Actor
abstract; 

/** Who owns this */
var Controller	InstigatorController;

/*Index of owning team*/
var byte	TeamIndex; 



/**The Visual/Audio Components*/

/** The deployable's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;
var PointLightComponent 			LightComp, RadialLight;
var SkeletalMeshComponent 			Mesh;

var ParticleSystem 					BeaconParticleEffect ; 
var ParticleSystemComponent 		ParticleComp; 
var CanvasIcon 						IconType; //Icon to use to signify what this is
var repnotify	bool				bDeployed; 

/********************************/

/**************************/
/******The Support********/
/************************/
/*These are all set in the Initialize() function and retrieves from Rx_CommanderSupport_BeaconInfo classes*/

var class<Rx_CommanderSupport_BeaconInfo> BeaconInfoClass; 

/**********************************************************************/

var int DeployTime; //Holds the time in which the beacon was set

replication 
{
	if(bnetdirty || bNetInitial)
		TeamIndex, BeaconInfoClass, bDeployed; 
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bDeployed')
	{
		if(bDeployed)  
		{
			InitParticles();
			DeployTime = WorldInfo.TimeSeconds ;	
		}
	}
	else
	super.ReplicatedEvent(VarName);
}

simulated function InitParticles()
{
	local rotator R; 
	//R.Pitch = 0; //Always remain vertical EDIT: this is vertical when flat, dummy
	//65536 360 degrees
	if(BeaconInfoClass.default.Emitter_BeaconTemplate != none) BeaconParticleEffect = BeaconInfoClass.default.Emitter_BeaconTemplate;
	
	ParticleComp = WorldInfo.MyEmitterPool.SpawnEmitter(BeaconParticleEffect, location, R,self);	
}

simulated function Init(byte TI, class<Rx_CommanderSupport_BeaconInfo> BeaconInfo, Controller MyInstigator)
{
	local byte AntiTeamByte;
	
	DeployTime = WorldInfo.TimeSeconds ;	
	
	
	
	if(ROLE == ROLE_AUTHORITY) 
	{
		BeaconInfoClass = BeaconInfo; 
		InstigatorController = MyInstigator;
		SetTimer(BeaconInfoClass.default.AbilityCallTime, false, 'CallAbility');
		TeamIndex=TI; 
		AntiTeamByte = TeamIndex == 0 ? 1 : 0 ;
		if(BeaconInfoClass.default.bBroadcastToTeam) 
			Rx_Game(WorldInfo.Game).CTextBroadCast(TeamIndex, "-Friendly" @ GetName() @ "Inbound-") ; 
		
		if(BeaconInfoClass.default.bBroadcastToEnemy) 
			Rx_Game(WorldInfo.Game).CTextBroadCast(AntiTeamByte, "-Enemy" @ GetName() @ "Inbound-", 'Red',,,BeaconInfoClass.default.bPlayWarningSiren) ; 
		
		bDeployed = true; 
		
	}
	
	if(class<Rx_CommanderSupport_BeaconInfo_AOEBuff>(BeaconInfoClass) != none) 
	{
		SetCollision(false, false); 
		SetHidden(true); 
	} 
	
	if(WorldInfo.NetMode != NM_DedicatedServer) InitParticles();
	
}

function CallAbility()
{
	local Rx_SupportVehicle SupVehicle;
	local rotator AdjustedRotation;
	
	AdjustedRotation = rotation;
	
	AdjustedRotation.Yaw = rotation.Yaw; //16384; //We just need your rotation
	
	if(BeaconInfoClass.static.GetSupportVehicleClass(TeamIndex) != none ) 
	{
		SupVehicle = Spawn(BeaconInfoClass.static.GetSupportVehicleClass(TeamIndex),,,location+BeaconInfoClass.default.SupportSpawnLocation,AdjustedRotation,,true);
		SupVehicle.Initialize(InstigatorController, TeamIndex, location, self, BeaconInfoClass.default.SupportPayload, BeaconInfoClass.default.CPCost*0.5); 
	}
	
	if(BeaconInfoClass.default.bAffectArea) 
	{
		BeaconInfoClass.static.DoAreaEffect(self, location, TeamIndex);
	}
	
	SetTimer(BeaconInfoClass.default.LingerTime, false, 'TimerEndSelf');
}


simulated function TimerEndSelf()
{
	Destroy(); 
}

simulated function Destroyed()
{
	//`log("DEstroyed");
 if(WorldInfo.NetMode != NM_DedicatedServer) ParticleComp.DeactivateSystem(); 

  Super.Destroyed();
   
}

simulated function string GetName()
{
	return BeaconInfoClass.default.PowerName ; 
}

simulated event byte ScriptGetTeamNum()
{
	return TeamIndex;
}

simulated function int GetTimeLeft()
{
	return max(0, int(BeaconInfoClass.default.AbilityCallTime - (WorldInfo.TimeSeconds - DeployTime)));
}

simulated function PostBeginPlay()
{
	
	super.PostBeginPlay();
	
		
}


event Landed( vector HitNormal, actor FloorActor )
{
	//if(Pawn(FloorActor) != none) return; 
	super.Landed(HitNormal, FloorActor);
	SetPhysics(PHYS_NONE); 
	 //Just stop where you are entirely 
	SetBase(none); 
	SetCollision(false, false);
	Velocity = vect(0,0,0); 
	Acceleration = vect(0,0,0); 
	SetTimer(1.0,false,'ReplicatePositionAfterLanded');
}

/** to make sure final location gets replicated */
function ReplicatePositionAfterLanded()
{
	ForceNetRelevant();
	bUpdateSimulatedPosition = true;
	bNetDirty = true;   	
}

defaultproperties
{
   Physics=PHYS_Falling   
   RemoteRole=ROLE_SimulatedProxy
   
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
       bEnabled                        = True
      bSynthesizeSHLight              = True
      bUseBooleanEnvironmentShadowing = False
   End Object
   LightEnvironment=MyLightEnvironment
   Components.Add(MyLightEnvironment)
   
   
    Begin Object Class=SkeletalMeshComponent Name=BeaconMesh
      SkeletalMesh=SkeletalMesh'RX_WP_Nuke.Mesh.SK_WP_Nuke_Deployed'
      PhysicsAsset=PhysicsAsset'RX_WP_Nuke.Mesh.SK_WP_Nuke_Deployed_Physics'
      Scale3D=(X=1.0,Y=1.0,Z=1.0)
      Scale=1.0f
	  
	  BlockNonZeroExtent   = true 
      BlockZeroExtent      = true
      CollideActors        = true
      BlockActors          = true
      BlockRigidBody       = false
	  CanBlockCamera		= false 
      LightEnvironment = MyLightEnvironment
	  
   End Object
   Mesh = BeaconMesh 
   Components.Add(BeaconMesh)
	
	
   Begin Object Class=CylinderComponent Name=CollisionCylinder
      CollisionRadius=+001.100000
      CollisionHeight=+005.000
	  BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
   End Object
   CollisionComponent=CollisionCylinder
   Components.Add(CollisionCylinder)	
   
   Begin Object Class=PointLightComponent Name=RadialLight
	Brightness=12.0
	Radius=600
	LightColor=(R=255,G=255,B=255)
	bEnabled=TRUE
   End Object
   LightComp = RadialLight
   Components.Add(RadialLight)
   
   bAlwaysRelevant      = true
   
   BeaconParticleEffect=ParticleSystem'rx_fx_envy.Fire.P_Flare_Large_Yellow'
  
   bWorldGeometry          = true //true  //Set to false to not block the camera 
   //bWorldGeometry          = false
   bPushedByEncroachers    = false
   bIgnoreEncroachers      = false
   bOrientOnSlope          = false
   bIgnoreRigidBodyPawns   = false  
   bNoEncroachCheck        = true
   //bNoEncroachCheck        = false
   bAlwaysEncroachCheck    = false
  
   bCollideActors=true
	bCollideWorld=true 
    bCollideComplex=false
	bBlockActors=true
   
   bCanStepUpOn = false 
   
   bHardAttach = false 
   //StaticMesh'RX_FX_Munitions.Missile.SM_Missile_AGT'
   //SoundCue'RX_SoundEffects.Missiles.SC_CruiseMissileFire'
   
	
  
}