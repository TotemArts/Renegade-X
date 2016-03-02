class Rx_Projectile extends UTProjectile
    abstract;
    
var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

//percentage of weapon damage done by bots
var float BotDamagePercentage;
var bool bWaitForEffectsAtEndOfLifetime;
var bool bDidHitMaterial;
var TraceHitInfo HitInfo;
var bool bDoWaitingForVelocityAndInstigatorTimer;

var array<MaterialImpactEffect> ImpactEffects;

// If non-zero, the hurt origin for the projectile is translated by this value on the Z-axis, on top of the existing normal translation.
var float AddedZTranslate;

var bool bLogExplosion;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(bWaitForEffects && bWaitForEffectsAtEndOfLifetime) {
		SetTimer(LifeSpan,false,'ShutDownBeforeEndOfLife');
		LifeSpan += 0.5;
	}
}

simulated event SetInitialState()
{
	bScriptInitialized = true;
	if (Role < ROLE_Authority && !isAirstrikeProjectile())
	{
		bDoWaitingForVelocityAndInstigatorTimer = true;
		GotoState('WaitingForVelocityAndInstigator');
	}
	else
	{
		GotoState((InitialState != 'None') ? InitialState : 'Auto');
	}
}

state WaitingForVelocityAndInstigator
{
	simulated function Tick(float DeltaTime)
	{ 		
		if (bDoWaitingForVelocityAndInstigatorTimer && instigator != None 
				&& (AccelRate == 0.f || !IsZero(Velocity)))
		{
			if(AccelRate != 0.f) {
				Acceleration = AccelRate * Normal(Velocity);
			}
			if(Instigator.IsLocallyControlled() 
						&& Rx_Vehicle_Weapon(Instigator.Weapon) != None 
						&& Rx_Vehicle_Weapon(Instigator.Weapon).CanReplicationFire())
				UTWeapon(Instigator.Weapon).FireAmmunition(); 
			if (Instigator.IsHumanControlled() && Instigator.IsLocallyControlled()) {
				HideProjectile();
				SetCollision(false,false);
				ClearAllTimers();
				bSuppressExplosionFX = true;
				bWaitForEffects = false;
				bDoWaitingForVelocityAndInstigatorTimer = false;
				Shutdown();	
			} else {
				GotoState((InitialState != 'None') ? InitialState : 'Auto');
			}	
		}
	}
}

simulated function Shutdown()
{
	local vector HitLocation, HitNormal;

	bShuttingDown=true;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && !bSuppressExplosionFX)
	{
		HitNormal = normal(Velocity * -1);
		Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	}

	SetPhysics(PHYS_None);

	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && !bSuppressExplosionFX)
	{
		SpawnExplosionEffects(Location, HitNormal);
	}
	
	HideProjectile();
	SetCollision(false,false);

	// If we have to wait for effects, tweak the death conditions

	if (bWaitForEffects)
	{
		if (bNetTemporary)
		{
			if ( WorldInfo.NetMode == NM_DedicatedServer )
			{
				// We are on a dedicated server and not replicating anything nor do we have effects so destroy right away
				Destroy();
			}
			else
			{
				// We can't die right away but make sure we don't replicate to anyone
				RemoteRole = ROLE_None;
				// make sure we leave enough lifetime for the effect to play
				LifeSpan = FMax(LifeSpan, 2.0);
			}
		}
		else
		{
			bTearOff = true;
			if (WorldInfo.NetMode == NM_DedicatedServer)
			{
				LifeSpan = 0.15;
			}
			else
			{
				// make sure we leave enough lifetime for the effect to play
				LifeSpan = FMax(LifeSpan, 2.0);
			}
		}
	}
	else
	{
		Destroy();
	}
}

simulated function ShutDownBeforeEndOfLife() 
{
	Shutdown();
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
    if(DamageRadius == 0.0 && TryHeadshot(Other, HitLocation, HitNormal, Damage)) {
        SpawnExplosionEffects(HitLocation, HitNormal);
        return;
    } else {
		if (DamageRadius > 0.0)
		{
			Explode( HitLocation, HitNormal );
		}
		else
		{
			SpawnExplosionEffects(HitLocation, HitNormal);
			if(WorldInfo.NetMode != NM_DedicatedServer
						&& (Rx_Weapon(Instigator.Weapon) != None || Rx_Vehicle_Weapon(Instigator.Weapon) != None)
						&& !isAirstrikeProjectile()) {
				if(Pawn(Other) != None && Pawn(Other).Health > 0 && UTPlayerController(Instigator.Controller) != None && Pawn(Other).GetTeamNum() != Instigator.GetTeamNum()) {
					Rx_Hud(UTPlayerController(Instigator.Controller).myHud).ShowHitMarker();
				}
				if(FracturedStaticMeshActor(Other) != None)
					Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);	
				CallServerALHit(Other,HitLocation,HitInfo,false);
			} else if(ROLE == ROLE_Authority && (AIController(InstigatorController) != None || isAirstrikeProjectile())) {
				Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			}
			Shutdown();
		}        
    }
}

