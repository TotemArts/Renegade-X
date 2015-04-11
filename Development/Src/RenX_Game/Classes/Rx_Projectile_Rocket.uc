class Rx_Projectile_Rocket extends UTProj_SeekingRocket
	abstract;
	
var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

//percentage of weapon damage done by bots
var float BotDamagePercentage;

var array<MaterialImpactEffect> ImpactEffects;
var repnotify vector Target;
var bool bDontLockAnymore;
var bool bWaitForEffectsAtEndOfLifetime;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(bWaitForEffectsAtEndOfLifetime) {
		SetTimer(LifeSpan,false,'ShutDownBeforeEndOfLife');
		LifeSpan += 0.5;
	}
}

replication
{
	if ( bNetInitial && Role == ROLE_Authority )
		Target;
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'Target')
	{
      	ClientAdjustState();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function ShutDownBeforeEndOfLife() 
{
	Shutdown();
}

simulated function ClientAdjustState()
{
   GotoState('Homing');
}

simulated state Homing
{
	simulated function Timer()
	{
		local vector TargetLocation;
		local bool bDontLock;
		
		if(bDontLockAnymore) {
			return;
		}
		
		if(SeekTarget != none) {
			TargetLocation = SeekTarget.GetTargetLocation();
		} else {
			TargetLocation = Target;		
		}	
		
		if(class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,Rotation,TargetLocation) > 0.0) { // else we already are past the target
			bDontLock = true;	
		}
		if(GetTimerCount('ShutDownBeforeEndOfLife',self) < 2.0)
			bDontLock = false;	
		
		if(!bDontLock) {
			if(RxIfc_SeekableTarget(SeekTarget) != none && VSize(SeekTarget.Velocity) > 150 && RxIfc_SeekableTarget(SeekTarget).GetAimAheadModifier() > 0.0) { 
				TargetLocation = TargetLocation + Normal(SeekTarget.Velocity) * RxIfc_SeekableTarget(SeekTarget).GetAimAheadModifier();
			}
			if(RxIfc_SeekableTarget(SeekTarget) != none && RxIfc_SeekableTarget(SeekTarget).GetAccelrateModifier() > 0.0) { 
				AccelRate = default.AccelRate * RxIfc_SeekableTarget(SeekTarget).GetAccelrateModifier();
			}
			Acceleration = 16.0 * AccelRate * Normal(TargetLocation - Location);
		} else {
			bDontLockAnymore = true;
		}		
	}

	simulated function BeginState(name PreviousStateName)
	{
		InitialState = 'Homing';
		Timer();
		SetTimer(0.1, true);
	}
}

simulated event CreateProjectileLight()
{
	if ( WorldInfo.bDropDetail )
		return;

	if(ProjectileLightClass != None) {
		ProjectileLight = new(self) ProjectileLightClass;
		AttachComponent(ProjectileLight);
	}
}

simulated function float GetBotDamagePercentage()
{
    return BotDamagePercentage;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if(DamageRadius == 0.0 && Rx_BuildingAttachment_MCT(Other) != None) {
		// Some projectiles are so fast that they go through the MCT and hit the building behind it.
		// This prevents the building from taking additional damage via HitWall()
		//Destroy();
		bWaitForEffects=false;
		Explode(HitLocation,HitNormal);
	}
    super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function bool HurtRadius( float DamageAmount,
								    float InDamageRadius,
				    				class<DamageType> DamageType,
									float Momentum,
									vector HurtOrigin,
									optional actor IgnoredActor,
									optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
									optional bool bDoFullDamage
									)
{
	local bool bCausedDamage, bResult;

	if ( bHurtEntry )
		return false;

	bCausedDamage = false;
	if (InstigatedByController == None)
	{
		InstigatedByController = InstigatorController;
	}

	// if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
	if ( (ImpactedActor != None) && (ImpactedActor != self) && Rx_Building(ImpactedActor) == None)
	{
		if(!TryHeadshot(ImpactedActor, HurtOrigin, Velocity, Damage)) {
			ImpactedActor.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, true, self);
		}
		bCausedDamage = ImpactedActor.bProjTarget;
	}

	bResult = Super(Actor).HurtRadius(DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, ImpactedActor, InstigatedByController, bDoFullDamage);
	return ( bResult || bCausedDamage );
}

simulated function bool TryHeadshot(Actor Other, Vector HitLocation, Vector HitNormal, float DamageAmount)
{
    local float Scaling;
    local ImpactInfo Impact;
    
    if(Worldinfo.NetMode == NM_Client) { // since Rockets dont use clientside hitdetection yet
    	return false;
    }
    if (Instigator == None || VSize(Instigator.Velocity) < Instigator.GroundSpeed * Instigator.CrouchedPct)
    {
        Scaling = SlowHeadshotScale;
    }
    else
    {
        Scaling = RunningHeadshotScale;
    }

    DamageAmount *= HeadShotDamageMult;
    
    Impact.HitActor = Other;
    Impact.HitLocation = HitLocation;
    Impact.HitNormal = HitNormal;
    Impact.RayDir = vector(Rotation); 
    
    if( Rx_Pawn(Other) != None )
    {
        UTPawn(Other).Mesh.ForceSkelUpdate();
        CheckHitInfo(Impact.HitInfo, UTPawn(Other).Mesh, Impact.RayDir, Impact.HitLocation);
        
        if(HeadShotDamageType != None) {
        	return Rx_Pawn(Other).TakeHeadShot(Impact, HeadShotDamageType, DamageAmount, Scaling, InstigatorController, true);
        } else {
        	return Rx_Pawn(Other).TakeHeadShot(Impact, MyDamageType, DamageAmount, Scaling, InstigatorController, true);
        }
    }
    
    return False;
}

simulated singular event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	TriggerEventClass(class'SeqEvent_HitWall', Wall);

	if ( Wall.bWorldGeometry )
	{
		HitStaticMesh = StaticMeshComponent(WallComp);
		if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
		{
	        NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
	        if ( NewKActor != None )
			{
				Wall = NewKActor;
			}
		}
	}
	ImpactedActor = Wall;
	if ( ( !Wall.bStatic && (DamageRadius == 0) ) || ClassIsChildOf(Wall.Class,class'Rx_Building') )
	{
		Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
	}

	Explode(Location, HitNormal);
	ImpactedActor = None;
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector NewHitLoc;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;	
		
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(ImpactedActor != None && ImpactedActor.isA('Rx_Vehicle')){
			ProjExplosionTemplate = ImpactEffects[3].ParticleTemplate;
			ExplosionSound = ImpactEffects[3].Sound;
		} else if(ImpactedActor != None && ImpactedActor.isA('Rx_Pawn')){
			ProjExplosionTemplate = ImpactEffects[8].ParticleTemplate;
			ExplosionSound = ImpactEffects[8].Sound;
		} else {
			Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), true,, HitInfo, TRACEFLAG_Bullet);
			ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);
			ProjExplosionTemplate = ImpactEffect.ParticleTemplate;
			ExplosionSound = ImpactEffect.Sound;
		}
	}
	super.SpawnExplosionEffects(HitLocation,HitNormal);
}

simulated function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial)
{
	local int i;
	local UTPhysicalMaterialProperty PhysicalProperty;

	if (HitMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
	}
	if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
	{
		i = ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
		if (i != -1)
		{
			return ImpactEffects[i];
		}
	}		
	return ImpactEffects[1];
}

DefaultProperties
{
	HeadShotDamageMult=2.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5
	
	ExplosionDecal=none
    bWaitForEffectsAtEndOfLifetime = true
}