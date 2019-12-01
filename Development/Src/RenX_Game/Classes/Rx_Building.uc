class Rx_Building extends Actor
	abstract
	ClassGroup(Buildings)
	implements(RxIfc_SpotMarker)
	implements(RxIfc_EMPable);

/** Team Numbers in handy ENUM form */
enum TEAM
{
	TEAM_GDI,
	TEAM_NOD,
	TEAM_UNOWNED
};
// A list of all the different types of buildings
enum BuildingType
{
	BT_None,
	BT_Power,
	BT_Money,
	BT_Veh,
	BT_Inf,
	BT_Def,
	BT_Air,
	BT_Tech,
	BT_Rep,
	BT_Neutral
};

var(RenX_Buildings) TEAM                        TeamID;                 // building belongs to team with this TeamID (normally 0 -> GDI, 1-> Nod)
var(RenX_Buildings) int                         Health;                 // Starting Health for the building
var(RenX_Buildings) int                         HealthMax;                // Max Health for the building
var(RenX_Buildings) bool                        bBuildingDebug;         // Set to true to enable Debug Logging
var(RenX_Buildings) const BuildingType myBuildingType;

var class<Rx_Building_Internals>          BuildingInternalsClass; // Class of the internals that needs spawned
var repnotify Rx_Building_Internals             BuildingInternals;      // Instance of the internals that handles the logic like TakeDamage and the like
var(RenX_Buildings) bool bSignificant;									// Whether or not this building counts as victory condition and is shown in HUD


var(BuildingLights) array<PointLightComponent>  PointLightComponents;   // Point lights for the pre setup lighting
var(BuildingLights) array<SpotLightComponent>   SpotLightComponents;    // Spot lights for the PT's and MCT's for pre setup lighting
var array<StaticMeshComponent>                  StaticMeshPieces;
var Rx_BuildingObjective						myObjective;
var Rx_BuildingAttachment MCT;

var() StaticMeshComponent StaticExterior;
var() StaticMeshComponent StaticInterior;
var() StaticMeshComponent StaticInteriorComplex;
var() StaticMeshComponent PTScreens;


var() Array<NavigationPoint> ViableAttackPoints;

var(RenX_Buildings) Texture IconTexture;

replication
{
	//if( bNetInitial && Role == ROLE_Authority )
	if( bNetDirty && Role == ROLE_Authority )
		BuildingInternals;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'BuildingInternals' ) 
	{
		BuildingInternalsReplicated(); 
	}
	else
		super.ReplicatedEvent(VarName);
}	

simulated function BuildingInternalsReplicated()
{

}

simulated function Rx_BuildingAttachment GetMCT()
{

	local int i;
	local Rx_BuildingAttachment Attachment;
	
	if(MCT != None)
		return MCT;
	else if(BuildingInternals != None)
	{
		for (i = 0; i < BuildingInternals.BuildingAttachments.length; i++)
		{
			Attachment=BuildingInternals.BuildingAttachments[i];
			
			if(Attachment.IsA('Rx_BuildingAttachment_MCT'))
			{
				MCT = Attachment;
				return Attachment;	//found it, abandon everything else
			}
		}
	}

	return none;
	
}	

function byte GetBuildingType()
{
	return myBuildingType;
}

function PostBeginPlay()
{



	BuildingInternals = spawn(BuildingInternalsClass,self,BuildingInternalsClass.Name,Location,Rotation);

	
	if ( BuildingInternals != none && (WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer))
	{
		BuildingInternals.Init(self,bBuildingDebug);
	}

	

	
	/**
	else
	{
		`log("CRITICAL ERROR: Building Internals ("$BuildingInternalsClass.default.Class$") did not spawn for"@self.Class$".",,'Buildings');
	}
	*/
	if(Role == ROLE_Authority)
		GetAttackPoints();
	
}

simulated function TickBuilding(float DeltaTime)
{
	
}

simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
)
{
	if(BuildingInternals.GetHealth() <= 0) {
		return;
	}
	super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(BuildingInternals.GetHealth() <= 0) 
	{
		if(myObjective != None && !myObjective.IsDisabled()) 
		{
			myObjective.DisableBuildingObjective();
		}
		return;
	}
	BuildingInternals.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(myObjective != None) 
	{
		myObjective.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);    
	}
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if(BuildingInternals.HealDamage(Amount,Healer,DamageType) && myObjective != none ) {
		myObjective.HealDamage(Amount,Healer,DamageType);
		return true;
	}
	return false;
}

