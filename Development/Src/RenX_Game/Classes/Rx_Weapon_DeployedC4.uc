/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedC4 extends Rx_Weapon_DeployedActor
	abstract;

var vector FloorNormal;

var bool bUsesMineLimit;

/** Explosion effect */
var ParticleSystem ShapedChargeExplosion;

/** Class of ExplosionLight */
var class<UDKExplosionLight> ExplosionLightClass;

var class<UTDamageType> ChargeDamageType;

var float ChargeColourBlend;

var UTAvoidMarker FearSpot;

var	SoundCue ImpactSound;
var Actor ImpactedActor;
var ParticleSystem ExplosionTemplate;
var repnotify bool bExploded;

replication
{
	if (bNetDirty && Role == Role_Authority)
      ImpactedActor, bExploded;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bExploded')
	{
		if(bExploded) PlayExplosionEffect(); 
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}



event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	// make it sticky on everything except the owner and blocking volumes
   if (Other != self.Instigator && (Volume(Other) == none || BlockingVolume(Other) != none) && Other.bBlockActors == true && bDeployed == false)
   {
      Landed(HitNormal, Other);
   }
   Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}


event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	FloorNormal = HitNormal;
   	Landed(HitNormal, Wall);
   	Super.HitWall (HitNormal, Wall, WallComp);
}

function Landed(vector HitNormal, Actor FloorActor)
{
   	ImpactedActor = FloorActor;
   	//loginternal(impactedActor);
   	FloorNormal = HitNormal;
   	PlaySound(ImpactSound);
	super.Landed(HitNormal, FloorActor);
}

simulated function PerformDeploy()
{
	super.PerformDeploy();

	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(LandEffects != none && !LandEffects.bIsActive)
			LandEffects.SetActive(true);
	}

	if(ImpactedActor != None) {
		if(UTPawn(ImpactedActor) != None) {
			SetBase(ImpactedActor,FloorNormal,UTPawn(ImpactedActor).Mesh);
			//SetCollision(false);
		} else {
			SetBase(ImpactedActor,FloorNormal);	
		}
		
		if(ROLE == ROLE_Authority  && InstigatorController != None)
		{
		if (Rx_Pawn(ImpactedActor) != None && Rx_Pawn(ImpactedActor).PlayerReplicationInfo != None)
			`LogRxPub("GAME" `s "Deployed;" `s self.class `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo) `s "on" `s `PlayerLog(Rx_Pawn(ImpactedActor).PlayerReplicationInfo) `s "near" `s GetSpotMarkerName() `s "at" `s Location);
		else
			`LogRxPub("GAME" `s "Deployed;" `s self.class `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo) `s "on" `s ImpactedActor.Class.name `s "near" `s GetSpotMarkerName() `s "at" `s Location);
		}
	}
	else if (Base != none)
		Base.Attach(self);
}

simulated function PlayExplosionEffect()
{
	local rotator Dir;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// spawn client side explosion effect
		if ( EffectIsRelevant(Location, false) )
		{
			Dir = rotator(FloorNormal);
			
			WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, Location, Dir, ImpactedActor);			
			
			if(ExplosionLightClass != None)
				UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight( ExplosionLightClass,
						Location + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * (vect(1,0,0) >> Dir)) );
		}
		PlaySound(ExplosionSound, true);
		PlayCamerashakeAnim();
	}
}

function Explosion()
{
	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRxPub("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	else
		`LogRxPub("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location);
	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
		bExplode = true;
	if (WorldInfo.NetMode != NM_DedicatedServer)
		PlayExplosionEffect();

	if ( Role == ROLE_Authority )
	{

		HurtRadius(Damage*Vet_DamageModifier[VRank], DmgRadius, ChargeDamageType, DamageMomentum, Location); /** Applies Radius Damage to all but ImpactedActor */
		if(ImpactedActor != None && (ImpactedActor.GetTeamNum() != GetTeamNum() || bDamageAll)) {
			ImpactedActor.TakeDamage(Damage*Vet_DamageModifier[VRank],InstigatorController,Location,vect(0,0,0),ChargeDamageType);
		}		
		SetTimer(0.1f, false, 'DestroyMe');
	}
}

function DestroyMe()
{
	Destroy();
}

/** Applies Radius Damage to all but ImpactedActor */
simulated function bool HurtRadius
(
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
)
{
	local Pawn Victim;
	local bool bCausedDamage;
	//local TraceHitInfo HitInfo;

	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return false;
		
   if (InstigatedByController == None)
   {
      InstigatedByController = InstigatorController;
   }		

	bHurtEntry = true;
	bCausedDamage = false;
	//foreach VisibleCollidingActors( class'Pawn', Victim, DamageRadius, HurtOrigin,,,,, HitInfo )
	foreach OverlappingActors( class'Pawn', Victim, DamageRadius, HurtOrigin, true)
	{
		if(Victim == ImpactedActor || (!bDamageAll && GetTeamNum() == Victim.GetTeamNum() && Victim.Controller != InstigatorController) ) {
			continue;
		}
		if ( (Victim != IgnoredActor) && (Victim.bCanBeDamaged || Victim.bProjTarget) )
		{
			//if(FRand() < 0.75)
				Victim.TakeDamage(20,InstigatedByController,Location,vect(0,0,0),class'Rx_DmgType_BurnC4');
			Victim.TakeRadiusDamage(InstigatedByController, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bDoFullDamage, self);
			bCausedDamage = bCausedDamage || Victim.bProjTarget;
		}
	}
	bHurtEntry = false;
	return bCausedDamage;
}

function BroadcastDisarmed(Controller Disarmer)
{
	super.BroadcastDisarmed(Disarmer);
	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRxPub("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo) `s "owned by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	else
		`LogRxPub("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo));
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	
	//super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
		if (!CanDisarmMe(DamageCauser))
	{
		return;
	}
	
	super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
      return;

	HP -= DamageAmount;

	if (HP <= 0)
	{
		BroadcastDisarmed(EventInstigator);
		if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
			bDisarmed = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
			PlayDisarmedEffect();      
			ClearTimer('Explosion');

		
		if (EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum)
		{
			Rx_Controller(EventInstigator).DisseminateVPString( "[C4 Disarmed]&" $ class'Rx_VeterancyModifiers'.default.Ev_C4Disarmed $ "&");
			Rx_Pri(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(DisarmScoreReward,true);
			Rx_PRI(EventInstigator.PlayerReplicationInfo).AddMineDisarm();
		}
		
		SetTimer(0.1, false, 'DestroyMe'); // delay it a bit so disappearing blends a littlebit better with the disarmed effects
	}
	
	if (!CanDisarmMe(DamageCauser))
	{
		if(ImpactedActor != None)
			ImpactedActor.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
		return;
	}
}

defaultproperties
{
	bUsesMineLimit=false
	TimeUntilExplosion=30.0f
	bAlwaysRelevant=true

	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	ExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4'
	
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=150.0
	OuterExplosionShakeRadius=550.0
	
	 bWorldGeometry          = false //true  //Set to false to not block the camera 
}