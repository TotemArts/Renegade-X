class Rx_Projectile extends UTProjectile
    abstract;
    
var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

/** Scale Multiplier for explosion particle */
var() float ProjExplosionScale;

//percentage of weapon damage done by bots
var float BotDamagePercentage;
var bool bWaitForEffectsAtEndOfLifetime;
var bool bDidHitMaterial;
var TraceHitInfo HitInfo;
var bool bDoWaitingForVelocityAndInstigatorTimer;

var array<MaterialImpactEffect> ImpactEffects;
var ParticleSystem				AirburstExplosionTemplate; 
//var Color						ExplosionSmokeColour; 
var vector						ExplosionSmokeColour;

// If non-zero, the hurt origin for the projectile is translated by this value on the Z-axis, on top of the existing normal translation.
var float AddedZTranslate;

var bool bLogExplosion;

//Veterancy options 
var byte VRank; //Veterancy Rank
var float Vet_SpeedIncrease[4]; 
var float Vet_DamageIncrease[4]; 
var float Vet_LifespanModifier[4] ; //*X  Used to keep projectile ranges from getting totally out of hand. 

var byte FMTag; //Identify what firemode you belong to for when ServerALHit is called 
var Weapon MyWeaponInstigator; 

//Pawn piercing 
var bool bPierceInfantry;
var bool bPierceVehicles; 
/**
* This controls how much piercing power the shot has. 
* Hitting infantry subtracts '1' from its piercing ability
* Where as vehicles subtract 3
* So if the Max pierce rating is 5, you could fire through 5 infantry before the 6th guy stopped it   
*/  
var int MaximumPiercingAbility;
var int	CurrentPiercingPower;  

var array<Actor> PiercedActors; //Don't double dip on actors you've pierced but touch again 

var class<DamageType>	ExplosionDamageType; //Used for the damage type for the explosion. If blank, just use normal damage type (The Usual case) 

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//We don't get our VRank immediately 
	//RxInitLifeSpan();
}


