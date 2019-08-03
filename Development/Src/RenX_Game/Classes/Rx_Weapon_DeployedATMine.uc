/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedATMine extends Rx_Weapon_DeployedProxyC4;

/** The factor of the DisarmScoreReward to give the player when they destroy the mine. */
var(Damage) float                  DestroyRewardFactor;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(Instigator != none ) Planter = InstigatorController;

}

function KillCheck()
{
	if( Role == ROLE_Authority )
	{
		// Destroy when player dies
		if( Instigator == None )  //|| Instigator.Health <= 0 )
			Destroy();
	}
}




function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (CanDisarmMe(DamageCauser))
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	else
	{
		if (class<Rx_DmgType>(DamageType) != None)
			DamageAmount *= class<Rx_DmgType>(DamageType).static.MineDamageScalingFor();
		else
			DamageAmount = 0;

		super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

		if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
		  return;

		if (EventInstigator.GetTeamNum() != GetTeamNum())
			HP -= DamageAmount;

		if (HP <= 0)
		{
			InstigatorController = EventInstigator;
			TeamNum = InstigatorController.GetTeamNum();
			SetDamageAll(true);
			ClearTimer('Explosion');
			Explosion();
		
			if (EventInstigator.PlayerReplicationInfo != none)
			{
				Rx_Pri(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(DisarmScoreReward*DestroyRewardFactor,true);
			}
		
		}

		if(ImpactedActor != None)
			ImpactedActor.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	}
}

event Landed( vector HitNormal, actor FloorActor )
{
	super.Landed(HitNormal, FloorActor);
	//SetTimer(1.0, true, 'KillCheck');
	if (Pawn(FloorActor) != None)
        Detonate();	
}

simulated event Destroyed()
{
	super.Destroyed();
	if (Role == ROLE_Authority && Rx_PRI(Planter.PlayerReplicationInfo) != None)
		Rx_PRI(Planter.PlayerReplicationInfo).RemoveATMine(self);
}

/** Explosion from Rx_Weapon_DeployedC4, as it supports DamageAll. */
function Explosion()
{
	super(Rx_Weapon_DeployedC4).Explosion();
}

defaultproperties
{
   
    DeployableName="Anti-Tank Mine"
    HP = 150 //50
    Damage=50
    DirectLineOfSightDamage=50
	DmgRadius=700
	DamageMomentum=60000.0
	TriggerRadius=0	 
	VehicleTriggerRadius=150
	DetonateDelay = 0.35f
	bUsesMineLimit=false
	bIsRemoteC4=false

	// Required in order to take radius damage
	bCanBeDamaged=true
	bProjTarget=true
	bWorldGeometry=false

	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	ExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Large'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big'
	ImpactSound=SoundCue'rx_wp_proxyc4.Sounds.SC_ProxyC4_Impact'
	ChargeDamageType=class'Rx_DmgType_ATMine'
	
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=100.0
	OuterExplosionShakeRadius=800.0	

	DisarmScoreReward = 30
	DestroyRewardFactor = 0.5

	Begin Object Name=DeployableMesh
		SkeletalMesh=SkeletalMesh'RX_WP_ATMine.Mesh.SK_WP_ATMine_Deployed'
		PhysicsAsset=PhysicsAsset'RX_WP_ATMine.Mesh.SK_WP_ATMine_Deployed_Physics'
		Scale=1.0
	End Object
}