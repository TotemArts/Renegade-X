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

var TEAM                                        TeamID;                 // building belongs to team with this TeamID (normally 0 -> GDI, 1-> Nod)
var(RenX_Buildings) int                         Health;                 // Starting Health for the building
var(RenX_Buildings) int                         HealthMax;                // Max Health for the building
var(RenX_Buildings) bool                        bBuildingDebug;         // Set to true to enable Debug Logging

var class<Rx_Building_Internals>          BuildingInternalsClass; // Class of the internals that needs spawned
var repnotify Rx_Building_Internals             BuildingInternals;      // Instance of the internals that handles the logic like TakeDamage and the like

var(BuildingLights) array<PointLightComponent>  PointLightComponents;   // Point lights for the pre setup lighting
var(BuildingLights) array<SpotLightComponent>   SpotLightComponents;    // Spot lights for the PT's and MCT's for pre setup lighting
var array<StaticMeshComponent>                  StaticMeshPieces;
var Rx_BuildingObjective						myObjective;

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
	

function PostBeginPlay()
{

	BuildingInternals = spawn(BuildingInternalsClass,self,BuildingInternalsClass.Name,Location,Rotation);

	
	if ( BuildingInternals != none && (WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_DedicatedServer))
	{
		BuildingInternals.Init(self,bBuildingDebug);
	} 
	
	/**
	else
	{
		`log("CRITICAL ERROR: Building Internals ("$BuildingInternalsClass.default.Class$") did not spawn for"@self.Class$".",,'Buildings');
	}
	*/
	
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

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor)
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

simulated function vector GetTargetLocation(optional actor RequestedBy, optional bool bRequestAlternateLoc) 
{
	return super.GetTargetLocation(RequestedBy,bRequestAlternateLoc) + 200 * vect(0,0,1);
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

}