replication
{
    if (Role == ROLE_Authority && bNetDirty)
        VRank;
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

//Sets Lifespan for Rx_Projectiles with regard for their veterancy
simulated function RxInitLifeSpan()
{
	LifeSpan = default.LifeSpan*Vet_LifespanModifier[VRank] ; 
	
	if(bWaitForEffects && bWaitForEffectsAtEndOfLifetime) 
	{
		SetTimer(LifeSpan,false,'ShutDownBeforeEndOfLife');
		LifeSpan += 0.5;
	}
}

simulated function SetWeaponInstigator (Weapon SetTo)
{
	MyWeaponInstigator = SetTo; 
}

simulated function Weapon GetWeaponInstigator()
{
	return MyWeaponInstigator; 
}

/**
 * Initialize the Projectile [RX] Add modifiers for veterancy
 */
function Init(vector Direction)
{
	local Rx_Weapon Rx_Inst; 
	local Rx_Vehicle_Weapon Rx_VInst;
	
	Rx_Inst=Rx_Weapon(MyWeaponInstigator);
	Rx_VInst=Rx_Vehicle_Weapon(MyWeaponInstigator) ;
	
	if(Rx_Inst != none) VRank=Rx_Inst.VRank; 
	else
	if(Rx_VInst != none) VRank=Rx_VInst.VRank; 
	SetRotation(rotator(Direction));

	RxInitLifeSpan();
	
	Velocity = (Speed*Vet_SpeedIncrease[VRank]) * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
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
			/**if(Instigator.IsLocallyControlled() 
						&& Rx_Vehicle_Weapon(Instigator.Weapon) != None 
						&& Rx_Vehicle_Weapon(Instigator.Weapon).CanReplicationFire())
				UTWeapon(Instigator.Weapon).FireAmmunition(); */
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
	
	CurrentPiercingPower = 0; 
	
	if (WorldInfo.NetMode != NM_DedicatedServer && !bSuppressExplosionFX)
	{
		HitNormal = normal(Velocity * -1);
		Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	}

	SetPhysics(PHYS_None);

	if(AmbientSound != none)
		CleanupAmbientSound(); 
	
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
	//do appropriate damage
	if ( !bShuttingDown && DamageRadius > 0)
		{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, location,,,false); 
		}
		
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
	local float VAdjustedDamage; //Adjusted for veterancy
	local Rx_DestroyableObstaclePlus DObj;
		
	//Don't double dip on pierced actor
	if(PiercedActors.Find(Other) > -1)
		return;
	
	VAdjustedDamage=Damage*GetDamageModifier(VRank, InstigatorController); //*Vet_DamageIncrease[VRank];
	
	DObj = Rx_DestroyableObstaclePlus(Other); 
	
	if(bPierceInfantry && Rx_Pawn(Other) != none && CurrentPiercingPower > 0){
		CurrentPiercingPower-=1 ;
		PiercedActors.AddItem(Other);
	}	
	else if(bPierceVehicles && Rx_Vehicle(Other) != none && CurrentPiercingPower > 2){
		CurrentPiercingPower-=3 ;
		PiercedActors.AddItem(Other); 
	}
	else
		CurrentPiercingPower = 0; 
		
		
	
    if(CurrentPiercingPower == 0 && DamageRadius == 0.0 && TryHeadshot(Other, HitLocation, HitNormal, VAdjustedDamage)) {
        SpawnExplosionEffects(HitLocation, HitNormal);
        return;
    } else {
		if (DamageRadius > 0.0)
		{
			if(DObj !=none && !DObj.bTakeRadiusDamage) //|| (Rx_BasicPawn(Other) !=none && !Rx_BasicPawn(Other).bTakeRadiusDamage))  
				Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);	
			Explode( HitLocation, HitNormal );
		}
		else
		{
			SpawnExplosionEffects(HitLocation, HitNormal);
			if(WorldInfo.NetMode != NM_DedicatedServer
						&& (Rx_Weapon(MyWeaponInstigator) != None || Rx_Vehicle_Weapon(MyWeaponInstigator) != None)
						&& !isAirstrikeProjectile()) {
				if(Pawn(Other) != None && Pawn(Other).Health > 0 && UTPlayerController(Instigator.Controller) != None && Pawn(Other).GetTeamNum() != Instigator.GetTeamNum()) {
					Rx_Hud(UTPlayerController(Instigator.Controller).myHud).ShowHitMarker();
					if(Rx_Pawn(Other) != None) Rx_Controller(Instigator.Controller).AddHit() ;
				}
				if(FracturedStaticMeshActor(Other) != None || DObj != None)
					Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);	
				CallServerALHit(Other,HitLocation,HitInfo,false);
			} else if(ROLE == ROLE_Authority && (AIController(InstigatorController) != None || isAirstrikeProjectile())) {
				Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			}
			if(CurrentPiercingPower <= 0) Shutdown();
		}        
    }
}

/** Jacked Projectile::ProjectileHurtRadius to allow for custom HurtOrigin offset (for airstrikes).
 *  CLOSE COPY OF THIS FUNCTION IS USED IN RX_WEAPON AND RX_VEHICLE_WEAPON AS InstantFireHurtRadius - UPDATED ACCORDINGLY. */
simulated function bool ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;
	local float VAdjustedDamage; //veterancy adjusted damage
	
	//`log("PROJECTILE HURT RADIUS");
	
	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
	{
		return false;
	}
		

	VAdjustedDamage=Damage*GetDamageModifier(VRank, InstigatorController) ;//Vet_DamageIncrease[VRank];
	
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
	return HurtRadius(VAdjustedDamage, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin);
}

