class Rx_SupportVehicle_CruiseMissile_EMP extends Rx_SupportVehicle_CruiseMissile; 

var	float	EMPVehicleTimeModifier; 


simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(MyAudioComponent, RootSocketName);
}

simulated function AirBurst()
{
	MyAudioComponent.Stop(); 

	Explosion(InstigatorController);	
}

simulated function Explosion(optional Controller EventInstigator) //Overrite for EMP so it doesn't have to re-iterate to EMP everything it already applied radius damage to
{
   local Actor A;  
  
  if(bExploded) return; //Don't double dip on explosions
  
  bExploded = true; 
   if (WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
      PlayExplosionEffect();

  if(bExplodes )
   foreach CollidingActors(class'Actor', A, ExplosionRadius, Location, false)
		{
         if(A != self)  A.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bDoFullDamage, self);
			
				if ( RxIfc_EMPable(A) != None && RxIfc_EMPable(A).IsEffectedByEMP() && (A.bCanBeDamaged || A.bProjTarget) )
				{
					if (Rx_Building(A) != None)
						continue;
					RxIfc_EMPable(A).EMPHit(EventInstigator, self, EMPVehicleTimeModifier);
				}
		
		}
   
   if (WorldInfo.NetMode != NM_Client)
	//	ReplicatePositionAfterLanded(); 
		Spawn(class'Rx_EMPField',self,,location,,,);
   
   SetTimer(0.1f, false, 'ToDestroy');
}

DefaultProperties
{

/**Missile specific*/ 

EMPVehicleTimeModifier = 5.0 //Keep vehicles locked down for an exceptional amount of time 

/****************************/


/**Rx_SupportVehicle_Air*/

/************************/

/********************************/
/**Rx_BasicPawn characteristics**/
/********************************/
 
ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade'
ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade'

EntrySound = SoundCue'RX_SoundEffects.Missiles.SC_CruiseMissileFire'

ExplosionDamage=50
ExplosionRadius=3000
bDamageAll=true 
DamageMomentum=100
bExplodeOnImpact = true; 

DamageTypeClass=class'Rx_DmgType_CruiseMissile'

ActorName = "Sparky Shit" 

	
}