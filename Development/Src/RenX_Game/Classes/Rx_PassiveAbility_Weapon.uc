/*Passive Ability variant that has limited support for projectiles [Base class. Extend from this]*/

class Rx_PassiveAbility_Weapon extends Rx_PassiveAbility; 

var class<UTProjectile> MyProjectileClass; 

/*Hold the current fire socket, and the name of all of our firing sockets*/
var int CurrentFireSocket;
var array<name> FireSocketNames;

var bool bIgnoreHitDist; 

var int	  AbilityRange;

simulated function ActivateAbility()
{
	super.ActivateAbility();
	ProjectileFire(); 
}

/*-------------------------------*/
/*Support for Firing projectiles*/
/*-------------------------------*/

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;
	local Rx_Weapon		UsingPawnWeapon;

	if(!UsesClientSideProjectiles()) {
		return ProjectileFireOld();
	}

	// this is the location where the projectile is spawned.
	RealStartLoc = GetPhysicalFireStartLoc();

	if(UsingPawn.Weapon != none) //Every class SHOULD always be carrying SOME weapon
		UsingPawnWeapon = Rx_Weapon(UsingPawn.Weapon);
	
	// Spawn projectile	
	SpawnedProjectile = Spawn(MyProjectileClass,,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		if(Rx_Projectile(SpawnedProjectile) != none) Rx_Projectile(SpawnedProjectile).SetWeaponInstigator(self);
		
		if(Rx_Bot(UsingPawn.Controller) != None) {
			SpawnedProjectile.Init( Vector(UsingPawnWeapon.GetAdjustedAim( RealStartLoc ) ) );
		} else {
			SpawnedProjectile.Init( Vector(UsingPawnWeapon.GetAdjustedWeaponAim( RealStartLoc )) );
		}	
	}
	// Return it up the line
	return SpawnedProjectile;
}

simulated function Projectile ProjectileFireOld()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;
	local Rx_Weapon		UsingPawnWeapon;

	// tell remote clients that we fired, to trigger effects

	if( ROLE == Role_Authority) {
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();
		
		if(UsingPawn.Weapon != none) //Every class SHOULD always be carrying SOME weapon
			UsingPawnWeapon = Rx_Weapon(UsingPawn.Weapon);
		
		// Spawn projectile	
		SpawnedProjectile = Spawn(MyProjectileClass,,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			if(Rx_Projectile_Rocket(SpawnedProjectile) != none)
				Rx_Projectile_Rocket(SpawnedProjectile).SetWeaponInstigator(self);
			
			SpawnedProjectile.Init( Vector(UsingPawnWeapon.GetAdjustedWeaponAim( RealStartLoc )) );
		}
		
		// Return it up the line
		return SpawnedProjectile;
	} else {
		//AddSpread(Instigator.GetBaseAimRotation());
		return none; 
	}
}

