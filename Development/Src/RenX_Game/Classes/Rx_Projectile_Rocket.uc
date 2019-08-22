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

//Veterancy options 
var byte VRank; //Veterancy Rank
var float Vet_SpeedIncrease[4]; 
var float Vet_DamageIncrease[4]; 

//Weapon who fired me
var Weapon MyWeaponInstigator;  

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
		
    if (Role == ROLE_Authority && bNetDirty)
        VRank;

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

/**
 * Initialize the Projectile [RX] Add modifiers for veterancy
 */
function Init(vector Direction)
{
	local Rx_Weapon Rx_Inst; 
	local Rx_Vehicle_Weapon Rx_VInst;
	
	Rx_Inst=Rx_Weapon(Instigator.Weapon);
	
	Rx_VInst=Rx_Vehicle_Weapon(Instigator.Weapon) ;
	
	if(Rx_Inst != none) 
		VRank=Rx_Inst.VRank; 
	else
	if(Rx_VInst != none) 
		VRank=Rx_VInst.VRank; 
	
	SetRotation(rotator(Direction));
	
	MaxSpeed = default.MaxSpeed*Vet_SpeedIncrease[VRank] ; 
	Velocity = (Speed*Vet_SpeedIncrease[VRank]) * Direction;
	
	Velocity.Z += TossZ;
	
	Acceleration = AccelRate * Normal(Velocity);
}

simulated function ShutDownBeforeEndOfLife() 
{
	
	if ( !bShuttingDown )
		{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, location,,,false); 
		}
	
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
			if(RxIfc_SeekableTarget(SeekTarget) != none && VSizeSq(SeekTarget.Velocity) > 22500 && RxIfc_SeekableTarget(SeekTarget).GetAimAheadModifier() > 0.0) { 
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
	local float VAdjustedDamage; //Adjusted for veterancy
	
	VAdjustedDamage=Damage*GetDamageModifier(VRank, InstigatorController);
	
	if(DamageRadius == 0.0 && Rx_BuildingAttachment_MCT(Other) != None) {
		// Some projectiles are so fast that they go through the MCT and hit the building behind it.
		// This prevents the building from taking additional damage via HitWall()
		//Destroy();
		bWaitForEffects=false;
		Explode(HitLocation,HitNormal);
	}
	
	if (DamageRadius > 0.0)
		{
			if(Rx_DestroyableObstaclePlus(Other) !=none && !Rx_DestroyableObstaclePlus(Other).bTakeRadiusDamage) // || (Rx_BasicPawn(Other) !=none && !Rx_BasicPawn(Other).bTakeRadiusDamage)) 
				Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);	
			Explode( HitLocation, HitNormal );
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

	//`log("Rocket hurt radius"); 
	
	DamageAmount*=GetDamageModifier(VRank, InstigatorController); 
	
	bCausedDamage = false;
	if (InstigatedByController == None)
	{
		InstigatedByController = InstigatorController;
	}

	// if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
	if ( (ImpactedActor != None) && (ImpactedActor != self) && Rx_Building(ImpactedActor) == None)
	{
		if(!TryHeadshot(ImpactedActor, HurtOrigin, Velocity, DamageAmount)) {
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
	
	//`log("Rocket rey "); 
	
    if (Instigator == None || VSizeSq(Instigator.Velocity) < Square(Instigator.GroundSpeed * Instigator.CrouchedPct))
    {
        Scaling = SlowHeadshotScale;
    }
    else
    {
        Scaling = RunningHeadshotScale;
    }

	DamageAmount*=GetDamageModifier(VRank, InstigatorController); 
	
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
        	return Rx_Pawn(Other).TakeHeadShot(Impact, HeadShotDamageType, DamageAmount, Scaling, InstigatorController, true, GetWeaponInstigator());
        } else {
        	return Rx_Pawn(Other).TakeHeadShot(Impact, MyDamageType, DamageAmount, Scaling, InstigatorController, true, GetWeaponInstigator());
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
		Wall.TakeDamage( Damage*GetDamageModifier(VRank, InstigatorController), InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
	}

	Explode(Location, HitNormal);
	ImpactedActor = None;
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector NewHitLoc;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;	
	
	local PlayerController PC;
	local float Distance;	
		
		
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			Distance = VSizeSq(PC.ViewTarget.Location - HitLocation);
			 
			// dont spawn explosion effect if far away and no direct line of sight or if behind and relativly far away   
			if ( ( PC.ViewTarget != None && Distance > 81000000 && !FastTrace(PC.ViewTarget.Location, HitLocation) ) 
			 		|| ( vector(PC.Rotation) dot (HitLocation - PC.ViewTarget.Location) < 0.0 && Distance > 25000000 && !FastTrace(PC.ViewTarget.Location, HitLocation)) )
			{
				
				if (ExplosionSound != None && !bSuppressSounds)
				{
					PlaySound(ExplosionSound, true);
				}
		
				bSuppressExplosionFX = true; // so we don't get called again				
				return;
			}
		}	
		
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

simulated function SetWeaponInstigator(Weapon SetTo)
{
	MyWeaponInstigator = SetTo; 
}

simulated function Weapon GetWeaponInstigator()
{
	return MyWeaponInstigator; 
}

DefaultProperties
{
	HeadShotDamageMult=2.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5
	
	ExplosionDecal=none
    bWaitForEffectsAtEndOfLifetime = true
	
	/*************************/
	/*VETERANCY*/
	/************************/
	
	//Rocket damage is usually built up with extra rockets 
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1 //Veteran 
	Vet_DamageIncrease(2)=1 //Elite
	Vet_DamageIncrease(3)=1 //Heroic

	//Rockets are generally better off not moving faster... as it screws up their lock abilities. 
	
	Vet_SpeedIncrease(0)=1 //Normal (should be 1) 
	Vet_SpeedIncrease(1)=1 //Veteran 
	Vet_SpeedIncrease(2)=1 //Elite
	Vet_SpeedIncrease(3)=1 //Heroic 
	
	/***********************/
}