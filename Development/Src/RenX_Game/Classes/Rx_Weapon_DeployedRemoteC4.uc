/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedRemoteC4 extends Rx_Weapon_DeployedC4;

var bool bDestroyed;

var Controller Planter;
var bool bIsRemoteC4;


simulated function PostBeginPlay()
{
	Super(Rx_Weapon_DeployedActor).PostBeginPlay();
	ClearTimer('Explosion'); 
	Planter = InstigatorController;
}

function KillCheck()
{
	if( Role == ROLE_Authority )
	{
		// Destroy when player dies
		if( Instigator == None || Instigator.Health <= 0 )
			Destroy();
	}
}

function Landed(vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	SetTimer(1.0, true, 'KillCheck');
}

simulated function Destroyed() {
	if(!bDestroyed) { // bugfix because destroyed sometimes gets called more than once
	
		if (Role == ROLE_Authority && bUsesMineLimit)
			Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[GetTeamNum()]).mineCount--;	
	
		if (bIsRemoteC4 && Role == ROLE_Authority && Rx_PRI(Planter.PlayerReplicationInfo) != None) 
			Rx_PRI(Planter.PlayerReplicationInfo).RemoveRemoteC4(self);	
		super.Destroyed();
		bDestroyed = true;
	}
}

defaultproperties
{
   
    DeployableName="Remote C4"
    HP = 200
    Damage=200
	DmgRadius=300
	DamageMomentum=8000.0
	bUsesMineLimit=false
	bIsRemoteC4=true

	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	ExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4'
	ImpactSound=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Disarm'	
	ChargeDamageType=class'Rx_DmgType_RemoteC4'
	
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=100.0
	OuterExplosionShakeRadius=500.0		

	DisarmScoreReward = 30

	Begin Object Name=DeployableMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RemoteC4.Mesh.WP_RemoteC4'
		PhysicsAsset=PhysicsAsset'RX_WP_RemoteC4.Mesh.WP_RemoteC4_Physics'
		Scale=1.0
	End Object
	
	
}