/*Support for clientside projectiles*/
//DmgReduction 
reliable server function ServerALHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage, optional byte FireTag, optional float DmgReduction = 1.0) 
{
	local class<Rx_Projectile>			MyRxProj;
	local class<DamageType> 	DamageType;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HitDistDiff;
	
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(UsingPawn.Controller) == None) {
		if(Rx_Controller(UsingPawn.Controller) == None) {
			return;
		} 
	}		
	
	MyRxProj = class<Rx_Projectile>(MyProjectileClass);
	loginternal(target);
	
	`log(UsingPawn @ Target @ MyRxProj);
	if (UsingPawn == none || Target == none || MyRxProj == none){
		return;  
	}
	
	HitDistDiff = VSizeSq(Target.Location - HitLocation);
	
	if (Target != none && !default.bIgnoreHitDist)
	{
		if(Rx_Building(Target) != None) {
			if(HitDistDiff > 9000000) {
				return;
			} 
		} else if(HitDistDiff > 250000 ) {
			return;
		}
	}
	
	if (UsingPawn.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - UsingPawn.Location)) )
	{
		return;
	}

	FireDir = Normal(Target.Location - UsingPawn.Location);

	Momentum = MyRxProj.default.MomentumTransfer * FireDir;
	DamageType = MyRxProj.default.MyDamageType;
	Damage = MyRxProj.default.Damage * MyRxProj.static.GetDamageModifier(VRank, UsingPawn.Controller);

	if(DmgReduction <= 1.0)
		Damage*=DmgReduction; //Used for effective range manipulation. Should never be higher than 1 
	
	if(mctDamage) {
		Damage = Damage * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor();
	}	
	
	Target.TakeDamage(Damage, UsingPawn.Controller, HitLocation, Momentum, DamageType, HitInfo, self);		
}

reliable server function ServerALHeadshotHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, optional float DmgReduction = 1.0)
{
	local class<DamageType> 	DamageType, TempDamageType, HeadShotDamageType; //TempDamageType Holds the REAL damage type for a weapon
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HeadShotDamageMultLocal, ArmorMultiplier, HeadShotDamageBurnMultiplier;
	local class<Rx_DmgType_Special> SpecialClass;

	ArmorMultiplier=1; //Used for infantry armour, so it will also apply to headshots
	
	//`log("ServerALHeadshot called");
	//`log("PType: " @ ProjectileClass); 
	
	UsingPawn = Rx_Pawn(Owner);
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(UsingPawn.Controller) == None) {
		if(UTPlayercontroller(UsingPawn.Controller) == None || Rx_Controller(UsingPawn.Controller) == None) {
			return;
		} 
	}	

	// If we don't have a projectile class, and are not an instant hit weapon

	if (UsingPawn == none || Target == none)
	{
		return;  
	}
	if (Target != none && VSizeSq(Target.Location - HitLocation) > 62500 )
	{
		return;
	}
	if (UsingPawn.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - UsingPawn.Location)) )
	{
		return;
	}

	//if (!self.bInstantHit)
		//Several weapons use instant hit and projectiles.
		if(class<Rx_Projectile>(MyProjectileClass) != None) {
			HeadShotDamageMultLocal = class<Rx_Projectile>(MyProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile>(MyProjectileClass).default.HeadShotDamageType;
			TempDamageType = class<Rx_Projectile>(MyProjectileClass).default.MyDamageType;
		//	`log("With Class " @ TempDamageType);
		} else {
			HeadShotDamageMultLocal = class<Rx_Projectile_Rocket>(MyProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile_Rocket>(MyProjectileClass).default.HeadShotDamageType;
			TempDamageType = class<Rx_Projectile_Rocket>(MyProjectileClass).default.MyDamageType;
			//`log("No class:" @ TempDamageType);
		}
		
		
		
		if(class<Rx_Projectile_Rocket>(MyProjectileClass) == none) Damage = MyProjectileClass.default.Damage * class<Rx_Projectile>(MyProjectileClass).static.GetDamageModifier(VRank, UsingPawn.Controller) * HeadShotDamageMultLocal; //class<Rx_Projectile>(ProjectileClass).default.Vet_DamageIncrease[VRank] * HeadShotDamageMultLocal;
		else
		Damage = MyProjectileClass.default.Damage * class<Rx_Projectile>(MyProjectileClass).static.GetDamageModifier(VRank, UsingPawn.Controller) * HeadShotDamageMultLocal;
	
		FireDir = Normal(Target.Location - UsingPawn.Location);
		Momentum = MyProjectileClass.default.MomentumTransfer * FireDir;

		if(HeadShotDamageType != None) 
		{
			DamageType = HeadShotDamageType; 
		} 
		else 
		{
			DamageType = MyProjectileClass.default.MyDamageType; 
		}
		//`log("Projectile hit mods vs. " @ TempDamageType);
	// Then we are an instant hit weapon

	if(Rx_Pawn(Target) != None && Rx_Pawn(Target).Armor > 0) 
	{
		//Rx_Pawn(Target).bHeadshot = true;	
		Rx_Pawn(Target).setbHeadshot(true);
		//`log("Armor mods vs. " @ TempDamageType);
		//Adjust for armour, as Rx_Pawn does not inherently adjust damage if it is a headshot 
		if(Rx_Pawn(Target).GetArmor() == A_KEVLAR) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.KevlarDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_FLAK) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.FlakDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_LAZARUS) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.LazarusDamageScalingFor(); 
		else
		ArmorMultiplier=1;
	//`log("Armor Mult" @ ArmorMultiplier @Damage); 
	}
	
	Damage*=ArmorMultiplier;
	
	if(DmgReduction <= 1.0)
		Damage*=DmgReduction; //Used for effective range manipulation. Should never be higher than 1 
	
	//`log("ServerALHeadshot Armor Multiplier: " @ ArmorMultiplier @ Damage);
	
	if(Rx_Pawn(UsingPawn) != None)
		Rx_Pawn(UsingPawn).HitEnemyWithHeadshotForDemoRec++;	
	
	Target.TakeDamage(Damage, UsingPawn.Controller, HitLocation, Momentum, DamageType, HitInfo, self);

	SpecialClass = class<Rx_DmgType_Special>(TempDamageType);

	//We only use projectiles, so get the burn multiplier from that
	if(SpecialClass != none)
		HeadShotDamageBurnMultiplier = SpecialClass.default.BleedDamageFactor;
	
	if (SpecialClass != None && SpecialClass.default.bCausesBleed && Rx_Pawn(Target) != None)
		Rx_Pawn(Target).AddBleed(SpecialClass.default.BleedDamageFactor*Damage*HeadShotDamageBurnMultiplier, SpecialClass.default.BleedCount, UsingPawn.Controller, SpecialClass.default.BleedType);
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local rotator FireRot;
	local vector FireLoc;

	if( UsingPawn != none )
	{
		if(FireSocketNames.Length > 0)
		{
			UsingPawn.Mesh.GetSocketWorldLocationAndRotation(FireSocketNames[CurrentFireSocket], FireLoc, FireRot, 0); 
			
			return FireLoc + vector(FireRot);
		}
		else
		{
			return UsingPawn.location;
		}
		
		return Location;
	}
}