simulated function bool TryHeadshot(Actor Other, Vector HitLocation, Vector HitNormal, float DamageAmount)
{
    local float Scaling;
    local ImpactInfo Impact;
    
    if (Instigator == None || VSizeSq(Instigator.Velocity) < Square(Instigator.GroundSpeed * Instigator.CrouchedPct))
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
        	return Rx_Pawn(Other).TakeHeadShot(Impact, HeadShotDamageType, DamageAmount, Scaling, InstigatorController, false, GetWeaponInstigator());
        } else {
        	return Rx_Pawn(Other).TakeHeadShot(Impact, MyDamageType, DamageAmount, Scaling, InstigatorController, false, GetWeaponInstigator());
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
	local Pawn WallPawn; 
	
	if(PiercedActors.Find(Wall) > -1)
		return;
	
	WallPawn = Pawn(Wall);

	
	//We don't own the projectile, so don't be the one to determine its effects 
	if(ROLE < ROLE_Authority){
		if (DamageRadius > 0.0){
			Explode(Location, HitNormal);
		}
		else {
			SpawnExplosionEffects(Location, HitNormal);
			Shutdown();
		}
		
		return; 
	}
		//`log("Hit Wall, using instigator:" @ MyWeaponInstigator); 
		
	TriggerEventClass(class'SeqEvent_HitWall', Wall);

	if(bPierceInfantry && Rx_Pawn(Wall) != none && CurrentPiercingPower > 0){
		CurrentPiercingPower-=1 ;
		PiercedActors.AddItem(Wall);
	}	
	else if(bPierceVehicles && Rx_Vehicle(Wall) != none && CurrentPiercingPower > 2){
		CurrentPiercingPower-=3 ;
		PiercedActors.AddItem(Wall); 
	}
	else
		CurrentPiercingPower = 0; 
	
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
			&& ( Instigator != none && (Rx_Weapon(MyWeaponInstigator) != None || Rx_Vehicle_Weapon(MyWeaponInstigator) != None))
			&& !isAirstrikeProjectile()) 
		{
			if(WallPawn != None && WallPawn.Health > 0 && UTPlayerController(Instigator.Controller) != None && WallPawn.GetTeamNum() != Instigator.GetTeamNum()) 
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
	
	if(CurrentPiercingPower <= 0)
	{
		Explode(Location, HitNormal);
		ImpactedActor = None;
	}		
}

simulated function CallServerALHit(Actor Target, vector HitLocation, TraceHitInfo ProjHitInfo, bool mctDamage)
{
	
	if(Rx_Weapon(MyWeaponInstigator) != None) 
	{
		Rx_Weapon(MyWeaponInstigator).ServerALHit(Target,HitLocation,ProjHitInfo,mctDamage, FMTag);
	} 
	else 
	{
		//`log("ServerALHit:" @ MyWeaponInstigator);
		Rx_Vehicle_Weapon(MyWeaponInstigator).ServerALHit(Target,HitLocation,ProjHitInfo,mctDamage, FMTag);
	}
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector NewHitLoc;
	local MaterialImpactEffect ImpactEffect;
	local PlayerController PC;
	local float Distance;	
		 
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		
		if(!self.isA('Rx_Vehicle_A10_Bombs') && !self.isA('Rx_Vehicle_AC130_AutoCannon') && !self.isA('Rx_Vehicle_AC130_HeavyCannon'))
		{
			foreach LocalPlayerControllers(class'PlayerController', PC)
			{
				Distance = VSizeSq(PC.ViewTarget.Location - HitLocation);
				 
				// dont spawn explosion effect if far away and no direct line of sight or if behind and relatively far away 
				//EDIT: Yosh: Fairly certain the line-of-sight is already checked for! 
				if (ROLE < ROLE_Authority && ( PC.ViewTarget != None && Distance > 144000000))
				{
					if (ExplosionSound != None && !bSuppressSounds)
					{
						PlaySound(ExplosionSound, true);
					}

					bSuppressExplosionFX = true; // so we don't get called again				
					return;
				}
			}	
		}	
		
		if(ImpactedActor != None && ImpactedActor.isA('Rx_Vehicle')){
			ProjExplosionTemplate = ImpactEffects[3].ParticleTemplate;
			ExplosionSound = ImpactEffects[3].Sound;
			
		} else if(ImpactedActor != None && ImpactedActor.isA('Rx_Pawn')){
			ProjExplosionTemplate = ImpactEffects[8].ParticleTemplate;
			ExplosionSound = ImpactEffects[8].Sound;
			ExplosionSmokeColour = ImpactEffects[8].ImpactSmokeColour; 
		} else if(bShuttingDown && AirburstExplosionTemplate != none){
			ProjExplosionTemplate = AirburstExplosionTemplate;
			//ExplosionSound = ImpactEffects[8].Sound;
		}
		else {
			Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), true,, HitInfo, TRACEFLAG_Bullet);
			ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);
			ProjExplosionTemplate = ImpactEffect.ParticleTemplate;
			ExplosionSmokeColour = ImpactEffect.ImpactSmokeColour; 
			ExplosionSound = ImpactEffect.Sound;
		}
	}
	super.SpawnExplosionEffects(HitLocation,HitNormal);
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(ProjExplosionScale);
	
	ProjExplosion.SetVectorParameter('SurfaceImpactColour', ExplosionSmokeColour);
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
	local class<DamageType>	TrueDamageType; 
	
	if ( bHurtEntry )
		return false;

	bCausedDamage = false;
	if (InstigatedByController == None)
	{
		InstigatedByController = InstigatorController;
	}
	
		//`log("True:" @ TrueDamageType);
	
	// if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
	if ( (ImpactedActor != None) && (ImpactedActor != self) && Rx_Building(ImpactedActor) == None )
	{
		if(!TryHeadshot(ImpactedActor, HurtOrigin, Velocity, Damage)) {
			ImpactedActor.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, true, self);
		}
		bCausedDamage = ImpactedActor.bProjTarget;
	}

	//Do we have a specific damage type for the actual explosion?  
	if(ExplosionDamageType != none){
		TrueDamageType = ExplosionDamageType; 
	}
	else
		TrueDamageType = DamageType; 
		
	
	bResult = Super(Actor).HurtRadius(DamageAmount, InDamageRadius, TrueDamageType, Momentum, HurtOrigin, ImpactedActor, InstigatedByController, bDoFullDamage);
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
	CleanupAmbientSound();
	
	if (bLogExplosion && WorldInfo.NetMode != NM_Client)
		`LogRxPub("GAME"`s "ProjectileExploded;" `s self.Class `s "at" `s HitLocation `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	
	
	
	super.Explode(HitLocation, HitNormal);
}

