/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedProxyC4 extends Rx_Weapon_DeployedRemoteC4
	implements (RxIfc_EMPable)
	implements (RxIfc_TargetedDescription);

var float TriggerRadius;
var float VehicleTriggerRadius;
var Pawn Activator;
var float DirectLineOfSightDamage;
var float DetonateDelay;
var PlayerReplicationInfo OwnerPRI;

var int EMPDisarmTime;	// time it takes for the EMP to disarm a full health mine. Note integer and not floating point.
var int EMPTicks;
var Controller EMPInstigator;
var Actor EMPActor;

replication
{
	if (bNetInitial)
		OwnerPRI;
}

simulated function PostBeginPlay()
{
	Super(Rx_Weapon_DeployedActor).PostBeginPlay();
	OwnerPRI = InstigatorController.PlayerReplicationInfo;
	Planter = InstigatorController;
	ClearTimer('Explosion'); 
	ClearTimer('CountDown'); 
}

simulated function PerformDeploy()
{
	super.PerformDeploy();
    settimer(0.4, true, 'CheckProxy');
    /**
    if (WorldInfo.Game.NumBots > 0)
    {
       Spawn(class'UTAvoidMarker'); // for AI
    }
    */	
}

// Remove on death removal.
function Landed(vector HitNormal, Actor FloorActor)
{
	super(Rx_Weapon_DeployedC4).Landed(HitNormal, FloorActor);
}

function CheckProxy()
{
	local Rx_Pawn P;
	local Rx_Vehicle V;
	
	ForEach CollidingActors(class'Rx_Pawn', P, TriggerRadius,, true)
	{
      if ((GetTeamNum() != P.GetTeamNum()) && (P.Health > 0) && bDeployed) {
      	Activator = P;
		Detonate();
		ClearTimer('CheckProxy');
		break;
      }
   }
   
	ForEach OverlappingActors(class'Rx_Vehicle', V, VehicleTriggerRadius,, true)
	{
      if ((GetTeamNum() != V.GetTeamNum()) && (V.Health > 0) && bDeployed && !(V.GetTeamNum() == 255)) {
      	Detonate();
		ClearTimer('CheckProxy');
		break;
      }
   }
}

function Detonate()
{
	if (DetonateDelay > 0)
      	SetTimer(DetonateDelay,false,'Explosion');
	else
		Explosion();
}

function Explosion()
{
	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
		bExplode = true;
	if (WorldInfo.NetMode != NM_DedicatedServer)
		PlayExplosionEffect();

	if ( Role == ROLE_Authority )
	{
		if(Activator != None && FastTrace(Activator.location,location))
		{
			Activator.TakeDamage(DirectLineOfSightDamage,InstigatorController,Location,vect(0,0,0),ChargeDamageType);
		}
			
		HurtRadius(Damage, DmgRadius, ChargeDamageType, DamageMomentum, Location); /** Applies Radius Damage to all but ImpactedActor */
		SetTimer(0.1f, false, 'DestroyMe');
	}
}

simulated function bool CanDisarmMe(Actor A)
{
	if (Rx_Projectile_EMPGrenade(A) != None)
		return true;
	return super.CanDisarmMe(A);
}

simulated function bool IsEffectedByEMP()
{
	return true;
}

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor)
{
	if (InstigatedByController.GetTeamNum() == GetTeamNum() || EMPTicks > 0)
		return false;
	EMPTicks = EMPDisarmTime;
	EMPInstigator = InstigatedByController;
	EMPActor = EMPCausingActor;
	SetTimer(1.0, true, 'EMPDisarmTick');
	EMPDisarmTick();
	return true;
}

function EMPDisarmTick()
{
	TakeDamage(float(default.HP/EMPDisarmTime), EMPInstigator, Location, Vect(0,0,0), class'Rx_DmgType_EMP',,EMPActor);
	if (--EMPTicks <= 0)
		ClearTimer('EMPDisarmTick');
}

function EnteredEMPField(Rx_EMPField EMPField);

function LeftEMPField(Rx_EMPField EMPField);

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if (OwnerPRI != None && PlayerPerspective.GetTeamNum() == GetTeamNum())
	{
		if (PlayerPerspective.PlayerReplicationInfo == OwnerPRI)
			return "Your Mine";
		else 
			return "Placed by "$OwnerPRI.PlayerName;
	}
	return "";
}

defaultproperties
{
   
    DeployableName="Proximity Mine"
    HP = 200
    Damage=50
    DirectLineOfSightDamage=30
	DmgRadius=360
	DamageMomentum=8000.0
	TriggerRadius=130	 
	VehicleTriggerRadius=5
	DetonateDelay = 0.0f
	bUsesMineLimit=true
	bIsRemoteC4=false

	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	ExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4'
	ImpactSound=SoundCue'rx_wp_proxyc4.Sounds.SC_ProxyC4_Impact'
	ChargeDamageType=class'Rx_DmgType_ProxyC4'
	
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=50.0
	OuterExplosionShakeRadius=400.0	

	DisarmScoreReward = 20
	EMPDisarmTime=10

	Begin Object Name=DeployableMesh
		SkeletalMesh=SkeletalMesh'rx_wp_proxyc4.Mesh.SK_WP_Proxy_Deployed'
		PhysicsAsset=PhysicsAsset'rx_wp_proxyc4.Mesh.SK_WP_Proxy_3P_Physics'
		Scale=1.0
	End Object
	
	
}