class Rx_CommanderSupport_SmokeBomb extends Rx_CommanderSupport_EMPBomb;
	

simulated function Explosion(optional Controller EventInstigator) //Overrite for EMP so it doesn't have to re-iterate to EMP everything it already applied radius damage to
{
   local Rx_SmokeScreen_Large Screen; 
  
  if(bExploded) return; //Don't double dip on explosions
  
  if(!bArmed) 
  {
	SetHidden(true); 
	SetTimer(0.05f, false, 'ToDestroy');  
	return; 
  }
  
	bExploded = true; 
   if (WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
      PlayExplosionEffect();
	  
   if (WorldInfo.NetMode != NM_Client)
   {
	   Screen = Spawn(class'Rx_SmokeScreen_Large',self,,location,,,);
	   Screen.InitSmokeScreen(0, Rx_Pawn(EventInstigator.Pawn)); 
   }
		
		
   SetHidden(true);
   
   SetTimer(0.05f, false, 'ToDestroy');
}	


event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	Explosion(InstigatingController);	
	super.HitWall(HitNormal, Wall, WallComp);
}

/******************************/

DefaultProperties
{

	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke'
	ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade'

	ActorName = "Smoke Canister" 

	
}