simulated function CleanupAmbientSound()
{
	local AudioComponent AudioCues;
	
	if(AmbientSound != none){
		foreach ComponentList(class'AudioComponent',AudioCues){
			if(AudioCues.SoundCue == AmbientSound )
				AudioCues.Stop(); 
		}
	}
}

/** returns the maximum distance this projectile can travel */
simulated static function float GetRange()
{
	if (default.LifeSpan == 0.0)
	{
		return 15000.0;
	}
	else
	{
		return (default.MaxSpeed * default.LifeSpan );
	}
}

simulated static function float RxGetRange(optional byte rank)
{
	local float tempCachedRange; 
	
	tempCachedRange =  GetRange(); 
	
	tempCachedRange = tempCachedRange*default.Vet_SpeedIncrease[rank]*default.Vet_LifespanModifier[rank]; 
	
	return tempCachedRange; 
	
}

simulated static function float GetDamageModifier(byte Rank, Controller RxC)
{
	if(Rx_Controller(RxC) != none) 
		return default.Vet_DamageIncrease[Rank]+Rx_Controller(RxC).Misc_DamageBoostMod; 
	else
	if(Rx_Bot(RxC) != none) 
		return default.Vet_DamageIncrease[Rank]+Rx_Bot(RxC).Misc_DamageBoostMod; 
	else
		return 1.0; 
}

DefaultProperties
{    
    ImpactSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh'
	
    HeadShotDamageMult=5.0 
    SlowHeadshotScale=1.75
    RunningHeadshotScale=1.5

    ProjExplosionScale=1.0

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

	//Veterancy Base stats 

	VRank=0

	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.10 //Veteran 
	Vet_DamageIncrease(2)=1.25 //Elite
	Vet_DamageIncrease(3)=1.50 //Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1 //Veteran 
	Vet_SpeedIncrease(2)=1 //Elite
	Vet_SpeedIncrease(3)=1 //Heroic

	Vet_LifespanModifier(0)=1 //Normal (should be 1)
	Vet_LifespanModifier(1)=1 //Veteran 
	Vet_LifespanModifier(2)=1 //Elite
	Vet_LifespanModifier(3)=1 //Heroic
	
	//For instant hit weapons 
	bPierceInfantry = false
	bPierceVehicles = false
	MaximumPiercingAbility	= 0 
	CurrentPiercingPower	= 0 
}