simulated function bool IsEffectedByEMP()
{
	return true;
}

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	if (Rx_Building_Team_Internals(BuildingInternals) != None && GetTeamNum() != InstigatedByController.GetTeamNum() && BuildingInternals.GetHealth() > 0)
	{
		Rx_Building_Team_Internals(BuildingInternals).TriggerBuildingUnderAttackMessage(InstigatedByController);
		return true;
	}
	return false;
}

function EnteredEMPField(Rx_EMPField EMPField);

function LeftEMPField(Rx_EMPField EMPField);

simulated function bool StopsProjectile(Projectile P)
{
	return true;
}

simulated function byte ScriptGetTeamNum() 
{
	return TeamID; 
}

simulated function byte GetTeamNum() 
{
	return TeamID; 
}

simulated function int GetHealth() 
{
	if(BuildingInternals != None)
		return BuildingInternals.GetHealth(); 
	else 
		return Health;		
}

simulated function int GetMaxHealth() 
{
	if(BuildingInternals != None)
		return BuildingInternals.GetMaxHealth(); 
	else 
		return HealthMax;	
}

simulated function int GetTrueMaxHealth() 
{
	if(BuildingInternals != None)
		return BuildingInternals.GetTrueMaxHealth(); 
	else 
		return HealthMax;	
}


simulated function int GetArmor() 
{
	if(BuildingInternals != None)
		return BuildingInternals.GetArmor(); 
	else 
		return 0;		
}

simulated function int GetMaxArmor() 
{
	if(BuildingInternals != None)
		return BuildingInternals.GetMaxArmor(); 
	else 
		return 0;	
}


simulated function string GetBuildingName()
{	
	if(BuildingInternals != None)
		return BuildingInternals.GetBuildingName();
	else 
		return GetBuildingName(); 
			
}

simulated function bool IsDestroyed()
{
	if (BuildingInternals != none)
		return BuildingInternals.IsDestroyed();
	else return false;
}

simulated function String GetSpotName()
{
	return GetHumanReadableName();
}

/*
simulated function vector GetTargetLocation(optional actor RequestedBy, optional bool bRequestAlternateLoc) 
{
	return super.GetTargetLocation(RequestedBy,bRequestAlternateLoc) + vect(0,0,200);
}
*/

function RemoveMyMines(Rx_Controller Control)
{
	local Rx_Weapon_DeployedProxyC4 Proxies; 
	local byte TeamByte;
	
	TeamByte = Control.GetTeamNum();
	
	foreach AllActors(class'Rx_Weapon_DeployedProxyC4', Proxies)
	{
		if(Proxies.Base == self && Proxies.GetTeamNum() == TeamByte ) Proxies.TakeDamage(500, Control, vect(0,0,0), vect(0,0,0), class'Rx_DmgType_EMP') ; 
	}
}

