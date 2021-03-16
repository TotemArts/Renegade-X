class Rx_Projectile_Spray extends Rx_Projectile; 

/*Class to get around native code spamming traces for volumetric projectiles and providing no, to my knowledge, method of avoiding HitWall() stopping projectiles.*/
var vector SprayRadii, MinSprayRadii, MaxSprayRadii; //Radius of the spray object
var vector SprayRadiiIncrement; //Calculated on Init. How much do we increment per damage check for size of colission increase
var bool bDidFinalTrace; 
var float CheckInterval; 

function Init(vector Direction)
{
	super.Init(Direction); 
	//if(Instigator != none && WorldInfo.NetMode != NM_DedicatedServer)
		if(ROLE == ROLE_Authority && WorldInfo.NetMode != NM_DedicatedServer)
		{
			InitializeSpray();	
			SetTimer(CheckInterval, true, 'DamageActors');
		}
			
}

simulated function InitializeSpray()
{
	//Set our initial Spray Radii 
	SprayRadii = MinSprayRadii;
	
	//Somehow this always ends up wrong... would probably just set it in subclasses manually, or note me with working math 
	SprayRadiiIncrement.X = (MaxSprayRadii.X - MinSprayRadii.X)/(LifeSpan/CheckInterval);
	SprayRadiiIncrement.Y = (MaxSprayRadii.Y - MinSprayRadii.Y)/(LifeSpan/CheckInterval);
	SprayRadiiIncrement.Z = (MaxSprayRadii.Z - MinSprayRadii.Z)/(LifeSpan/CheckInterval);
} 

simulated function UpdateSprayRadiiSize()
{
	SprayRadii.X += SprayRadiiIncrement.X;
	SprayRadii.Y += SprayRadiiIncrement.Y;
	SprayRadii.Z += SprayRadiiIncrement.Z;
}

simulated function DamageActors()
{
	local Pawn Damageable; 
	local vector HLoc;
	local vector Norm; 
	local vector AdjustedLocation; 
	
	UpdateSprayRadiiSize();
	
	AdjustedLocation = location + SprayRadii;
	
	foreach TraceActors(class'Pawn', Damageable, HLoc, Norm, AdjustedLocation + vector(rotation) * (speed/LifeSpan*-1.0), AdjustedLocation, (SprayRadii+SprayRadii)) 
	{
		if(Damageable == Instigator || Damageable.GetTeamNum() == GetTeamNum())
			return; 
		ProcessTouch(Damageable, location, Normal(Location - Damageable.Location));
	}

	if(CurrentPiercingPower <= 0 && !bDidFinalTrace) 
	{
		bDidFinalTrace = true;
		SpawnExplosionEffects(location, location);
		ShutDown(); 
	}
}
	
simulated function Shutdown()
{
	
	if(ROLE == ROLE_Authority && WorldInfo.NetMode != NM_DedicatedServer)
	{
		ClearTimer('DamageActors');
		if(!bDidFinalTrace)
		{
			bDidFinalTrace = true;
			DamageActors(); 	
		}
	}
	super.Shutdown();
}	

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local float VAdjustedDamage; //Adjusted for veterancy
	local Rx_DestroyableObstaclePlus DObj;
	
	
	//Don't double dip on pierced actor
	if(PiercedActors.Find(Other) > -1)
	{
		return;
	}	
		
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
	{
		PiercedActors.AddItem(Other); 
		CurrentPiercingPower = 0; 
	}
			//SpawnExplosionEffects(HitLocation, HitNormal);
			if(WorldInfo.NetMode != NM_DedicatedServer
						&& (Rx_Weapon(MyWeaponInstigator) != None || Rx_Vehicle_Weapon(MyWeaponInstigator) != None)
						&& !isAirstrikeProjectile()) {
				if(Pawn(Other) != None && Pawn(Other).Health > 0 && UTPlayerController(Instigator.Controller) != None && Pawn(Other).GetTeamNum() != Instigator.GetTeamNum()) {
					Rx_Hud(UTPlayerController(Instigator.Controller).myHud).ShowHitMarker();
					if(Rx_Pawn(Other) != None) 
						Rx_Controller(Instigator.Controller).AddHit() ;
				}
				if(FracturedStaticMeshActor(Other) != None || DObj != None)
					Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
				
				if(DObj !=none)
					Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
				
				CallServerALHit(Other,HitLocation,HitInfo,false);
			} else if(ROLE == ROLE_Authority && (AIController(InstigatorController) != None || isAirstrikeProjectile())) {
				Other.TakeDamage(VAdjustedDamage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			}
			
		if(Rx_BuildingAttachment(Other) != None) //Building attachments like doors should stop this
		{
			SpawnExplosionEffects(HitLocation, HitNormal);
			Shutdown();
		}
			
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
	{
		PiercedActors.AddItem(Wall); 
		CurrentPiercingPower = 0; 
	}
		
	
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
				
	if (!Wall.bStatic )
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
			
			if(Rx_Building(Wall) != none)
			{
				//Staaahhhhp! Those are walls!
				Shutdown();
			}
		} 
		else if(ROLE == ROLE_Authority && (AIController(InstigatorController) != None || isAirstrikeProjectile())) 
		{
			Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		}
	}
	else
	{	
		if(WorldInfo.NetMode != NM_DedicatedServer && Rx_Building(Wall) != none && Instigator != none && (Rx_Weapon(MyWeaponInstigator) != None || Rx_Vehicle_Weapon(MyWeaponInstigator) != None))
		{
			if(Rx_Building(Wall).GetTeamNum() != GetTeamNum())
				CallServerALHit(Wall,location,WallHitInfo,mctDamage);
			Shutdown();
		}
		
		SpawnExplosionEffects(location, HitNormal);
		Shutdown();
	}
}

DefaultProperties
{
	DamageRadius = 0 //Needs no damage radius. Use SprayRadii vector to have more control of the shape 
	MaxSprayRadii = (X=0.0,Y=0.0,Z=0.0) //You're THIS big in the end 
	MinSprayRadii =  (X=0.0,Y=0.0,Z=0.0) //You're this big to start with 
	SprayRadii = (X=0.0,Y=0.0,Z=0.0)
	
	CheckInterval = 0.10
	
	bPierceInfantry = true
	//Must COLLIDE actors if it can't pierce vehicles.. otherwise it'll go through them anyway
	bCollideActors = true 
	bPierceVehicles = false
	
	MaximumPiercingAbility	= 32 //Higher usually just makes sense unless it's going through vehicles. 
	CurrentPiercingPower	= 32
	
	bCollideWorld = true ;
}