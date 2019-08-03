/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedNukeBeacon extends Rx_Weapon_DeployedBeacon;

var ParticleSystemComponent   TempComp, ExplosionParticle;
var SoundCue                  ExposionSound;
var ParticleSystem            PartSysTemplate;
var ParticleSystem            SecondaryExplosionEffect;
var repnotify bool 		      bPlayNukeMissile;
var float                     NukeParticleLength;



replication
{
   if (Role == ROLE_Authority && bNetDirty)
      bPlayNukeMissile;
}

simulated event ReplicatedEvent(name VarName)
{
   if ( VarName == 'bPlayNukeMissile' )
   {
      PlayNukeMissile();
   }	
   else
   {
      Super.ReplicatedEvent(VarName);
   }
}

simulated function PerformDeploy()
{
   super.PerformDeploy();

   if (!bImminentExplode)
   {
      if(WorldInfo.NetMode != NM_Client) 
      {            
         SetTimer(TimeUntilExplosion - NukeParticleLength, false, 'NukeMissile');
      }
   }
}

function NukeMissile() {
   bPlayNukeMissile = true;
   if (WorldInfo.NetMode != NM_DedicatedServer) {
      PlayNukeMissile();
   }
}

simulated function PlayNukeMissile()
{
      TempComp = WorldInfo.MyEmitterPool.SpawnEmitter(PartSysTemplate, Location, emitterRotation);
      TempComp.ActivateSystem();
}

simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
   local vector loc;
   SpawnRotation.Pitch = 0;
   WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
   WorldInfo.MyEmitterPool.SpawnEmitter(SecondaryExplosionEffect, SpawnLocation, SpawnRotation);
   loc = location;
   loc.z += 1024;
   if(ExplosionLightClass != None)
      UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight( ExplosionLightClass, loc);
   PlayCamerashakeAnim();	
}


defaultproperties
{
   DeployableName = "Nuclear Strike Beacon";
   DamageTypeClass = class'Rx_DmgType_Nuke'

   BeepCue = SoundCue'RX_WP_Nuke.Sounds.Nuke_BeepsCue'
   GdiDeployedSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeDeployed_Cue'
   NodDeployedSound=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeDeployed_Cue'  	
   BuildUpAndExplosionSound=SoundCue'RX_WP_Nuke.Sounds.SC_Nuke_BuildUpExplosion'
   ExplosionSound=SoundCue'RX_WP_Nuke.Sounds.SCue_Explosion_Nuke'

 GdiImminentSound = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeImminent_Cue'
 NodImminentSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeImminent_Cue'

	GdiDisarmSound = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeDisarmed_Cue'
	NodDisarmSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeDisarmed_Cue'

   GdiCountdownSounds(0)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_25_Cue'
   GdiCountdownSounds(1)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_20_Cue'
   GdiCountdownSounds(2)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_15_Cue'
   GdiCountdownSounds(3)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_10_Cue'
   GdiCountdownSounds(4)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_9_Cue'
   GdiCountdownSounds(5)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_8_Cue'
   GdiCountdownSounds(6)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_7_Cue'
   GdiCountdownSounds(7)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_6_Cue'
   GdiCountdownSounds(8)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_5_Cue'
   GdiCountdownSounds(9)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_4_Cue'
   GdiCountdownSounds(10)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_3_Cue'
   GdiCountdownSounds(11)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_2_Cue'
   GdiCountdownSounds(12)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_1_Cue'
   GdiCountdownSounds(13)=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_0_Cue'
   
   NodCountdownSounds(0)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_25_Cue'
   NodCountdownSounds(1)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_20_Cue'
   NodCountdownSounds(2)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_15_Cue'
   NodCountdownSounds(3)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_10_Cue'
   NodCountdownSounds(4)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_9_Cue'
   NodCountdownSounds(5)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_8_Cue'
   NodCountdownSounds(6)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_7_Cue'
   NodCountdownSounds(7)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_6_Cue'
   NodCountdownSounds(8)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_5_Cue'
   NodCountdownSounds(9)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_4_Cue'
   NodCountdownSounds(10)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_3_Cue'
   NodCountdownSounds(11)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_2_Cue'
   NodCountdownSounds(12)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_1_Cue'
   NodCountdownSounds(13)=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_0_Cue'	
   
   GdiCountDownInitiatedSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_CountDownInitiated_Cue'
   NodCountDownInitiatedSound=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_CountDownInitiated_Cue'
   
   GdiApproachingSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeApproaching_Cue'
   NodApproachingSound=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeApproaching_Cue'
   
   // DisarmSounds(0) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_NuclearStrikeDisarmed_Cue'
   // DisarmSounds(1) = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeDisarmed_Cue'

   PartSysTemplate=ParticleSystem'RX_WP_Nuke.Effects.P_Nuke_Falling'
	NukeParticleLength = 10
   ExplosionEffect=ParticleSystem'RX_WP_Nuke.Effects.P_Nuke_Explosion'
   SecondaryExplosionEffect=ParticleSystem'RX_WP_Nuke.Effects.P_Explosion_Secondary'
   BlinkingLight=ParticleSystem'RX_WP_Nuke.Effects.P_NukeBeacon_BlinkingLight'
   
   ExplosionShake=CameraAnim'RX_FX_Envy.Camera.CA_Shake_Nuke'
   
   InnerExplosionShakeRadius=4000.0
   OuterExplosionShakeRadius=16000.0	

   ExplosionLightClass=class'RenX_Game.Rx_Light_Nuke_Explosion'	

   Begin Object Name=DeployableMesh
      SkeletalMesh=SkeletalMesh'RX_WP_Nuke.Mesh.SK_WP_Nuke_Deployed'
      PhysicsAsset=PhysicsAsset'RX_WP_Nuke.Mesh.SK_WP_Nuke_Deployed_Physics'
      Scale3D=(X=1.0,Y=1.0,Z=1.0)
      Scale=1.0f
   End Object
   bCollideActors=false

   RemoteRole = ROLE_SimulatedProxy
   LifeSpan = 60.2f
   
   MinimapIconTexture = Texture2D'RenxHud.T_Beacon_Nuke';
}