function GetAttackPoints()
{
	local NavigationPoint N;
	local Vector Dummy1,Dummy2;

	foreach WorldInfo.AllNavigationPoints(class'NavigationPoint',N)
	{
		if(N.Trace(Dummy1,Dummy2,Location,N.Location,,,,TRACEFLAG_Bullet) != Self)
			Continue;

		ViableAttackPoints.AddItem(N);

	}

	if(ViableAttackPoints.length <= 0)
		`log(GetHumanReadableName()@" : Failed to find viable attack points! Bots may find issues in pathfinding to this building!");
}

function NavigationPoint FindAttackPointsFor(UTBot B)
{
	local float Dist, BestDist;
	local Vector DistanceMark;
	local NavigationPoint N, BestN;
	local bool bBotIsTransport;

	if(ViableAttackPoints.length <= 0)
	{
		`log(GetHumanReadableName()@" : This building lacks any attack point!");
		return none;
	}

	if(Vehicle(B.Pawn) != None && (Rx_Vehicle_Weapon(B.Pawn.Weapon) == None || !Rx_Vehicle_Weapon(B.Pawn.Weapon).bOkAgainstBuildings))
	{
		bBotIsTransport = true;
		DistanceMark = Location;
	}
	else
	{
		DistanceMark = B.Pawn.Location;
	}

	foreach ViableAttackPoints(N)
	{
		if(Vehicle(B.Pawn) != None && N.bBlockedForVehicles)
			continue;
		Dist = VSizeSq(N.Location - DistanceMark);

		if(!bBotIsTransport && VSizeSq(N.Location - Location) > Square(B.Pawn.Weapon.GetTraceRange()))		// can't possibly attack from here if the spot is unreachable
			continue;

		if(BestN == None || BestDist > Dist)
		{
			BestN = N;
			BestDist = Dist;
		}
	}

	if(BestN != None)
	{
		return BestN;
	}

	else
	{
		`log(B.GetHumanReadableName()@" : Failed to get my attack spot, have you setup the map's navigation points correctly?");
		return none;
	}
}

simulated function Rx_BuildingObjective GetObjective()
{
	return myObjective;
}

function OnToggle(SeqAct_Toggle Action)
{
	local Rx_Building_Team_Internals TeamInternals;
	local bool bNewPowerStatus;

	if(Rx_Building_Team_Internals(BuildingInternals) != None && !IsDestroyed())
		TeamInternals = Rx_Building_Team_Internals(BuildingInternals);

	else
		return;

	if(Action.InputLinks[0].bHasImpulse)
		bNewPowerStatus = true;

	else if (Action.InputLinks[1].bHasImpulse)
		bNewPowerStatus = false;

	else
		bNewPowerStatus = TeamInternals.bNoPower;


	if(bNewPowerStatus)
		TeamInternals.PowerRestore();
	else
		TeamInternals.PowerLost(true);
	
}

function bool Unpowered()
{
	if(IsDestroyed())
		return true;
	if(Rx_Building_Team_Internals(BuildingInternals) != None)
		return Rx_Building_Team_Internals(BuildingInternals).bNoPower;
}

function CreateUnlistedBO()
{
	local vector SpawnLoc;

	if(GetMCT() != None)
		SpawnLoc = GetMCT().Location;

	else
		SpawnLoc = Location;

	myObjective = Spawn(class'Rx_BuildingObjective_Dynamic',self,,SpawnLoc,Rotation);

	myObjective.DefenderTeamIndex = ScriptGetTeamNum();
	myObjective.DamageCapacity = GetMaxArmor();	
	myObjective.myBuilding = Self;

	Rx_BuildingObjective_Dynamic(myObjective).GenerateInfiltrationPoint();
}

function bool ShouldCreateUnlistedBO()
{
	return myObjective == None;
}

defaultproperties
{
	/***************************************************/
	/*              Actor Settings                     */
	/***************************************************/
	RemoteRole            = ROLE_SimulatedProxy
	bBlocksNavigation   = false
	bBlocksTeleport     = True
	BlockRigidBody      = True
	bCollideActors      = True
	bBlockActors        = True
	bStatic             = true
	bWorldGeometry      = True
	bMovable            = False
	bAlwaysRelevant     = True
	bGameRelevant       = True
	bOnlyDirtyReplication = True
	
	NetUpdateFrequency=10.0


	HealthMax           = 4000
	Health              = 0
	bBuildingDebug      = False
	bSignificant		= true

	/***************************************************/
	/*             Buildings Static Meshes             */
	/***************************************************/
	Begin Object Class=StaticMeshComponent Name=Static_Interior
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		//HiddenGame=true
		ForcedLodModel 					= 1
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
	End Object
	StaticMeshPieces.Add( Static_Interior )
	Components.Add( Static_Interior )
	StaticInterior=Static_Interior

	Begin Object Class=StaticMeshComponent Name=Static_Interior_Complex
		//HiddenGame=true
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		ForcedLodModel 					= 1
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
	End Object
	StaticMeshPieces.Add( Static_Interior_Complex )
	Components.Add( Static_Interior_Complex )
	StaticInteriorComplex=Static_Interior_Complex

	Begin Object Class=StaticMeshComponent Name=Static_Exterior
		//HiddenGame=true
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		ForcedLodModel 					= 1
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
	End Object
	StaticMeshPieces.Add( Static_Exterior )
	Components.Add( Static_Exterior )
	StaticExterior=Static_Exterior

	Begin Object Class=StaticMeshComponent Name=PT_Screens
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		ForcedLodModel 					= 1
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
	End Object
	StaticMeshPieces.Add( PT_Screens )
	Components.Add( PT_Screens )
	PTScreens=PT_Screens


	/***************************************************/
	/*             For Debugging Purposes              */
	/***************************************************/
	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius0
		SphereColor = (R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius0)

	// Inner cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawInnerCone0
		ConeColor=(R=150,G=200,B=255)
	End Object
	Components.Add(DrawInnerCone0)

	// Outer cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawOuterCone0
		ConeColor=(R=200,G=255,B=255)
	End Object
	Components.Add(DrawOuterCone0)


	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Class=PointLightComponent Name=PointLightComponent1
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent2
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent3
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent4
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent5
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent6
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent7
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent8
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent9
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent10
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent11
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object
	
	Begin Object Class=PointLightComponent Name=PointLightComponent12
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent13
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	Begin Object Class=PointLightComponent Name=PointLightComponent14
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		PreviewLightRadius          = DrawLightRadius0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
		Radius                      = 350.000000
		FalloffExponent             = 4.000000
		Brightness                  = 3.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightColor                  = (B=255,G=255,R=255,A=0)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
	End Object

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Class=SpotLightComponent Name=SpotLightComponent1
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		InnerConeAngle              = 80.000000
		OuterConeAngle              = 90.000000
		Radius                      = 300.000000
		FalloffExponent             = 4.000000
		Brightness                  = 2.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
		PreviewLightRadius          = DrawLightRadius0
		PreviewInnerCone            = DrawInnerCone0
		PreviewOuterCone            = DrawOuterCone0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
	End Object

  Begin Object Class=SpotLightComponent Name=SpotLightComponent2
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		InnerConeAngle              = 80.000000
		OuterConeAngle              = 90.000000
		Radius                      = 300.000000
		FalloffExponent             = 4.000000
		Brightness                  = 2.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
		PreviewLightRadius          = DrawLightRadius0
		PreviewInnerCone            = DrawInnerCone0
		PreviewOuterCone            = DrawOuterCone0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
	End Object

	Begin Object Class=SpotLightComponent Name=SpotLightComponent3
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		InnerConeAngle              = 80.000000
		OuterConeAngle              = 90.000000
		Radius                      = 300.000000
		FalloffExponent             = 4.000000
		Brightness                  = 2.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
		PreviewLightRadius          = DrawLightRadius0
		PreviewInnerCone            = DrawInnerCone0
		PreviewOuterCone            = DrawOuterCone0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
	End Object
	
	Begin Object Class=SpotLightComponent Name=SpotLightComponent4
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		InnerConeAngle              = 80.000000
		OuterConeAngle              = 90.000000
		Radius                      = 300.000000
		FalloffExponent             = 4.000000
		Brightness                  = 2.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
		PreviewLightRadius          = DrawLightRadius0
		PreviewInnerCone            = DrawInnerCone0
		PreviewOuterCone            = DrawOuterCone0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
	End Object

	Begin Object Class=SpotLightComponent Name=SpotLightComponent5
		LightAffectsClassification  = LAC_STATIC_AFFECTING
		CastShadows                 = True
		CastStaticShadows           = True
		CastDynamicShadows          = False
		bForceDynamicLight          = False
		InnerConeAngle              = 80.000000
		OuterConeAngle              = 90.000000
		Radius                      = 300.000000
		FalloffExponent             = 4.000000
		Brightness                  = 2.000000
		LightingChannels            = (BSP=True,Static=True,Dynamic=False,CompositeDynamic=True,bInitialized=True)
		LightmassSettings           = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=32)
		PreviewLightRadius          = DrawLightRadius0
		PreviewInnerCone            = DrawInnerCone0
		PreviewOuterCone            = DrawOuterCone0
		PreviewLightSourceRadius    = DrawLightSourceRadius0
	End Object

	SupportedEvents.Add(class'Rx_SeqEvent_BuildingEvent')

	IconTexture=Texture2D'RenxHud.T_BuildingIcon_RepairPad_Normal'

}