/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedBeacon extends Rx_Weapon_DeployedActor
	abstract
	implements (RxIfc_TargetedDescription);

var int 					  count;
var array<SoundCue>           GdiCountdownSounds;
var array<SoundCue>           NodCountdownSounds;
var SoundCue   				  GdiDeployedSound;
var SoundCue   				  NodDeployedSound;
var SoundCue   				  GdiDisarmSound;
var SoundCue   				  NodDisarmSound;
var SoundCue                  BeepCue;
var SoundCue                  GdiCountDownInitiatedSound;
var SoundCue                  NodCountDownInitiatedSound;
var SoundCue                  BuildUpAndExplosionSound;
var SoundCue                  GdiApproachingSound;
var SoundCue                  NodApproachingSound;
var SoundCue                  GdiImminentSound;
var SoundCue                  NodImminentSound;
var class<UDKExplosionLight>  ExplosionLightClass;
var rotator					  emitterRotation;
var ParticleSystemComponent   BlinkingLightComponent;
var float		     	      DeployTime;

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();
   emitterRotation = rotation;
   emitterRotation.pitch = 0;
}

simulated function PerformDeploy()
{
   local vector BlinkinglightSpawnLocation;
   local rotator BlinkinglightSpawnRotation;
   super.PerformDeploy();

   if (!bImminentExplode)
   {
	  DeployTime = Worldinfo.Timeseconds;
	  
	  if(WorldInfo.NetMode != NM_Client) 
      {
		if (TimeUntilExplosion > GdiApproachingSound.Duration && TimeUntilExplosion > NodApproachingSound.Duration)
			SetTimer(3.0, false, 'playApproachingSound');
		if (TimeUntilExplosion - 31.0f > 0)
			SetTimer(TimeUntilExplosion - 31.0f, false, 'playCountInitiatedDownSound');
		if (TimeUntilExplosion - 14.0f > 0)
			SetTimer(TimeUntilExplosion - 14.0f, false, 'PlayImminentSound');
		if (TimeUntilExplosion - 11.0f > 0)
			SetTimer(TimeUntilExplosion - 11.0f, false, 'DeactivateHealingAbility');
      }
      if(WorldInfo.NetMode != NM_DedicatedServer)
      {
		 CreateAudioComponent(BeepCue,true,true,true,,true);
		 if (TimeUntilExplosion - 10.5f > 0)
			SetTimer(TimeUntilExplosion - 10.5f, false, 'CreateBuildUpAndExplosionSound');
		 else
			PlayExplosionSound = true; // If there's not enough time to play the whole build up + explosion, play the explosion sound.

         SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( 'BlinkingLightSocket', BlinkinglightSpawnLocation, BlinkinglightSpawnRotation );
         BlinkingLightComponent = WorldInfo.MyEmitterPool.SpawnEmitter(BlinkingLight, BlinkinglightSpawnLocation, BlinkinglightSpawnRotation,self);		
      }
   }
}

simulated function PlayApproachingSound() 
{
   local PlayerController PC; 
   
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiApproachingSound);
       } else 
       {
         PC.ClientPlaySound(NodApproachingSound);
       }
      }
}

simulated function PlayImminentSound()
{
	local PlayerController PC; 
   
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiImminentSound);
       } else 
       {
         PC.ClientPlaySound(NodImminentSound);
       }
      }
}

function BroadcastPlaced()
{
	`LogRx("GAME"`s "Deployed;" `s self.Class `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo) );
	BroadcastLocalizedMessage(class'Rx_Message_Deployed',-1,InstigatorController.PlayerReplicationInfo,,self.Class);
}

simulated function playCountInitiatedDownSound()
{
   local PlayerController PC; 
   
   SetTimer(5.0f, true, 'playCountDownSound');
   foreach WorldInfo.AllControllers(class'PlayerController', PC)
   {
      if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiCountDownInitiatedSound);
      } 
      else 
      {
         PC.ClientPlaySound(NodCountDownInitiatedSound);
      }
   }
}

simulated function CreateBuildUpAndExplosionSound()
{
   PlaySound(BuildupAndExplosionSound,true,false,false);
}


simulated function PlayDisarmedEffect()
{
	if ( BlinkingLightComponent != none )
	{
		 BlinkingLightComponent.DeactivateSystem();
	}

	super.PlayDisarmedEffect();

}

simulated function Destroyed()
{
	super.Destroyed();

	if ( BlinkingLightComponent != none )
	{
		 BlinkingLightComponent.DeactivateSystem();
	}
}

function BroadcastDisarmed(Controller Disarmer)
{
	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRx("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo) `s "owned by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	else
		`LogRx("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo));
	BroadcastLocalizedMessage(class'Rx_Message_Deployed',GetTeamNum(),Disarmer.PlayerReplicationInfo,,self.Class);
}


simulated function playCountDownSound() 
{
   local PlayerController PC; 
   
   if(count > GdiCountdownSounds.Length || count > NodCountdownSounds.Length)
   {
      return;
   }
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(default.GdiCountdownSounds[count]);
       } else 
       {
         PC.ClientPlaySound(default.NodCountdownSounds[count]);
       }	
      }
      count++;
      if(count == 4) 
      {
         SetTimer(1.0f, true, 'playCountDownSound');
      }
}

function DeactivateHealingAbility()
{
   bCanNotBeDisarmedAnymore = true;	
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
   if(!bCanNotBeDisarmedAnymore) {
      return super.HealDamage(Amount,Healer,DamageType);
   }
   return false;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(!bCanNotBeDisarmedAnymore)
	{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	}
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	local int DisarmTime;
	DisarmTime = int((TimeUntilExplosion - 10) - (WorldInfo.TimeSeconds - DeployTime));
	if(DisarmTime <= 0)
		return "";
	else
		return string(DisarmTime);
}

DefaultProperties
{
	PlayExplosionSound = false;
	bBroadcastPlaced = true;
	bBroadcastDisarmed = true;
	bFullDamage = true; // do radius damage on pawns
	TimeUntilExplosion = 60.0f;
	DisarmScoreReward = 200;
	VectorHurtOrigin=(X=0,Y=0,Z=1);
	DamageMomentum = 500000.0f
	DmgRadius = 1500.0f
	BuildingDmgRadius = 500.0f
	Damage = 5000;
	HP = 400;
}