/** Jacked Projectile::ProjectileHurtRadius to allow for custom HurtOrigin offset (for airstrikes).
 *  CLOSE COPY OF THIS FUNCTION IS USED IN RX_WEAPON AND RX_VEHICLE_WEAPON AS InstantFireHurtRadius - UPDATED ACCORDINGLY. */
simulated function bool ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
		return false;

	AltOrigin = HurtOrigin;

	if ( (ImpactedActor != None) && ImpactedActor.bWorldGeometry )
	{
		// try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		AltOrigin.Z += AddedZTranslate;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if ( TraceHitActor == None )
		{
			// go half way if hit nothing
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
			AltOrigin.Z += AddedZTranslate;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}

	return HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin);
}

simulated function bool TryHeadshot(Actor Other, Vector HitLocation, Vector HitNormal, float DamageAmount)
{
    local float Scaling;
    local ImpactInfo Impact;
    
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
        	return Rx_Pawn(Other).TakeHeadShot(Impact, HeadShotDamageType, DamageAmount, Scaling, InstigatorController, false);
        } else {
        	return Rx_Pawn(Other).TakeHeadShot(Impact, MyDamageType, DamageAmount, Scaling, InstigatorController, false);
        }
    }
    
    return False;
}

simulated singular event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	local TraceHitInfo WallHitInfo;
	local bool mctDamage;

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
		if(WorldInfo.NetMode != NM_DedicatedServer 
			&& ( Instigator != none && (Rx_Weapon(Instigator.Weapon) != None || Rx_Vehicle_Weapon(Instigator.Weapon) != None))
			&& !isAirstrikeProjectile()) 
		{
			if(Pawn(Wall) != None && Pawn(Wall).Health > 0 && UTPlayerController(Instigator.Controller) != None && Pawn(Wall).GetTeamNum() != Instigator.GetTeamNum()) 
			{
				Rx_Hud(UTPlayerController(Instigator.Controller).myHud).ShowHitMarker();
			}	
			WallHitInfo.HitComponent = WallComp;

			if(Rx_BuildingAttachment_MCT(Wall) != None) 
			{
				Wall = Rx_BuildingAttachment_MCT(Wall).OwnerBuilding.BuildingVisuals;
					
				mctDamage = true;
	
			} 

			CallServerALHit(Wall,location,WallHitInfo,mctDamage);		
		} 
		else if(ROLE == ROLE_Authority && (AIController(InstigatorController) != None || isAirstrikeProjectile())) 
		{
			Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		}
	}

	Explode(Location, HitNormal);
	ImpactedActor = None;
}

simulated function CallServerALHit(Actor Target, vector HitLocation, TraceHitInfo ProjHitInfo, bool mctDamage)
{
	if(Rx_Weapon(Instigator.Weapon) != None) 
	{
		Rx_Weapon(Instigator.Weapon).ServerALHit(Target,HitLocation,ProjHitInfo,mctDamage);
	} 
	else 
	{
		Rx_Vehicle_Weapon(Instigator.Weapon).ServerALHit(Target,HitLocation,ProjHitInfo,mctDamage);
	}
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector NewHitLoc;
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
	if ( (ImpactedActor != None) && (ImpactedActor != self) && Rx_Building(ImpactedActor) == None )
	{
		if(!TryHeadshot(ImpactedActor, HurtOrigin, Velocity, Damage)) {
			ImpactedActor.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, true, self);
		}
		bCausedDamage = ImpactedActor.bProjTarget;
	}

	bResult = Super(Actor).HurtRadius(DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, ImpactedActor, InstigatedByController, bDoFullDamage);
	return ( bResult || bCausedDamage );
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

simulated function bool isAirstrikeProjectile()
{
	return false;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bLogExplosion && WorldInfo.NetMode != NM_Client)
		`LogRxPub("GAME"`s "ProjectileExploded;" `s self.Class `s "at" `s HitLocation `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	super.Explode(HitLocation, HitNormal);
}

DefaultProperties
{    
    ImpactSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh'
    HeadShotDamageMult=5.0 
    SlowHeadshotScale=1.75
    RunningHeadshotScale=1.5

/*    
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Dirt',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Stone',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Stone'),DecalWidth=8.0,DecalHeight=8.0)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Stone',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Concrete'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Metal',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Metal'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Glass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass',DecalMaterials=(DecalMaterial'RX_FX_Munitions.Bullet_Decals.MDecal_Bullet_Glass'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Wood',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Wood_01'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_TiberiumGround',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_TiberiumCrystal',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_TiberiumGround_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_TiberiumCrystal_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Mud',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_WhiteSand',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_YellowSand',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Grass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
*/
	
    BotDamagePercentage = 1.0;
    
    ExplosionDecal=none
    
    bWaitForEffects=false
    bWaitForEffectsAtEndOfLifetime=false
    bAttachExplosionToVehicles=False
    bCanBeDamaged=false
	bLogExplosion=false
    
//    bAttachExplosionToPawns=False    This needs to return

}