reliable server function ServerALRadiusDamage(Actor Target, vector HurtOrigin, bool bFullDamage)
{
	local class<Rx_Projectile>	Rx_Proj;
	local class<DamageType> 	DamageType;
	local float					Momentum;
	local float 				Damage,DamageRadius;

	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}		

	Rx_Proj = class<Rx_Projectile>(MyProjectileClass);
	
	if (UsingPawn == none || Target == none || Rx_Proj == none)
	{
		return;  
	}
	
	if (UsingPawn.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - UsingPawn.Location)) )
	{
		return;
	}

	Momentum = Rx_Proj.default.MomentumTransfer;
	
	if(Rx_Proj.default.ExplosionDamageType != none && !bFullDamage) //Full damage IMPLIES this is actually the impacted actor
		DamageType = Rx_Proj.default.ExplosionDamageType;
	else
		DamageType = Rx_Proj.default.MyDamageType;
	
	Damage = Rx_Proj.default.Damage * Rx_Proj.static.GetDamageModifier(VRank, Instigator.Controller);
	DamageRadius = Rx_Proj.default.DamageRadius;
	
	Target.TakeRadiusDamage(Instigator.Controller,Damage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,self);
}

function bool IsInsideGracePeriod(float ShotDistance)
{
	local float DiedTime, FlightTime;

	if (MyProjectileClass != none )		
		FlightTime = ShotDistance / MyProjectileClass.default.Speed;
	else
		FlightTime = 0.075 ; 
		
	DiedTime = Rx_Controller(UsingPawn.Controller).LastDiedTime;
	
	if (DiedTime + FlightTime + 0.075 > WorldInfo.TimeSeconds)
		return true;
		
	return false;
}

simulated function bool UsesClientSideProjectiles()
{
	return true; //Usually not for passives
}

/** @return the actor that 'owns' this weapon's traces (i.e. can't be hit by them) */
simulated function Actor GetTraceOwner()
{
	return (UsingPawn != None) ? UsingPawn : self;
}

/*Some projectiles (Rockets) may need to adjust their initial yaw depending on what barrel they're spawned at.*/ 
simulated function int GetRProjectileYaw(){
	return 1.0; //Modifier... usually 1.0 or -1.0 
}

DefaultProperties
{
	MyProjectileClass = class'Rx_Projectile_Grenade'
	AbilityRange = 4000
	
	FireSocketNames(0) =WeaponPoint
}