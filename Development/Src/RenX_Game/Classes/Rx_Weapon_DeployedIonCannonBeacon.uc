/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedIonCannonBeacon extends Rx_Weapon_DeployedBeacon;


var() ParticleSystem          SecondaryExplosionEffect;
var() ParticleSystem          AftermathCloudsEffect;
var() ParticleSystem          IonBeamEmitterEffect;
var() ParticleSystem          IonBeamPedestalEmitterEffect;
var() ParticleSystem          ExplosionPedestalEffect;
var() ParticleSystem          GroundUpSuckEffect;
var repnotify bool 		      bPlayGroundUpSuckEffect;
var repnotify bool 		      bPlayIonBeamEffect;


replication
{
   if (Role == ROLE_Authority && bNetDirty)
      bPlayGroundUpSuckEffect, bPlayIonBeamEffect;
}

simulated event ReplicatedEvent(name VarName)
{
   if ( VarName == 'bPlayGroundUpSuckEffect' )
   {
      PlayGroundUpSuckEffect();
   }
    else if (VarName == 'bPlayIonBeamEffect') 
    {
      PlayIonBeamEmitterEffect();
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
         SetTimer(TimeUntilExplosion - 10.0f, false, 'GroundUpSuck');
         SetTimer(TimeUntilExplosion - 2.5f, false, 'IonBeamEffect');
      }
   }
}

function GroundUpSuck() {
   bPlayGroundUpSuckEffect = true;
   if (WorldInfo.NetMode != NM_DedicatedServer) {
      PlayGroundUpSuckEffect();
   }
}

function IonBeamEffect() {
   bPlayIonBeamEffect = true;
   if (WorldInfo.NetMode != NM_DedicatedServer) {
      PlayIonBeamEmitterEffect();
   }
}

simulated function PlayGroundUpSuckEffect() {

   local Vector ExplodeLocation;

   if(bOnPedestal)
      ExplodeLocation = GetPedestalExplosionPoint();

   else
      ExplodeLocation = Location;

   WorldInfo.MyEmitterPool.SpawnEmitter(GroundUpSuckEffect, ExplodeLocation, emitterRotation);
}

simulated function PlayIonBeamEmitterEffect() {

   local Vector ExplodeLocation;

   if(bOnPedestal)
      ExplodeLocation = GetPedestalExplosionPoint();

   else
      ExplodeLocation = Location;


   if(bOnPedestal)
      WorldInfo.MyEmitterPool.SpawnEmitter(IonBeamPedestalEmitterEffect, ExplodeLocation, emitterRotation);
   else
      WorldInfo.MyEmitterPool.SpawnEmitter(IonBeamEmitterEffect, ExplodeLocation, emitterRotation);
}

simulated function PlayExplosionEffect()
{
   local vector SpawnLocation;
   local vector loc;
   local rotator SpawnRotation;

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (ExplosionSound != none)
         PlaySound(ExplosionSound, true);

      if(bOnPedestal)
      {
         SpawnLocation = GetPedestalExplosionPoint();
         SpawnRotation = Rotation;
      }
      else if (ExplosionSocketName != '')
         SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( ExplosionSocketName, SpawnLocation, SpawnRotation );
      else
      {
         SpawnLocation = Location;
         SpawnRotation = Rotation;
      }
      if(bOnPedestal)
         WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionPedestalEffect, SpawnLocation, emitterRotation);       
      else
         WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, emitterRotation);


      WorldInfo.MyEmitterPool.SpawnEmitter(SecondaryExplosionEffect, SpawnLocation, emitterRotation);
      WorldInfo.MyEmitterPool.SpawnEmitter(AftermathCloudsEffect, SpawnLocation, emitterRotation);
      loc = location;
      loc.z += 1024;
      if(ExplosionLightClass != None)
         UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight( ExplosionLightClass, loc);
      PlayCamerashakeAnim();			
    }
} 

simulated function PlayCamerashakeAnim()
{
   local UTPlayerController UTPC;
   local float Dist;
   local float ExplosionShakeScale;
      
   foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
   {
      Dist = VSizeSq(Location - UTPC.ViewTarget.Location);

      if (Dist < Square(OuterExplosionShakeRadius))
      {
         if (ExplosionShake != None)
         {
            ExplosionShakeScale = 1.5;
            if (Dist > Square(InnerExplosionShakeRadius))
            {
               ExplosionShakeScale -= (Sqrt(Dist) - InnerExplosionShakeRadius) / (OuterExplosionShakeRadius - InnerExplosionShakeRadius);
            }
            UTPC.PlayCameraAnim(ExplosionShake, ExplosionShakeScale);
         }
      }
   }
}

defaultproperties
{
   DeployableName = "Ion Cannon Beacon";
   DamageTypeClass = class'Rx_DmgType_IonCannon'
   
   BeepCue = SoundCue'RX_WP_IonCannon.Sounds.SC_ICBeacon_Beep'
   GdiDeployedSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_IonCannonDeployed_Cue';
   NodDeployedSound=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_IonCannonDeployed_Cue';
   BuildUpAndExplosionSound=SoundCue'RX_IonCannonStrike.Sounds.SC_IonCannon_BuildUp'
   ExplosionSound=SoundCue'RX_IonCannonStrike.Sounds.SC_IonCannon_Explosion'
   GdiApproachingSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_IonSatteliteApproaching_Cue' 
   NodApproachingSound=SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_IonSatteliteApproaching_Cue'

   GdiImminentSound = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_IonSatteliteStrikeImminent_Cue'
   NodImminentSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_IonSatteliteStrikeImminent_Cue'

	GdiDisarmSound = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_IonCannonDisarmed_Cue'
	NodDisarmSound = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_IonCannonDisarmed_Cue'
   
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
   
   // ExplosionSound=SoundCue'RX_WP_Nuke.Sounds.SCue_Explosion_Nuke'
   // DisarmSounds(0) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_Beacon_IonCannonDisarmed_Cue'
   // DisarmSounds(1) = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_IonCannonDisarmed_Cue'
   
   ExplosionShake=CameraAnim'RX_FX_Envy.Camera.CA_Shake_IonCannon'
   
   InnerExplosionShakeRadius=4000.0
   OuterExplosionShakeRadius=16000.0	

   ExplosionLightClass=class'RenX_Game.Rx_Light_Ion_Explosion'		
   
   SecondaryExplosionEffect		= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_Explosion_Secondary'
   AftermathCloudsEffect		= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_AftermathClouds_New'
   ExplosionEffect				= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_Explosion'
   ExplosionPedestalEffect            = ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_Explosion_Pedestal'
   IonBeamEmitterEffect			= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_Beam'
   IonBeamPedestalEmitterEffect       = ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_Beam_Pedestal'
   GroundUpSuckEffect			= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_GroundUpSuck'
   BlinkingLight				= ParticleSystem'RX_IonCannonStrike.ParticleSystems.P_IonCannonBeacon_BlinkingLight'

   Begin Object Name=DeployableMesh
      SkeletalMesh=SkeletalMesh'RX_WP_IonCannon.Mesh.SK_ICBeacon_Deployed'
      PhysicsAsset=PhysicsAsset'RX_WP_IonCannon.Mesh.SK_ICBeacon_Deployed_Physics'
      Scale3D=(X=1.0,Y=1.0,Z=1.0)
      Scale=1.0f
   End Object
   bCollideActors=false

    LifeSpan = 60.2f
	
	MinimapIconTexture = Texture2D'RenxHud.T_Beacon_Ion'
}